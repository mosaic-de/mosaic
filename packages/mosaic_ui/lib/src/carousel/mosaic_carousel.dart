// prefer_initializing_formals fires on the two constructors below and is
// wrong about them. `items:` and `itemCount:` are the public parameter
// names; the fields behind them are private because which of the two is
// populated is an implementation detail of the named constructors. The
// lint's fix — `this._items` — is not expressible: Dart forbids a
// private named parameter, so callers could not pass it at all.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/widgets.dart';

import '../theme/mosaic_theme.dart';

/// Horizontal swipeable list of items with optional page indicator.
///
/// Use it for cards (wallet, weather city tiles), feature highlights,
/// or any "swipe through these" surface. Snaps to each page; the
/// active dot in the indicator widens so position reads at a glance.
class MosaicCarousel extends StatefulWidget {
  const MosaicCarousel({
    super.key,
    required List<Widget> items,
    this.height,
    this.aspectRatio,
    this.viewportFraction = 0.9,
    this.showIndicator = true,
    this.onPageChanged,
    this.initialIndex = 0,
  }) : _items = items,
       _itemCount = null,
       _itemBuilder = null,
       assert(
         height != null || aspectRatio != null,
         'Provide either a height or an aspectRatio',
       );

  const MosaicCarousel.builder({
    super.key,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    this.height,
    this.aspectRatio,
    this.viewportFraction = 0.9,
    this.showIndicator = true,
    this.onPageChanged,
    this.initialIndex = 0,
  }) : _items = null,
       _itemCount = itemCount,
       _itemBuilder = itemBuilder,
       assert(
         height != null || aspectRatio != null,
         'Provide either a height or an aspectRatio',
       );

  final List<Widget>? _items;
  final int? _itemCount;
  final IndexedWidgetBuilder? _itemBuilder;

  /// Pixel height of the carousel. Pass either this or [aspectRatio].
  final double? height;

  /// Aspect ratio (width/height) used to derive height from the
  /// available width. Pass either this or [height].
  final double? aspectRatio;

  /// Fraction of the viewport each page occupies. <1.0 makes the next
  /// page peek in from the right; 1.0 fills the viewport per page.
  final double viewportFraction;

  final bool showIndicator;
  final ValueChanged<int>? onPageChanged;
  final int initialIndex;

  int get itemCount => _itemCount ?? _items!.length;

  Widget _buildItem(BuildContext context, int i) {
    return _itemBuilder != null ? _itemBuilder(context, i) : _items![i];
  }

  @override
  State<MosaicCarousel> createState() => _MosaicCarouselState();
}

class _MosaicCarouselState extends State<MosaicCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    widget.onPageChanged?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final pages = PageView.builder(
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
        child: widget._buildItem(context, i),
      ),
    );
    final body = widget.aspectRatio != null
        ? AspectRatio(aspectRatio: widget.aspectRatio!, child: pages)
        : SizedBox(height: widget.height, child: pages);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        if (widget.showIndicator) ...[
          SizedBox(height: tokens.spacing.sm),
          _Indicator(count: widget.itemCount, active: _index),
        ],
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.count, required this.active});

  static const int _dotThreshold = 10;

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    if (count > _dotThreshold) {
      // Dots stop scaling well past ~10. Fall back to a compact text
      // counter so any item count fits on a phone width.
      return Text(
        '${active + 1} / $count',
        style: tokens.typography.caption.copyWith(
          color: tokens.color.textSecondary,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: tokens.motion.scaledUpdate,
            curve: tokens.motion.standardCurve,
            width: i == active ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == active
                  ? tokens.color.accent
                  : tokens.color.textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(tokens.radius.pill),
            ),
          ),
      ],
    );
  }
}
