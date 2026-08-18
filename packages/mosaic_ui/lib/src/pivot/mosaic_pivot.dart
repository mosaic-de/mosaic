import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../theme/mosaic_theme.dart';

/// One section of a [MosaicPivot]. The label appears in the pivot
/// header; the [child] renders when this section is the active page.
@immutable
class MosaicPivotPage {
  const MosaicPivotPage({required this.label, required this.child});

  final String label;
  final Widget child;
}

/// Horizontal context switcher. The Mosaic answer to tabs.
///
/// Mental model: a pivot switches the *lens* on the same surface — not
/// the page. Use it for "today / week / agenda" or "balance / cards /
/// limits" — variations of one thing, not destinations.
///
/// The header lists labels with the active one in `textPrimary` and the
/// rest dimmed to `textSecondary`. Tapping a label or swiping the body
/// horizontally animates between sections using `motion.pivot`.
class MosaicPivot extends StatefulWidget {
  const MosaicPivot({
    super.key,
    required this.pages,
    this.initialIndex = 0,
    this.onIndexChanged,
  }) : assert(pages.length > 0, 'MosaicPivot requires at least one page.'),
       assert(
         initialIndex >= 0 && initialIndex < pages.length,
         'initialIndex out of range.',
       );

  final List<MosaicPivotPage> pages;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<MosaicPivot> createState() => _MosaicPivotState();
}

class _MosaicPivotState extends State<MosaicPivot> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  void _selectIndex(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    widget.onIndexChanged?.call(index);
    final tokens = MosaicTheme.of(context);
    final duration = tokens.motion.scaledPivot;
    if (duration == Duration.zero) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: duration,
        curve: tokens.motion.standardCurve,
      );
    }
  }

  void _onPageChanged(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    widget.onIndexChanged?.call(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PivotHeader(
          pages: widget.pages,
          activeIndex: _index,
          onSelect: _selectIndex,
        ),
        SizedBox(height: tokens.spacing.sm),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.pages.length,
            itemBuilder: (context, i) => widget.pages[i].child,
          ),
        ),
      ],
    );
  }
}

class _PivotHeader extends StatefulWidget {
  const _PivotHeader({
    required this.pages,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<MosaicPivotPage> pages;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_PivotHeader> createState() => _PivotHeaderState();
}

class _PivotHeaderState extends State<_PivotHeader> {
  final ScrollController _controller = ScrollController();
  List<GlobalKey> _keys = const [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  void _syncKeys() {
    if (_keys.length == widget.pages.length) return;
    _keys = List<GlobalKey>.generate(
      widget.pages.length,
      (_) => GlobalKey(),
      growable: false,
    );
  }

  @override
  void didUpdateWidget(_PivotHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    if (widget.activeIndex != oldWidget.activeIndex) _revealActive();
  }

  /// Scroll the active label to the leading edge.
  ///
  /// Without this the header is a scroll view nobody ever scrolls: the
  /// labels are laid out left to right and the strip stays at offset
  /// zero, so on a narrow phone swiping to a later page leaves that
  /// page's own title off-screen — the one word the user most needs.
  ///
  /// Leading edge rather than centred because that is the panorama
  /// idiom this header is drawn from: the current title sits at the
  /// margin with the next one peeking in from the right.
  ///
  /// Deferred to the end of frame because the active label animates
  /// between two type styles; measuring during this build would use the
  /// widths the labels are moving away from.
  void _revealActive() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final index = widget.activeIndex;
      if (index < 0 || index >= _keys.length) return;
      final target = _keys[index].currentContext;
      if (target == null) return;
      final tokens = MosaicTheme.of(context);
      final duration = tokens.motion.scaledPivot;
      if (duration == Duration.zero) {
        // Tests and reduced-motion run at scale zero, where an animated
        // scroll would never settle.
        Scrollable.ensureVisible(target, alignment: 0);
      } else {
        Scrollable.ensureVisible(
          target,
          alignment: 0,
          duration: duration,
          curve: tokens.motion.standardCurve,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < widget.pages.length; i++) ...[
            if (i > 0) SizedBox(width: tokens.spacing.md),
            MosaicPressFeedback(
              key: _keys[i],
              onPressed: () => widget.onSelect(i),
              semanticLabel: widget.pages[i].label,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
                child: AnimatedDefaultTextStyle(
                  duration: tokens.motion.scaledPivot,
                  curve: tokens.motion.standardCurve,
                  style: i == widget.activeIndex
                      ? tokens.typography.headline.copyWith(
                          color: tokens.color.textPrimary,
                        )
                      : tokens.typography.title.copyWith(
                          color: tokens.color.textSecondary.withValues(
                            alpha: 0.55,
                          ),
                        ),
                  child: Text(widget.pages[i].label),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
