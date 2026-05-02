# Lock Screen and Ambient Components

Mosaic should support lock-screen style surfaces even where platforms do not allow replacing the real lock screen.

## Components

```text
MosaicLockScreen
MosaicLockClock
MosaicLockDate
MosaicLockStatusRow
MosaicLockNotificationStack
MosaicLockNotificationCard
MosaicLockQuickAction
MosaicLockMediaControls
MosaicLockCalendarPreview
MosaicLockWalletPreview
MosaicLockWeatherTile
MosaicBiometricPrompt
MosaicPinPad
MosaicUnlockGesture
MosaicAmbientSurface
MosaicAlwaysOnView
```

## Platform Reality

```text
Android: launcher and lock-screen-like experiences are possible with constraints.
Linux: full shell and lock screen are possible.
iOS: real lock screen replacement is not allowed for normal apps.
```

## iOS Strategy

Use:

```text
Mosaic apps
Mosaic widgets
Live Activities
App Intents
Notifications
Lock-screen-style previews where allowed
```

## Design Rule

Lock surfaces must be glanceable and minimal. They should not become a second home screen.
