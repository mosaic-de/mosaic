import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/data_state.dart';
import '../data/mosaic_live_source.dart';
import '../motion/mosaic_state_switcher.dart';
import '../surface/mosaic_surface_kind.dart';
import '../theme/mosaic_theme.dart';
import 'mosaic_tile.dart';
import 'mosaic_tile_size.dart';
import 'mosaic_tile_widget.dart';

typedef MosaicTileBuilder<T> =
    Widget Function(BuildContext context, T value, DataState<T> state);

typedef MosaicErrorBuilder =
    Widget Function(BuildContext context, Object error);

/// Tile bound to a [MosaicLiveSource]. Subscribes to state updates and
/// chooses the right body to show.
///
/// Display priority follows the spec contract: if the current state has
/// a `lastKnown` value, render via [tileBuilder] regardless of whether
/// the underlying state is ready, loading-with-prior, or error-with-prior.
/// Only when there is no value does the tile fall back to a loading,
/// empty, or error skeleton.
class MosaicLiveTile<T> extends StatefulWidget implements MosaicTileWidget {
  const MosaicLiveTile({
    super.key,
    required this.size,
    required this.source,
    required this.tileBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.kind = MosaicSurfaceKind.tile,
    this.padding,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  final MosaicTileSize size;

  final MosaicLiveSource<T> source;
  final MosaicTileBuilder<T> tileBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final MosaicErrorBuilder? errorBuilder;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final MosaicSurfaceKind kind;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  State<MosaicLiveTile<T>> createState() => _MosaicLiveTileState<T>();
}

class _MosaicLiveTileState<T> extends State<MosaicLiveTile<T>> {
  late StreamSubscription<DataState<T>> _sub;
  late DataState<T> _state;

  @override
  void initState() {
    super.initState();
    _state = widget.source.current;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant MosaicLiveTile<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.source, widget.source)) {
      _sub.cancel();
      _state = widget.source.current;
      _subscribe();
    }
  }

  void _subscribe() {
    _sub = widget.source.states.listen((next) {
      if (mounted) setState(() => _state = next);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MosaicTile(
      size: widget.size,
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
      enabled: widget.enabled,
      kind: widget.kind,
      padding: widget.padding,
      semanticLabel: widget.semanticLabel,
      semanticHint: widget.semanticHint,
      child: MosaicStateSwitcher(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = _state;
    final lastKnown = state.lastKnown;
    if (lastKnown != null) {
      return KeyedSubtree(
        key: const ValueKey<String>('mosaic.tile.value'),
        child: widget.tileBuilder(context, lastKnown, state),
      );
    }
    return state.when(
      onIdle: () => KeyedSubtree(
        key: const ValueKey<String>('mosaic.tile.loading'),
        child: _loading(context),
      ),
      onLoading: (_, __) => KeyedSubtree(
        key: const ValueKey<String>('mosaic.tile.loading'),
        child: _loading(context),
      ),
      onReady: (_, __, ___) => const SizedBox.shrink(),
      onEmpty: () => KeyedSubtree(
        key: const ValueKey<String>('mosaic.tile.empty'),
        child: _empty(context),
      ),
      onError: (error, _) => KeyedSubtree(
        key: const ValueKey<String>('mosaic.tile.error'),
        child: _error(context, error),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return widget.loadingBuilder?.call(context) ?? const _LoadingBody();
  }

  Widget _empty(BuildContext context) {
    return widget.emptyBuilder?.call(context) ?? const _EmptyBody();
  }

  Widget _error(BuildContext context, Object error) {
    return widget.errorBuilder?.call(context, error) ??
        _ErrorBody(error: error);
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Center(
      child: Container(
        width: tokens.spacing.lg,
        height: tokens.spacing.xs,
        decoration: BoxDecoration(
          color: tokens.color.textSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(tokens.radius.pill),
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Center(
      child: Text(
        '—',
        style: tokens.typography.tileSubtitle.copyWith(
          color: tokens.color.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final tokens = MosaicTheme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xs),
        child: Text(
          '!',
          style: tokens.typography.metric.copyWith(color: tokens.color.error),
        ),
      ),
    );
  }
}
