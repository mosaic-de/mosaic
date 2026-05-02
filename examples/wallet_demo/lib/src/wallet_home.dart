import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import 'format.dart';
import 'wallet_data.dart';
import 'wallet_tiles.dart';

class WalletHome extends StatelessWidget {
  const WalletHome({super.key, required this.data});

  final WalletData data;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: MosaicSurfaceHost(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
              child: Column(
                children: [
                  Expanded(
                    child: MosaicPivot(
                      pages: [
                        MosaicPivotPage(
                          label: 'Overview',
                          child: _OverviewPage(data: data),
                        ),
                        MosaicPivotPage(
                          label: 'Activity',
                          child: _ActivityPage(transactions: data.transactions),
                        ),
                        MosaicPivotPage(
                          label: 'Cards',
                          child: _CardsPage(cards: data.cards),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  const _HomeCommandBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({required this.data});

  final WalletData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MosaicGrid(
        children: <MosaicTileWidget>[
          BalanceTile(balance: data.balance, weeklySpend: data.weeklySpend),
          ActionTile(label: 'Send', glyph: '↗', onPressed: () {}),
          ActionTile(label: 'Pay', glyph: '◇', onPressed: () {}),
          CardsTile(cards: data.cards),
          InsightTile(weeklySpend: data.weeklySpend),
        ],
      ),
    );
  }
}

class _ActivityPage extends StatelessWidget {
  const _ActivityPage({required this.transactions});

  final ValueListenable<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return ValueListenableBuilder<List<Transaction>>(
      valueListenable: transactions,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No transactions yet',
              style: tokens.typography.body.copyWith(
                color: tokens.color.textSecondary,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
          itemCount: list.length,
          separatorBuilder: (_, __) => Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
            child: Container(height: 1, color: tokens.color.divider),
          ),
          itemBuilder: (context, i) {
            final tx = list[i];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.label,
                          style: tokens.typography.body.copyWith(
                            color: tokens.color.textPrimary,
                          ),
                        ),
                        Text(
                          formatRelative(tx.when),
                          style: tokens.typography.caption.copyWith(
                            color: tokens.color.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCents(tx.amount, withSign: true),
                    style: tokens.typography.body.copyWith(
                      color: tx.amount < 0
                          ? tokens.color.textPrimary
                          : tokens.color.success,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CardsPage extends StatelessWidget {
  const _CardsPage({required this.cards});

  final ValueListenable<List<WalletCard>> cards;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return ValueListenableBuilder<List<WalletCard>>(
      valueListenable: cards,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No cards',
              style: tokens.typography.body.copyWith(
                color: tokens.color.textSecondary,
              ),
            ),
          );
        }
        final palette = <Color>[
          tokens.color.accent,
          tokens.color.warning,
          tokens.color.success,
          tokens.color.error,
        ];
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(height: tokens.spacing.md),
          itemBuilder: (context, i) =>
              _PaymentCard(card: list[i], color: palette[i % palette.length]),
        );
      },
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.card, required this.color});

  final WalletCard card;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final ink = tokens.color.textInverse;
    return AspectRatio(
      aspectRatio: 1.586,
      child: MosaicSurface(
        kind: MosaicSurfaceKind.panel,
        color: color,
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.label,
                  style: tokens.typography.title.copyWith(color: ink),
                ),
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ink.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '••••  ••••  ••••  ${card.lastFour}',
              style: tokens.typography.metric.copyWith(
                color: ink,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCents(card.spent)} · ${formatCents(card.limit)}',
                  style: tokens.typography.caption.copyWith(
                    color: ink.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  '${(card.utilization * 100).round()}%',
                  style: tokens.typography.caption.copyWith(color: ink),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radius.pill),
              child: SizedBox(
                height: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ColoredBox(
                          color: ink.withValues(alpha: 0.2),
                          child: const SizedBox.expand(),
                        ),
                        SizedBox(
                          width: constraints.maxWidth * card.utilization,
                          child: ColoredBox(color: ink),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCommandBar extends StatelessWidget {
  const _HomeCommandBar();

  @override
  Widget build(BuildContext context) {
    final scope = MosaicAppScope.of(context);
    return MosaicCommandBar(
      commands: [
        MosaicCommand(
          label: scope.mode == MosaicMode.metro ? 'modern' : 'metro',
          glyph: '◐',
          onPressed: scope.toggleMode,
        ),
        MosaicCommand(
          label: scope.brightness == Brightness.dark ? 'light' : 'dark',
          glyph: '☀',
          onPressed: scope.toggleBrightness,
        ),
        MosaicCommand(label: 'settings', glyph: '⚙', onPressed: () {}),
      ],
    );
  }
}
