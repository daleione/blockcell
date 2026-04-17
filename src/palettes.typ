// ============================================================================
// Palettes: curated color sets organized by visual role
// ============================================================================
//
// Foundational:
//   palettes.base         Neutral tokens used as component defaults
//                         (surface / border / text tiers — not user swatches)
//
// General-purpose (pick these first — no domain knowledge required):
//   palettes.status       Semantic states: success / warning / danger / info / neutral
//   palettes.pastel       Named soft swatches (red, blue, green, …) — 13 colors
//   palettes.categorical  Array of 8 distinct colors for legends / N-way groups
//   palettes.sequential   Light→dark single-hue ramps (5 steps each)
//
// Domain examples (illustrative — feel free to ignore or copy-and-edit):
//   palettes.rust         Rust memory layout (cheats.rs conventions)
//   palettes.network      TCP/IP protocol headers
//   palettes.cache        CPU cache levels + MESI states
//
// Usage:
//   #import "@preview/blockcell:0.1.0": *
//   #badge(..palettes.status.success)[OK]            // status = (fill, stroke) pair → spread
//   #cell(fill: palettes.pastel.blue)[A]
//   #cell(fill: palettes.categorical.at(0))[Series 1]
//   #cell(fill: palettes.sequential.blue.at(3))[Level 4]
//
// Alias a palette locally to keep call-sites terse:
//   #let C = palettes.pastel
//   #cell(fill: C.green)[…]
// ============================================================================

