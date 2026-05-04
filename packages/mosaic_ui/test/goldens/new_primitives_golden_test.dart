@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('text variants stack', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'text_variants',
      size: const Size(360, 320),
      builder: (tokens) => Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MosaicText.display('Display'),
            MosaicText.headline('Headline'),
            MosaicText.title('Title'),
            MosaicText.body('Body copy'),
            MosaicText.caption('Caption'),
            MosaicText.metric('123,456'),
          ],
        ),
      ),
    );
  });

  testWidgets('divider — horizontal between rows', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'divider',
      size: const Size(320, 100),
      builder: (tokens) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MosaicText.body('Above'),
            SizedBox(height: 8),
            MosaicDivider(),
            SizedBox(height: 8),
            MosaicText.body('Below'),
          ],
        ),
      ),
    );
  });

  testWidgets('avatars — initials and shapes', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'avatar_row',
      size: const Size(360, 100),
      builder: (tokens) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MosaicAvatar(name: 'John Simiyu', size: MosaicAvatarSize.lg),
          SizedBox(width: tokens.spacing.md),
          const MosaicAvatar(
            name: 'Cher',
            shape: MosaicAvatarShape.circle,
            size: MosaicAvatarSize.lg,
          ),
          SizedBox(width: tokens.spacing.md),
          const MosaicAvatar(name: 'Mosaic Org', size: MosaicAvatarSize.md),
        ],
      ),
    );
  });

  testWidgets('badges — tones and dot', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'badge_row',
      size: const Size(360, 80),
      builder: (tokens) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MosaicBadge(label: 'NEW'),
          SizedBox(width: tokens.spacing.sm),
          const MosaicBadge(label: '3', tone: MosaicBadgeTone.error),
          SizedBox(width: tokens.spacing.sm),
          const MosaicBadge(label: 'ok', tone: MosaicBadgeTone.success),
          SizedBox(width: tokens.spacing.md),
          const MosaicBadge.dot(),
        ],
      ),
    );
  });

  testWidgets('progress bar at three values', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'progress_bar',
      size: const Size(320, 80),
      builder: (tokens) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MosaicProgressBar(value: 0.2),
            SizedBox(height: 8),
            MosaicProgressBar(value: 0.5),
            SizedBox(height: 8),
            MosaicProgressBar(value: 0.85),
          ],
        ),
      ),
    );
  });

  testWidgets('empty state with action', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'empty_state',
      size: const Size(400, 440),
      builder: (tokens) => SizedBox(
        width: 360,
        height: 400,
        child: MosaicPanel(
          child: MosaicEmptyState(
            title: 'No transactions yet',
            body: 'Once you send or receive, history shows up here.',
            glyph: '◌',
            actionLabel: 'Send',
            onAction: () {},
          ),
        ),
      ),
    );
  });

  testWidgets('error state with retry', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'error_state',
      size: const Size(400, 440),
      builder: (tokens) => SizedBox(
        width: 360,
        height: 400,
        child: MosaicPanel(
          child: MosaicErrorState(
            body: 'Could not reach the network. Check your connection.',
            onRetry: () {},
          ),
        ),
      ),
    );
  });

  testWidgets('inline error beneath an input', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'inline_error',
      size: const Size(320, 100),
      builder: (tokens) => SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MosaicInput(placeholder: 'Email'),
            SizedBox(height: tokens.spacing.xs),
            const MosaicInlineError("That doesn't look like a valid email."),
          ],
        ),
      ),
    );
  });

  testWidgets('status bar — title + caption + trailing', (tester) async {
    await runGoldenMatrix(
      tester,
      name: 'status_bar',
      size: const Size(360, 120),
      builder: (tokens) => const SizedBox(
        width: 360,
        child: MosaicStatusBar(
          title: 'Mosaic',
          caption: 'jonny',
          trailing: MosaicAvatar(name: 'JS'),
        ),
      ),
    );
  });
}
