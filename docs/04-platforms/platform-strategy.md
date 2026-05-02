# Platform Strategy

Mosaic is Flutter-first, but Flutter alone is not enough. Native bridges are required.

## Capability Tiers

```text
Tier 1: Flutter components everywhere
Tier 2: Native integrations per platform
Tier 3: Shell-level control where the OS allows it
Tier 4: Experimental OS targets
```

## Android

```text
launcher
widgets/live tiles
contacts
SMS/MMS where allowed
dialer integration
notifications
background services
file providers
permissions
accessibility
```

## iOS

iOS cannot replace the real launcher or lock screen.

Use:

```text
Mosaic UI kit
Mosaic apps
widgets
Live Activities
App Intents / Shortcuts
notifications
contacts
calendar
files/document picker
keychain/biometrics
```

## Linux

```text
Wayland shell hooks
notifications
power/battery
network
Bluetooth
audio
file manager
Waydroid integration
```

## Fuchsia Future Target

Fuchsia is experimental and should come after product traction.

Potential bridge:

```text
mosaic_native_fuchsia
  component lifecycle
  permissions/capabilities
  notifications
  storage
  input
  system surfaces
```

## Priority

```text
1. Flutter design system
2. Tile system
3. Launcher
4. Android native bridge
5. Core apps
6. Linux shell
7. iOS app/widget support
8. Fuchsia experiment
```
