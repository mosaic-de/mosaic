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

class _PivotHeader extends StatelessWidget {
  const _PivotHeader({
    required this.pages,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<MosaicPivotPage> pages;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < pages.length; i++) ...[
            if (i > 0) SizedBox(width: tokens.spacing.md),
            MosaicPressFeedback(
              onPressed: () => onSelect(i),
              semanticLabel: pages[i].label,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
                child: AnimatedDefaultTextStyle(
                  duration: tokens.motion.scaledPivot,
                  curve: tokens.motion.standardCurve,
                  style: i == activeIndex
                      ? tokens.typography.headline.copyWith(
                          color: tokens.color.textPrimary,
                        )
                      : tokens.typography.title.copyWith(
                          color: tokens.color.textSecondary.withValues(
                            alpha: 0.55,
                          ),
                        ),
                  child: Text(pages[i].label),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
