import 'package:flutter/foundation.dart';

/// State of a piece of data observed by a Mosaic component.
///
/// Five variants form a sealed hierarchy:
///   * [DataIdle]     — nothing has been requested yet.
///   * [DataLoading]  — a fetch is in flight.
///   * [DataReady]    — a value is available.
///   * [DataEmpty]    — the source produced "no data" (e.g. empty list).
///   * [DataError]    — the last fetch failed.
///
/// Invariants enforced by the live-source adapters:
///   1. Non-initial transitions preserve [lastKnown] so the UI never
///      flickers to a skeleton during a refresh.
///   2. [DataLoading.isInitial] distinguishes first load from refresh.
///   3. [DataReady.isStale] and [DataReady.isUpdating] are independent.
///   4. [DataError] carries [lastKnown] when a refresh fails after a
///      previous success.
@immutable
sealed class DataState<T> {
  const DataState();

  /// The most recent successfully-loaded value, if one is being preserved
  /// across this transition. Null for [DataIdle] and [DataEmpty].
  T? get lastKnown;

  /// True when there is a value to show — either currently ready, or a
  /// preserved [lastKnown] during loading or error.
  bool get hasValue => lastKnown != null;

  /// Pattern match against every variant.
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  });
}

class DataIdle<T> extends DataState<T> {
  const DataIdle();

  @override
  T? get lastKnown => null;

  @override
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  }) => onIdle();

  @override
  bool operator ==(Object other) => other is DataIdle<T>;

  @override
  int get hashCode => (DataIdle<T>).hashCode;

  @override
  String toString() => 'DataIdle<$T>()';
}

class DataLoading<T> extends DataState<T> {
  const DataLoading({this.lastKnown, this.isInitial = false});

  @override
  final T? lastKnown;

  /// True for the very first load. False for refreshes (where a prior
  /// value may live in [lastKnown]).
  final bool isInitial;

  @override
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  }) => onLoading(lastKnown, isInitial);

  @override
  bool operator ==(Object other) =>
      other is DataLoading<T> &&
      other.lastKnown == lastKnown &&
      other.isInitial == isInitial;

  @override
  int get hashCode => Object.hash(DataLoading<T>, lastKnown, isInitial);

  @override
  String toString() =>
      'DataLoading<$T>(isInitial: $isInitial, lastKnown: $lastKnown)';
}

class DataReady<T> extends DataState<T> {
  const DataReady(this.value, {this.isStale = false, this.isUpdating = false});

  final T value;

  /// The value is older than the freshness window. The UI should hint at
  /// staleness (a small dot, dimmed timestamp) without obscuring the
  /// value.
  final bool isStale;

  /// A background refresh is in flight. The current [value] is still the
  /// canonical one to show; the UI may overlay an updating indicator.
  final bool isUpdating;

  @override
  T? get lastKnown => value;

  @override
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  }) => onReady(value, isStale, isUpdating);

  DataReady<T> copyWith({T? value, bool? isStale, bool? isUpdating}) {
    return DataReady<T>(
      value ?? this.value,
      isStale: isStale ?? this.isStale,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DataReady<T> &&
      other.value == value &&
      other.isStale == isStale &&
      other.isUpdating == isUpdating;

  @override
  int get hashCode => Object.hash(DataReady<T>, value, isStale, isUpdating);

  @override
  String toString() =>
      'DataReady<$T>(value: $value, isStale: $isStale, isUpdating: $isUpdating)';
}

class DataEmpty<T> extends DataState<T> {
  const DataEmpty();

  @override
  T? get lastKnown => null;

  @override
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  }) => onEmpty();

  @override
  bool operator ==(Object other) => other is DataEmpty<T>;

  @override
  int get hashCode => (DataEmpty<T>).hashCode;

  @override
  String toString() => 'DataEmpty<$T>()';
}

class DataError<T> extends DataState<T> {
  const DataError(this.error, {this.lastKnown});

  final Object error;

  @override
  final T? lastKnown;

  @override
  R when<R>({
    required R Function() onIdle,
    required R Function(T? lastKnown, bool isInitial) onLoading,
    required R Function(T value, bool isStale, bool isUpdating) onReady,
    required R Function() onEmpty,
    required R Function(Object error, T? lastKnown) onError,
  }) => onError(error, lastKnown);

  @override
  bool operator ==(Object other) =>
      other is DataError<T> &&
      other.error == error &&
      other.lastKnown == lastKnown;

  @override
  int get hashCode => Object.hash(DataError<T>, error, lastKnown);

  @override
  String toString() => 'DataError<$T>(error: $error, lastKnown: $lastKnown)';
}
