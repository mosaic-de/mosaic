import 'package:flutter/widgets.dart';
import 'package:mosaic_ui/mosaic_ui.dart';

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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
                child: Column(
                  children: [
                    _Header(
                      mode: _mode,
                      onToggleMode: () => setState(
                        () => _mode = _mode == MosaicMode.metro
                            ? MosaicMode.modern
                            : MosaicMode.metro,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.md),
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
                            InsightTile(weeklySpend: widget.data.weeklySpend),
                          ],
                        ),
                      ),
                    ),
                  ],
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