/// Built-in color palettes grouped by visual role.
///
/// Extend or override any palette with the spread operator:
///
/// ```typst
/// #let C = (..palettes.pastel, accent: rgb("#FF6F00"))
/// ```
#let palettes = (
  // ==========================================================================
  // FOUNDATIONAL
  // ==========================================================================

  // --------------------------------------------------------------------------
  // Base neutrals — the default colors components reach for when no user
  // color is supplied. Intended as a single source of truth for the library's
  // structural look (surfaces, borders, label text tiers); not a user-facing
  // swatch palette (use `pastel` / `categorical` for that).
  //
  // Override by spreading into a replacement dict:
  //   #let palettes = (..palettes, base: (..palettes.base, surface: white))
  // --------------------------------------------------------------------------
  base: (
    surface:        luma(242),  // region background
    surface-alt:    luma(252),  // section card background
    surface-strong: luma(220),  // cell default fill (darker swatch)
    border:         black,      // primary strokes (cell, wrap, lane items)
    border-soft:    gray,       // container strokes (region, target, detail)
    border-subtle:  luma(220),  // faint separator lines (lane, entry-list)
    text:           black,      // primary text fill
    text-muted:     luma(100),  // secondary labels
    text-subtle:    luma(120),  // decorative/tertiary labels
  ),

  // ==========================================================================
  // GENERAL-PURPOSE
  // ==========================================================================

  // --------------------------------------------------------------------------
  // Semantic status colors — for alerts, flow decisions, form states, etc.
  // Each state is a (fill, stroke) pair designed to be spread directly into
  // any function that accepts those arguments:
  //
  //   #badge(..palettes.status.success)[OK]
  //   #cell(..palettes.status.danger)[Error]
  //
  // Need the dark tone for text? Access as palettes.status.success.stroke.
  // --------------------------------------------------------------------------
  status: (
    success: (fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32")),   // green
    warning: (fill: rgb("#FFE0B2"), stroke: rgb("#EF6C00")),   // orange
    danger:  (fill: rgb("#FFCDD2"), stroke: rgb("#C62828")),   // red
    info:    (fill: rgb("#BBDEFB"), stroke: rgb("#1565C0")),   // blue
    neutral: (fill: rgb("#E0E0E0"), stroke: rgb("#616161")),   // gray
  ),

  // --------------------------------------------------------------------------
  // Named pastel swatches (Material-100/200 range) — a general base.
  // --------------------------------------------------------------------------
  pastel: (
    red:    rgb("#EF9A9A"),
    pink:   rgb("#F48FB1"),
    purple: rgb("#CE93D8"),
    indigo: rgb("#9FA8DA"),
    blue:   rgb("#90CAF9"),
    cyan:   rgb("#80DEEA"),
    teal:   rgb("#80CBC4"),
    green:  rgb("#A5D6A7"),
    lime:   rgb("#DCEDC8"),
    yellow: rgb("#FFF9C4"),
    orange: rgb("#FFE0B2"),
    brown:  rgb("#BCAAA4"),
    gray:   luma(230),
  ),

  // --------------------------------------------------------------------------
  // Categorical palette — 8 harmonious but distinguishable colors.
  // Use when you need to color N discrete groups/series/rows.
  // Access by index: palettes.categorical.at(i) — wraps naturally in loops.
  // --------------------------------------------------------------------------
  categorical: (
    rgb("#90CAF9"),  // blue
    rgb("#FFAB91"),  // coral
    rgb("#A5D6A7"),  // green
    rgb("#CE93D8"),  // purple
    rgb("#FFE082"),  // amber
    rgb("#80CBC4"),  // teal
    rgb("#F48FB1"),  // pink
    rgb("#BCAAA4"),  // taupe
  ),

  // --------------------------------------------------------------------------
  // Sequential ramps — light → dark, 5 steps per hue.
  // Useful for intensity / level / heatmap-style coding.
  // Access by index: palettes.sequential.blue.at(0) is lightest.
  // --------------------------------------------------------------------------
  sequential: (
    blue:   (rgb("#E3F2FD"), rgb("#90CAF9"), rgb("#42A5F5"), rgb("#1E88E5"), rgb("#0D47A1")),
    green:  (rgb("#E8F5E9"), rgb("#A5D6A7"), rgb("#66BB6A"), rgb("#43A047"), rgb("#1B5E20")),
    orange: (rgb("#FFF3E0"), rgb("#FFCC80"), rgb("#FFA726"), rgb("#FB8C00"), rgb("#E65100")),
    purple: (rgb("#F3E5F5"), rgb("#CE93D8"), rgb("#AB47BC"), rgb("#8E24AA"), rgb("#4A148C")),
    gray:   (luma(245),      luma(220),      luma(180),      luma(120),      luma(60)),
  ),

  // ==========================================================================
  // DOMAIN EXAMPLES
  // Curated for the bundled examples. Treat them as starting points —
  // copy, rename, or ignore entirely when building your own diagrams.
  // ==========================================================================

  // Rust memory layout (from cheats.rs "Standard Library Types")
  rust: (
    any:         rgb("#FA8072"),
    ptr:         rgb("#87CEFA"),
    sized:       rgb("#00FFFF"),
    cell-bg:     rgb("#FFD700"),
    cell-border: rgb("#FFD700"),
    atomic:      rgb("#3CB371"),
    uninit:      rgb("#D1C4E9"),
    enum-bg:     rgb("#FAFAD2"),
    heap:        rgb("#C6DBE7"),
    anymem:      rgb("#FDECDC"),
  ),

  // Networking / protocol headers
  network: (
    link:      rgb("#BBDEFB"),
    internet:  rgb("#C8E6C9"),
    transport: rgb("#FFE0B2"),
    app:       rgb("#F8BBD0"),
    data:      rgb("#DCEDC8"),
    addr:      rgb("#B2DFDB"),
    flag:      rgb("#E1BEE7"),
    meta:      rgb("#FFF9C4"),
    checksum:  rgb("#D1C4E9"),
    reserved:  luma(230),
  ),

  // CPU cache hierarchy + MESI state colors
  cache: (
    reg:       rgb("#EF9A9A"),
    l1:        rgb("#F48FB1"),
    l2:        rgb("#CE93D8"),
    l3:        rgb("#90CAF9"),
    ram:       rgb("#80CBC4"),
    disk:      rgb("#A5D6A7"),
    data:      rgb("#FFE0B2"),
    modified:  rgb("#FFCC80"),
    exclusive: rgb("#B3E5FC"),
    shared:    rgb("#C8E6C9"),
    invalid:   luma(220),
  ),
)
