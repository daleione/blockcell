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
// stack      - A simple vertical stack with configurable gap
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
    radius: radius, inset: 0.5em, baseline: 30%,
    {
      set align(content-align)
      body
      if label != none {
        place(bottom + right, dx: 0.2em, dy: 0.4em,
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
#let connector(length: 0.8em, stroke: 1pt + palettes.base.border-soft) = {
  block(width: 100%, above: 0.2em, below: 0pt,
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
    radius: (bottom: 3pt), inset: (x: 0.6em, y: 0.3em), above: -0.1em,
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
        inset: 0.2em, entry,
      )
    }
  })
}

/// A bordered container with a top-left title for grouping multiple
/// independent sub-components into a logical boundary.
///
/// Sits between `region` (one structural unit, bottom-right small label) and
/// `section` (document-level card, big top-centered title). Use `group` for
/// "these N children belong together" — module ownership, layered sub-systems,
/// etc. Pass `dash: "dashed"` to indicate a logical (non-physical) boundary.
///
/// ```typst
/// #group(label: [业务层 Business], fill: cat.at(1).lighten(40%))[
///   #svc(cat.at(1))[Business: 自有平台]
///   #v(4pt)
///   #svc(cat.at(1).lighten(10%))[Business: 外部平台同步]
/// ]
/// ```
///
/// - `label`: Top-left title content. Omit to draw a bare frame.
/// - `dash`: `"dashed"` for logical groupings (non-physical boundary).
/// - `width`: Frame width. `auto` lets the box size to its content.
/// - `height`: Frame height. Pass an explicit length to equalize side-by-side
///   groups with uneven content. (`100%` does *not* resolve against an
///   auto-sized grid row — use `match-row` to measure the taller sibling
///   and pass its height through a factory.)
#let group(
  body,
  label: none,
  fill: palettes.base.surface,
  stroke: 1pt + palettes.base.border-soft,
  dash: none,
  radius: 5pt,
  width: auto,
  height: auto,
  inset: 1em,
  content-align: left,
) = {
  box(
    width: width,
    height: height,
    fill: fill,
    stroke: _stroke-with-dash(stroke, dash),
    radius: radius,
    inset: inset,
    baseline: 30%,
    {
      set align(content-align)
      if label != none {
        block(width: 100%, below: 0.6em,
          align(left,
            box(
              fill: fill.darken(12%),
              stroke: 0.6pt + fill.darken(45%),
              radius: 3pt,
              inset: (x: 0.6em, y: 0.2em),
              text(size: 0.78em, weight: "bold", fill: palettes.base.text, label),
            )))
      }
      body
    },
  )
}

/// A simple vertical stack with configurable gap.
///
/// Accepts multiple content items as positional arguments so each stacked item
/// is explicit and stable.
///
/// ```typst
/// #stack(
///   [#label[Memory]],
///   [#region[...]],
///   [#detail[64 bytes]],
/// )
/// ```
#let stack(..items, gap: 0.4em, align: left) = {
  let entries = items.pos()
  grid(
    columns: 1,
    row-gutter: gap,
    align: (align,),
    ..entries,
  )
}
