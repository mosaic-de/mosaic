import 'package:flutter/widgets.dart';

import '../button/mosaic_button.dart';
import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_panel.dart';
import '../surface/mosaic_surface_host.dart';
import '../theme/mosaic_theme.dart';

/// One step in a [MosaicWalkthrough].
@immutable
class MosaicWalkthroughStep {
  const MosaicWalkthroughStep({
    required this.title,
    required this.body,
    this.glyph,
  });

  final String title;
  final String body;

  /// Optional large glyph rendered above the title — usually an emoji
  /// or a single character for quick visual identification.
  final String? glyph;
}

/// First-run / feature-tour pattern. Pushes a full-bleed panel onto
/// the surrounding [MosaicSurfaceHost]'s stack, with a swipeable
/// PageView of [MosaicWalkthroughStep]s.
///
/// Bottom bar holds Skip on the left, page dots in the center, and
/// Next or Done (last step) on the right. Both Skip and Done call
/// [onComplete] (or [onSkip] for skip) and pop the panel.
class MosaicWalkthrough extends StatelessWidget {
  const MosaicWalkthrough({super.key});

  /// Push a walkthrough onto the nearest surface stack.
  static void show(
    BuildContext context, {
    required List<MosaicWalkthroughStep> steps,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) {
    assert(steps.isNotEmpty, 'walkthrough must have at least one step');
    MosaicSurfaceScope.of(context).push(
      (panelContext) => _WalkthroughPanel(
        steps: steps,
        onComplete: () {
          onComplete?.call();
          MosaicSurfaceScope.of(panelContext).pop();
        },
        onSkip: () {
          onSkip?.call();
          MosaicSurfaceScope.of(panelContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _WalkthroughPanel extends StatefulWidget {
  const _WalkthroughPanel({
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  final List<MosaicWalkthroughStep> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  State<_WalkthroughPanel> createState() => _WalkthroughPanelState();
}

class _WalkthroughPanelState extends State<_WalkthroughPanel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == widget.steps.length - 1;

  void _next() {
    if (_isLast) {
      widget.onComplete();
      return;
    }
    final tokens = MosaicTheme.of(context);
    final duration = tokens.motion.scaledPivot;
    if (duration == Duration.zero) {
      _controller.jumpToPage(_index + 1);
    } else {
      _controller.animateToPage(
        _index + 1,
        duration: duration,
        curve: tokens.motion.standardCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicPanel(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: widget.steps.length,
              itemBuilder: (context, i) => _StepView(step: widget.steps[i]),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Row(
            children: [
              if (!_isLast)
                MosaicPressFeedback(
                  onPressed: widget.onSkip,
                  semanticLabel: 'Skip',
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    child: Text(
                      'Skip',
                      style: tokens.typography.tileTitle.copyWith(
                        color: tokens.color.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              const Spacer(),
              _Dots(count: widget.steps.length, active: _index),
              const Spacer(),
              SizedBox(
                width: 96,
                child: MosaicButton(
                  label: _isLast ? 'Done' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final MosaicWalkthroughStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (step.glyph != null) ...[
            Text(
              step.glyph!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 96,
                color: tokens.color.accent,
                height: 1,
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
          ],
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: tokens.typography.headline.copyWith(
              color: tokens.color.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: tokens.typography.body.copyWith(
              color: tokens.color.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
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
