# Core App Patterns

Mosaic must support a complete basic app ecosystem, not only a launcher.

## Core App Families

```text
People: Contacts, Phone, SMS
Time: Calendar, Clock, Tasks
Files: Folders, Documents, Photos
System: Settings, Notifications, App List
Utility: Calculator, Notes, Recorder
Commerce: Wallet, Payments, Cards
```

## Pattern: SMS

```text
SMS Live Tile
  shows unread count + latest sender
  ↓ tap
Messages Surface
  chats | calls | favorites pivot
  ↓ open chat
Conversation Surface
  message bubbles + command bar
```

## Pattern: Calendar

```text
Calendar Live Tile
  next event + date
  ↓ tap
Agenda Surface
  today | week | month pivot
  ↓ tap event
Event Surface
```

## Pattern: Files

```text
Files Tile
  storage + recent document
  ↓ tap
Files Surface
  recent | folders | downloads pivot
  ↓ tap
Preview or open action
```

## Pattern: Settings

```text
Settings Tile
  device summary
  ↓ tap
Settings Surface
  network | display | privacy | apps pivot
  ↓ tap row
Inline panel or focused surface
```
