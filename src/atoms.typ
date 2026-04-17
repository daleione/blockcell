// ============================================================================
// Atoms: the fundamental visual building blocks
// ============================================================================
//
// cell       - A colored box with a label (the core primitive)
// tag        - A dotted-border cell for markers / discriminants
// note       - Small inline annotation text
// badge      - A compact status indicator (e.g., STALLED, ERROR)
// sub-label  - Subscript-style size annotation (e.g., 2/4/8)
// span-label - A horizontal extent label (e.g., ← capacity →)
// ============================================================================

#import "palettes.typ": palettes

/// Merge a dash pattern into an existing stroke, preserving paint and thickness.
/// Returns the stroke unchanged when `dash` is `none`.
#let _stroke-with-dash(stroke, dash) = {
  if dash == none { return stroke }
  if type(stroke) == dictionary {
    (..stroke, dash: dash)
  } else {
    let s = std.stroke(stroke)
    (paint: s.paint, thickness: s.thickness, dash: dash)
  }
}

/// A colored rectangular cell — the atomic building block of all diagrams.
///
/// ```typst
/// #cell[A]                                    // default gray
/// #cell(fill: salmon)[T]                      // colored
/// #cell(fill: cyan, stroke: 3pt + gold)[len]  // thick border
/// #cell(fill: salmon, expandable: true)[T]    // shows ← T →
/// #cell(phantom: true)[]                      // faded, dashed
/// #cell(fill: green, overlay: [S])[03]        // state marker
/// ```
#let cell(
  body,
  fill: palettes.base.surface-strong,
  width: auto,
  height: auto,
  stroke: 0.8pt + palettes.base.border,
  dash: none,
  radius: 0pt,
  inset: (x: 4pt, y: 2pt),
  expandable: false,
  phantom: false,
  overlay: none,
  baseline: 30%,
) = {
  let actual-fill = if phantom { fill.transparentize(60%) } else { fill }
  let actual-dash = if phantom { "dashed" } else { dash }

  box(
    width: width, height: height, fill: actual-fill,
    stroke: _stroke-with-dash(stroke, actual-dash),
    radius: radius, inset: inset, baseline: baseline,
    {
      set text(fill: palettes.base.text, hyphenate: false)
      set align(center)
      set par(justify: false)
      if expandable {
        text(size: 0.7em, sym.arrow.l)
        h(1pt)
        body
        h(1pt)
        text(size: 0.7em, sym.arrow.r)
      } else {
        body
      }
      if overlay != none {
        place(top + right,
          text(size: 0.5em, weight: "bold", fill: palettes.base.text-muted, overlay))
      }
    },
  )
}

/// A dotted-border cell for discriminants, tags, or markers.
///
/// Convenience wrapper: `cell` with dotted border and light green fill.
#let tag(body, fill: rgb("#90EE90")) = cell(body, fill: fill, dash: "dotted")

/// Small inline annotation text.
#let note(body) = text(size: 0.7em, body)

/// A compact status badge for indicating states or alerts.
///
/// ```typst
/// #badge[STALLED]
/// #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
/// #badges.success[OK]
/// #badges.danger[ERROR]
/// ```
#let badge(body, fill: rgb("#FFECB3"), stroke: rgb("#FF8F00")) = {
  box(
    fill: fill,
    stroke: (paint: stroke, thickness: 0.8pt),
    radius: 2pt,
    inset: (x: 3pt, y: 1pt),
    baseline: 30%,
    text(size: 0.6em, weight: "bold", fill: stroke.darken(40%), body),
  )
}

/// Prebound status badge shortcuts.
///
/// Provides a shorter alternative to `#badge(..palettes.status.success)[OK]`,
/// while keeping `palettes.status.*` as the underlying source of truth.
#let badges = (
  success: badge.with(..palettes.status.success),
  warning: badge.with(..palettes.status.warning),
  danger: badge.with(..palettes.status.danger),
  info: badge.with(..palettes.status.info),
  neutral: badge.with(..palettes.status.neutral),
)

/// Subscript-style label for field size annotations.
///
/// Typically appended inside a cell: `#cell[ptr#sub-label[2/4/8]]`
#let sub-label(body) = text(size: 0.5em, baseline: -2pt, body)

/// A horizontal extent label showing a span: `← label →`.
///
/// When `width` is `auto` (default), it measures the immediately preceding
/// sibling content so the arrows align automatically.  Pass an explicit
/// length to override.
#let span-label(body, width: 100%) = {
  block(width: width, {
    set text(size: 0.55em, fill: palettes.base.text-subtle)
    set align(center)
    [#sym.arrow.l~#body~#sym.arrow.r]
  })
}

/// A decorative wrapper that adds a thick colored border around content.
///
/// Used for double-border effects (e.g., Rust's `Cell<T>` has a thin black
/// inner border on the cell + thick gold outer border from `.celled`).
///
/// ```typst
/// #wrap(stroke: 3pt + gold)[
///   #cell(fill: salmon)[`T`]   // keeps its own thin black border
/// ]
/// ```
#let wrap(body, stroke: 3pt + palettes.base.border, radius: 3pt, inset: 2pt) = {
  box(
    stroke: stroke, radius: radius, inset: inset,
    baseline: 30%, body,
  )
}

/// A horizontal brace with a centered label below.
///
/// Draws a curly brace `⏟` spanning the given width with a label underneath.
///
/// ```typst
/// #brace(width: 120pt)[capacity]
/// ```
#let brace(body, width: 100pt) = {
  block(width: width, {
    set align(center)
    // Top: the brace line
    block(width: 100%, {
      set align(center)
      grid(
        columns: (1fr, auto, 1fr),
        align: horizon,
        line(length: 100%, stroke: 0.6pt + palettes.base.text-subtle),
        text(size: 0.7em, fill: palettes.base.text-subtle, h(2pt) + sym.arrow.b + h(2pt)),
        line(length: 100%, stroke: 0.6pt + palettes.base.text-subtle),
      )
    })
    // Bottom: the label
    v(1pt)
    text(size: 0.65em, fill: palettes.base.text-muted, body)
  })
}
