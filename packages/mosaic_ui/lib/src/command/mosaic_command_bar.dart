import 'package:flutter/widgets.dart';

import '../press/mosaic_press_feedback.dart';
import '../surface/mosaic_surface.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';

/// A single contextual action shown in a [MosaicCommandBar].
///
/// Commands are not toolbar buttons — they are the contextual verbs that
/// belong to the surface they sit on. Keep labels short.
@immutable
class MosaicCommand {
  const MosaicCommand({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;

  /// Optional single-character or short glyph rendered above the label.
  final String? glyph;

  final bool enabled;
}

/// Horizontal row of contextual actions for a Mosaic surface.
///
/// Renders below the surface body by convention. Spacing and feedback
/// pull from tokens; nothing is hardcoded.
class MosaicCommandBar extends StatelessWidget {
  const MosaicCommandBar({super.key, required this.commands, this.padding});

  final List<MosaicCommand> commands;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicSurface(
      kind: MosaicSurfaceKind.muted,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final command in commands)
            Expanded(child: _CommandButton(command: command)),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  const _CommandButton({required this.command});

  final MosaicCommand command;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return MosaicPressFeedback(
      onPressed: command.onPressed,
      enabled: command.enabled,
      semanticLabel: command.label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (command.glyph != null) ...[
              Text(
                command.glyph!,
                style: tokens.typography.title.copyWith(
                  color: tokens.color.accent,
                ),
              ),
              SizedBox(height: tokens.spacing.xs),
            ],
            Text(
              command.label,
              style: tokens.typography.tileTitle.copyWith(
                color: tokens.color.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
