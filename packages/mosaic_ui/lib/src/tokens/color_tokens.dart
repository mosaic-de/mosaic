import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class MosaicColorTokens {
  const MosaicColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceActive,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInverse,
    required this.accent,
    required this.error,
    required this.warning,
    required this.success,
    required this.divider,
  });

  final Color background;
  final Color surface;
  final Color surfaceActive;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;
  final Color accent;
  final Color error;
  final Color warning;
  final Color success;
  final Color divider;

  MosaicColorTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceActive,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textInverse,
    Color? accent,
    Color? error,
    Color? warning,
    Color? success,
    Color? divider,
  }) {
    return MosaicColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textInverse: textInverse ?? this.textInverse,
      accent: accent ?? this.accent,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      divider: divider ?? this.divider,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MosaicColorTokens &&
        other.background == background &&
        other.surface == surface &&
        other.surfaceActive == surfaceActive &&
        other.surfaceMuted == surfaceMuted &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textInverse == textInverse &&
        other.accent == accent &&
        other.error == error &&
        other.warning == warning &&
        other.success == success &&
        other.divider == divider;
  }

  @override
  int get hashCode => Object.hash(
    background,
    surface,
    surfaceActive,
    surfaceMuted,
    textPrimary,
    textSecondary,
    textInverse,
    accent,
    error,
    warning,
    success,
    divider,
  );
}
