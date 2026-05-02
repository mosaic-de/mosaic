import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

import 'format.dart';
import 'wallet_data.dart';
import 'wallet_tiles.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({super.key, required this.data});

  final WalletData data;

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  MosaicMode _mode = MosaicMode.metro;

  void _toggleMode() {
    setState(
      () => _mode = _mode == MosaicMode.metro
          ? MosaicMode.modern
          : MosaicMode.metro,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _mode == MosaicMode.metro
        ? MosaicTokens.metro()
        : MosaicTokens.modern();
    return MosaicTheme(
      tokens: tokens,
      child: Builder(
        builder: (context) {
          final tokens = MosaicTheme.of(context);
          return ColoredBox(
            color: tokens.color.background,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: MosaicSurfaceHost(
                    body: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.md,
                      ),
                      child: Column(
                        children: [
                          _Header(mode: _mode, onToggleMode: _toggleMode),
                          Expanded(
                            child: SingleChildScrollView(
                              child: MosaicGrid(
                                children: <MosaicTileWidget>[
                                  BalanceTile(
                                    balance: widget.data.balance,
                                    weeklySpend: widget.data.weeklySpend,
                                  ),
                                  ActionTile(
                                    label: 'Send',
                                    glyph: '↗',
                                    onPressed: () {},
                                  ),
                                  ActionTile(
                                    label: 'Pay',
                                    glyph: '◇',
                                    onPressed: () {},
                                  ),
                                  TransactionsTile(
                                    transactions: widget.data.transactions,
                                  ),
                                  CardsTile(cards: widget.data.cards),
                                  InsightTile(
                                    weeklySpend: widget.data.weeklySpend,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: tokens.spacing.sm),
                          _HomeCommandBar(
                            transactions: widget.data.transactions,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mode, required this.onToggleMode});

  final MosaicMode mode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet',
                  style: tokens.typography.headline.copyWith(
                    color: tokens.color.textPrimary,
                  ),
                ),
                Text(
                  mode == MosaicMode.metro ? 'metro' : 'modern',
                  style: tokens.typography.caption.copyWith(
                    color: tokens.color.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          MosaicPressFeedback(
            onPressed: onToggleMode,
            semanticLabel: 'Toggle design mode',
            child: MosaicSurface(
              kind: MosaicSurfaceKind.muted,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.md,
                vertical: tokens.spacing.sm,
              ),
              child: Text(
                mode == MosaicMode.metro ? '→ modern' : '→ metro',
                style: tokens.typography.tileTitle.copyWith(
                  color: tokens.color.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCommandBar extends StatelessWidget {
  const _HomeCommandBar({required this.transactions});

  final ValueListenable<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final scope = MosaicSurfaceScope.of(context);
        return MosaicCommandBar(
          commands: [
            MosaicCommand(
              label: 'All',
              glyph: '≡',
              onPressed: () {
                scope.push(
                  (context) => _TransactionsPanel(transactions: transactions),
                );
              },
            ),
            MosaicCommand(label: 'Search', glyph: '⌕', onPressed: () {}),
            MosaicCommand(label: 'Settings', glyph: '⚙', onPressed: () {}),
          ],
        );
      },
    );
  }
}

class _TransactionsPanel extends StatelessWidget {
  const _TransactionsPanel({required this.transactions});

  final ValueListenable<List<Transaction>> transactions;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    final scope = MosaicSurfaceScope.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.md,
      ),
      child: MosaicPanel(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MosaicPressFeedback(
                  onPressed: scope.pop,
                  semanticLabel: 'Collapse panel',
                  child: MosaicSurface(
                    kind: MosaicSurfaceKind.muted,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.xs,
                    ),
                    child: Text(
                      '←',
                      style: tokens.typography.title.copyWith(
                        color: tokens.color.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Text(
                    'All transactions',
                    style: tokens.typography.title.copyWith(
                      color: tokens.color.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            Flexible(
              child: ValueListenableBuilder<List<Transaction>>(
                valueListenable: transactions,
                builder: (context, list, _) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(tokens.spacing.lg),
                      child: Text(
                        'No transactions yet',
                        style: tokens.typography.body.copyWith(
                          color: tokens.color.textSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: tokens.spacing.xs,
                      ),
                      child: Container(height: 1, color: tokens.color.divider),
                    ),
                    itemBuilder: (context, i) {
                      final tx = list[i];
                      return Row(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
