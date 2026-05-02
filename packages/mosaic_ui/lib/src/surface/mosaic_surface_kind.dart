/// What a [MosaicSurface] is acting as. Drives radius and elevation token
/// selection.
enum MosaicSurfaceKind {
  /// A tile face. Uses `radius.tile` and `elevation.tile`.
  tile,

  /// A panel that can hold tiles or content blocks.
  /// Uses `radius.panel` and `elevation.panel`.
  panel,

  /// An overlay surface (e.g. expanded panel, sheet).
  /// Uses `radius.panel` and `elevation.overlay`.
  overlay,

  /// A muted background surface for grouping.
  /// Uses `radius.tile` with `surfaceMuted` color.
  muted,
}
