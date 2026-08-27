// services.dart re-exports Brightness and Color alongside
// SystemUiOverlayStyle, so it covers this file on its own.
import 'package:flutter/services.dart';

/// What the user asked for, which is not the same thing as what gets
/// rendered — [MosaicBrightnessChoice.system] resolves to whichever
/// brightness the device is currently in, and keeps resolving as that
/// changes.
///
/// This lives here because eleven apps had byte-identical copies of it.
/// Two of them left opposing comments about whether it belonged in the
/// design system: one argued the natural home was `mosaic_ui`, the other
/// that lifting it would push a storage concern into a component
/// library. The second is mistaken about this file — there is no storage
/// in it. Persistence stays in each app, where it differs; the enum and
/// the two pure functions do not differ and should not be copied.
///
/// Named `MosaicBrightnessChoice`, not `ThemeChoice`, because the
/// launcher already owns that name for something unrelated — its Lumia
/// accent-colour picker. Two meanings behind one identifier is how a
/// migration goes wrong quietly.
enum MosaicBrightnessChoice {
  system,
  dark,
  light;

  String get label => switch (this) {
    MosaicBrightnessChoice.system => 'System',
    MosaicBrightnessChoice.dark => 'Dark',
    MosaicBrightnessChoice.light => 'Light',
  };

  static MosaicBrightnessChoice fromName(String? raw) =>
      MosaicBrightnessChoice.values.firstWhere(
        (choice) => choice.name == raw,
        orElse: () => MosaicBrightnessChoice.system,
      );
}

/// The brightness to actually render.
///
/// [platformBrightness] is consulted only for
/// [MosaicBrightnessChoice.system]. The explicit options ignore it
/// outright — that is the whole point of offering them, and an override
/// that quietly deferred to the device at sunset would be worse than
/// having no override at all.
Brightness resolveMosaicBrightness(
  MosaicBrightnessChoice choice,
  Brightness platformBrightness,
) => switch (choice) {
  MosaicBrightnessChoice.system => platformBrightness,
  MosaicBrightnessChoice.dark => Brightness.dark,
  MosaicBrightnessChoice.light => Brightness.light,
};

/// System-bar styling for a resolved [brightness].
///
/// Icon brightness is the *opposite* of the background: dark UI needs
/// light icons, light UI needs dark ones. Hardcoding either way is how
/// the launcher ended up painting white status-bar icons on its white
/// light-mode background, hiding the clock, battery and signal.
SystemUiOverlayStyle mosaicSystemBarsFor(Brightness brightness) {
  final iconBrightness = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: const Color(0x00000000),
    statusBarIconBrightness: iconBrightness,
    // iOS reads statusBarBrightness and inverts it itself, so it takes
    // the background's brightness rather than the icons'.
    statusBarBrightness: brightness,
    systemNavigationBarColor: const Color(0x00000000),
    systemNavigationBarIconBrightness: iconBrightness,
    systemNavigationBarContrastEnforced: false,
  );
}
