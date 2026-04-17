// ============================================================================
// Containers: grouping and layout structures
// ============================================================================
//
// region     - A bordered container grouping cells into a visual unit
// target     - A linked/referenced region (dashed, faded, with label)
// connector  - A vertical line linking regions
// divider    - A text separator between layout alternatives
// detail     - An explanation bar below a region
// entry-list - A vertical list of entries inside a target
// ============================================================================

#import "palettes.typ": palettes
#import "atoms.typ": _stroke-with-dash

/// A bordered container that groups cells into a visual unit.
///
/// Regions are the primary structural element, providing a visual background
/// and border to delineate a composite structure.
///
/// - `dash`: Border dash pattern (`none`, `"dashed"`, `"dotted"`).
/// - `label`: Optional bottom-right annotation (e.g., `"(heap)"`).
/// - `danger`: Thick red border (mutually exclusive with `faded`).
/// - `faded`: Dashed border, semi-transparent (mutually exclusive with `danger`).
#let region(
  body,
  fill: palettes.base.surface,
  stroke: 1pt + palettes.base.border-soft,
  dash: none,
  radius: 4pt,
  width: auto,
  content-align: center,
  label: none,
  danger: false,
  faded: false,
) = {
  let effective-dash = if faded { "dashed" } else { dash }
  let effective-stroke = if danger {
    (paint: red, thickness: 2pt)
  } else {
    _stroke-with-dash(stroke, effective-dash)
  }
  let actual-fill = if faded { fill.transparentize(60%) } else { fill }

  box(
    width: width, fill: actual-fill, stroke: effective-stroke,
    radius: radius, inset: 5pt, baseline: 30%,
    {
      set align(content-align)
      body
      if label != none {
        place(bottom + right, dx: 2pt, dy: 4pt,
          text(size: 0.55em, fill: palettes.base.text-subtle, label))
      }
    },
  )
}

/// A linked / referenced region, drawn below a connector.
///
/// Has a dashed border with an optional bottom-right label
/// (e.g., "(heap)", "(static)"). Thin wrapper over `region`.
#let target(
  body,
  fill: rgb("#FDECDC"),
  label: none,
  width: auto,
) = region(
  fill: fill.transparentize(40%),
  dash: "dashed",
  label: label,
  width: width,
  body,
)

/// A vertical connecting line between a region and its target.
#let connector(length: 8pt, stroke: 1pt + palettes.base.border-soft) = {
  block(width: 100%, above: 2pt, below: 0pt,
    align(center, line(angle: 90deg, length: length, stroke: stroke)),
  )
}

/// A text separator between layout alternatives (e.g., "or maybe").
#let divider(body: [or]) = {
  align(center, text(size: 0.75em, style: "italic", body))
}

/// An explanation bar below a region.
#let detail(body, fill: rgb("#FFF8DC")) = {
  block(
    width: 100%, fill: fill,
    stroke: (paint: palettes.base.border-soft, thickness: 1pt),
    radius: (bottom: 3pt), inset: (x: 6pt, y: 3pt), above: -1pt,
    { set text(size: 0.75em); set align(center); body },
  )
}

/// A vertical list of labeled entries inside a target.
///
/// Used for field lists, register maps, vtables, or any structured
/// vertical listing within a referenced region.
#let entry-list(entries, fill: rgb("#DEB887"), label: none, width: auto) = {
  target(fill: fill, label: label, width: width, {
    set text(size: 0.7em)
    set align(left)
    for (i, entry) in entries.enumerate() {
      block(
        width: 100%,
        stroke: if i < entries.len() - 1 {
          (bottom: (paint: palettes.base.border-subtle, thickness: 0.5pt))
        },
        inset: 2pt, entry,
      )
    }
  })
}
