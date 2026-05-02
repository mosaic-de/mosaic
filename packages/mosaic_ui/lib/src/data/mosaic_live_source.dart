import 'dart:async';

import 'package:flutter/foundation.dart';

import 'data_state.dart';

/// A source of [DataState] updates for a Mosaic component.
///
/// The boundary between Mosaic and the consumer's state-management
/// library: hand over a stream, future, or [ValueListenable] and Mosaic
/// produces a [DataState] timeline that preserves the spec invariants
/// (last-known value, stale, updating, error fallback).
abstract class MosaicLiveSource<T> {
  /// Adapt a [Stream] of values into a [MosaicLiveSource].
  ///
  /// Emits [DataLoading] (initial) until the first value, then
  /// [DataReady] on each emission. Errors become [DataError] with the
  /// previous value preserved as `lastKnown`. If [initialValue] is
  /// provided, the source starts in [DataReady] instead of loading.
  ///
  /// If [isEmpty] returns true for a value, the source emits [DataEmpty]
  /// instead of [DataReady]. If the stream completes before emitting
  /// anything, the source transitions to [DataEmpty].
  factory MosaicLiveSource.fromStream(
    Stream<T> source, {
    T? initialValue,
    bool Function(T value)? isEmpty,
  }) => _StreamLiveSource<T>(
    source,
    initialValue: initialValue,
    isEmpty: isEmpty,
  );

  /// Adapt a fetch function into a [MosaicLiveSource].
  ///
  /// Calls [fetch] immediately. If [interval] is non-null, schedules
  /// follow-up fetches after each completion. Refresh fetches transition
  /// through `DataReady(lastKnown, isUpdating: true)` so the previous
  /// value remains visible while the new one loads.
  factory MosaicLiveSource.fromFuture(
    Future<T> Function() fetch, {
    Duration? interval,
    bool Function(T value)? isEmpty,
  }) => _FutureLiveSource<T>(fetch, interval: interval, isEmpty: isEmpty);

  /// Adapt a [ValueListenable] into a [MosaicLiveSource]. Bridges
  /// Riverpod, Provider, and any ChangeNotifier-based state into
  /// [DataState] semantics. Always starts in [DataReady] (or
  /// [DataEmpty] if [isEmpty] is true for the initial value).
  factory MosaicLiveSource.fromListenable(
    ValueListenable<T> listenable, {
    bool Function(T value)? isEmpty,
  }) => _ListenableLiveSource<T>(listenable, isEmpty: isEmpty);

  /// A constant source that emits [DataReady] once and never changes.
  factory MosaicLiveSource.static(T value) = _StaticLiveSource<T>;

  /// A constant source that emits [DataEmpty] once and never changes.
  factory MosaicLiveSource.empty() = _EmptyLiveSource<T>;

  /// Snapshot of the current state. Useful for synchronous reads in
  /// builders and tests.
  DataState<T> get current;

  /// Stream of state updates. Each new subscriber receives [current] as
  /// the first event, then any subsequent transitions.
  Stream<DataState<T>> get states;

  /// Release any underlying resources (timers, stream subscriptions,
  /// listener registrations).
  void dispose();
}

/// Shared multicast scaffolding for the built-in adapters.
abstract class _MulticastLiveSource<T> implements MosaicLiveSource<T> {
  _MulticastLiveSource(DataState<T> initial) : _current = initial;

  DataState<T> _current;
  final StreamController<DataState<T>> _controller =
      StreamController<DataState<T>>.broadcast(sync: true);

  @override
  DataState<T> get current => _current;

  bool get _isClosed => _controller.isClosed;

  @override
  Stream<DataState<T>> get states {
    late StreamController<DataState<T>> ctrl;
    StreamSubscription<DataState<T>>? sub;
    ctrl = StreamController<DataState<T>>(
      onListen: () {
        ctrl.add(_current);
        if (!_isClosed) {
          sub = _controller.stream.listen(
            ctrl.add,
            onError: ctrl.addError,
            onDone: ctrl.close,
          );
        } else {
          ctrl.close();
        }
      },
      onCancel: () => sub?.cancel(),
    );
    return ctrl.stream;
  }

  @protected
  void emit(DataState<T> next) {
    if (_isClosed) return;
    _current = next;
    _controller.add(next);
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_isClosed) return;
    _controller.close();
  }
}

class _StreamLiveSource<T> extends _MulticastLiveSource<T> {
  _StreamLiveSource(this._source, {this.initialValue, this.isEmpty})
    : super(
        initialValue == null
            ? DataLoading<T>(isInitial: true)
            : DataReady<T>(initialValue),
      ) {
    _sub = _source.listen(_onValue, onError: _onError, onDone: _onDone);
  }

  final Stream<T> _source;
  final T? initialValue;
  final bool Function(T value)? isEmpty;
  late final StreamSubscription<T> _sub;

  void _onValue(T value) {
    if (isEmpty?.call(value) ?? false) {
      emit(DataEmpty<T>());
    } else {
      emit(DataReady<T>(value));
    }
  }

  void _onError(Object error) {
    emit(DataError<T>(error, lastKnown: _current.lastKnown));
  }

  void _onDone() {
    if (_current is DataLoading<T>) {
      emit(DataEmpty<T>());
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _FutureLiveSource<T> extends _MulticastLiveSource<T> {
  _FutureLiveSource(this._fetch, {this.interval, this.isEmpty})
    : super(DataLoading<T>(isInitial: true)) {
    unawaited(_runFetch());
  }

  final Future<T> Function() _fetch;
  final Duration? interval;
  final bool Function(T value)? isEmpty;
  Timer? _timer;

  Future<void> _runFetch() async {
    final lastKnown = _current.lastKnown;
    if (lastKnown != null) {
      emit(DataReady<T>(lastKnown, isUpdating: true));
    }
    try {
      final value = await _fetch();
      if (_isClosed) return;
      if (isEmpty?.call(value) ?? false) {
        emit(DataEmpty<T>());
      } else {
        emit(DataReady<T>(value));
      }
    } catch (error) {
      if (_isClosed) return;
      emit(DataError<T>(error, lastKnown: _current.lastKnown));
    }
    if (interval != null && !_isClosed) {
      _timer = Timer(interval!, () => unawaited(_runFetch()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _ListenableLiveSource<T> extends _MulticastLiveSource<T> {
  _ListenableLiveSource(this._listenable, {this.isEmpty})
    : super(_initialFor(_listenable, isEmpty)) {
    _listenable.addListener(_onChange);
  }

  final ValueListenable<T> _listenable;
  final bool Function(T value)? isEmpty;

  static DataState<U> _initialFor<U>(
    ValueListenable<U> listenable,
    bool Function(U value)? isEmpty,
  ) {
    final value = listenable.value;
    if (isEmpty?.call(value) ?? false) {
      return DataEmpty<U>();
    }
    return DataReady<U>(value);
  }

  void _onChange() {
    final value = _listenable.value;
    if (isEmpty?.call(value) ?? false) {
      emit(DataEmpty<T>());
    } else {
      emit(DataReady<T>(value));
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_onChange);
    super.dispose();
  }
}

class _StaticLiveSource<T> extends _MulticastLiveSource<T> {
  _StaticLiveSource(T value) : super(DataReady<T>(value));
}

class _EmptyLiveSource<T> extends _MulticastLiveSource<T> {
  _EmptyLiveSource() : super(DataEmpty<T>());
}
