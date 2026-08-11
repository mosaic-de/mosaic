/// The visual mode that drives Mosaic's token set.
///
/// A mode changes *how a surface is made* — radius, elevation, blur,
/// colour, motion. It never changes *how a screen is organised*; grid,
/// spacing, and semantic tile sizes are structural and live outside the
/// mode. That separation is what lets a launcher offer "home layout" and
/// "visual mode" as two independent settings.
///
/// - [metro]  — the default: flat, sharp, opaque, snappy.
/// - [modern] — softened radius and subtle elevation; still opaque.
/// - [aurora] — layered translucent panes: large radii, real elevation,
///   backdrop blur, hairline edges, longer easing.
enum MosaicMode { metro, modern, aurora }
