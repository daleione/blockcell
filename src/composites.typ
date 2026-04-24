// ============================================================================
// Composites: higher-level diagram structures
// ============================================================================
//
// schema        - Top-level inline diagram with title and description
// linked-schema - Schema with fields → connector → target
// grid-row      - A labeled row for tabular / register / cache diagrams
// lane          - A horizontal track for thread / timeline diagrams
// section       - A titled card for grouping related diagrams
// ============================================================================

#import "atoms.typ": *
#import "containers.typ": *
#import "palettes.typ": palettes

/// A top-level diagram container with optional title and description.
///
/// Wraps content as an inline box so multiple schemas flow horizontally.
#let schema(title: none, desc: none, width: auto, body) = {
  box(
    width: width,
    inset: (bottom: 1.2em, right: 1.6em),
    baseline: 0%,
    {
      if title != none {
        block(below: 0.3em, text(weight: "bold", title))
      }
      { set align(center); body }
      if desc != none {
        block(above: 0.3em, text(size: 0.7em, fill: palettes.base.text-muted, desc))
      }
    },
  )
}

/// A schema with top-level fields linked to a target region below.
///
/// ```typst
/// #linked-schema(
///   title: raw("Vec<T>"),
///   fields: (my-ptr(), my-len(), my-cap()),
///   target-fill: blue.lighten(80%),
///   target-label: "(heap)",
///   { cell(fill: rgb("#FA8072"))[T]; cell(fill: rgb("#FA8072"))[T] },
/// )
/// ```
#let linked-schema(
  title: none,
  desc: none,
  width: auto,
  fields: (),
  target-fill: rgb("#FDECDC"),
  target-label: none,
  target-width: auto,
  danger: false,
  body,
) = {
  schema(title: title, desc: desc, width: width, {
    region(danger: danger, fields.join())
    connector()
    target(fill: target-fill, label: target-label, width: target-width, body)
  })
}

/// A labeled row of cells for tabular, register, or cache diagrams.
///
/// Row label is vertically centered with the content.
///
/// - `label-width`: width of the label column. `auto` (default) measures the
///   label and hugs its natural width — ideal for a single labeled row. For
///   multiple stacked rows that should align vertically (classic tabular
///   case), pass an explicit length that fits the widest label.
/// - `label-align`: horizontal alignment of the label inside its column.
///   Pass only a horizontal component (`left`, `right`, `center`); the vertical
///   part is managed internally. `auto` (default) pushes the label against the
///   body (`right` in LTR, `left` in RTL); pass `left`/`right` to override.
#let grid-row(
  label: none,
  label-width: auto,
  label-align: auto,
  body,
) = context {
  set par(spacing: 0.4em)
  let label-align = if label-align == auto {
    if text.dir == rtl { left } else { right }
  } else { label-align }
  let body-align = if text.dir == rtl { right } else { left }
  // Breathing space added to a measured label's natural width when
  // `label-width: auto`, so the label doesn't touch the body gutter.
  let label-pad = 0.2em.to-absolute()
  let rendered-label = if label != none {
    text(size: 0.75em, fill: palettes.base.text-muted, label)
  } else { [] }
  let w = if label-width == auto {
    if label == none { 0pt } else { measure(rendered-label).width + label-pad }
  } else { label-width }
  grid(
    columns: (w, 1fr),
    align: (label-align + horizon, body-align + horizon),
    gutter: 0.6em,
    rendered-label,
    body,
  )
}

/// A horizontal track with color-coded items for thread or timeline diagrams.
///
/// ```typst
/// #lane(
///   name: [Thread 1],
///   items: (
///     (label: [Mutex], fill: green),
///     (label: [Rc],    fill: red),
///   ),
/// )
/// ```
#let lane(name: none, items: ()) = {
  block(width: 100%, inset: (y: 0.4em), {
    place(horizon, line(length: 100%, stroke: (paint: palettes.base.border-subtle, thickness: 1pt)))
    for item in items {
      h(0.8em)
      box(
        fill: item.fill,
        stroke: (paint: palettes.base.border, thickness: 0.5pt),
        radius: 2pt,
        inset: (x: 0.4em, y: 0.2em),
        baseline: 30%,
        text(size: 0.75em, fill: palettes.base.text, item.label),
      )
    }
    v(0.4em)
    if name != none {
      v(0.1em)
      text(size: 0.65em, fill: palettes.base.text-subtle, name)
    }
  })
}

/// A color legend mapping fills to labels.
///
/// ```typst
/// #legend(
///   (label: [Modified], fill: orange),
///   (label: [Shared],   fill: green),
///   (label: [Invalid],  fill: gray),
/// )
/// ```
///
/// - `items`: Array of dictionaries with `label` and `fill` keys.
/// - `columns`: Number of columns. Default: `auto` (one row).
/// - `swatch-size`: Size of the color swatch. Default: `1em`.
#let legend(..items, columns: auto, swatch-size: 1em) = {
  let entries = items.pos()
  let cols = if columns == auto { entries.len() } else { columns }

  grid(
    columns: cols,
    column-gutter: 1.4em,
    row-gutter: 0.6em,
    ..entries.map(item => {
      box(baseline: 20%, {
        box(
          fill: item.fill, width: swatch-size, height: swatch-size,
          stroke: 0.5pt + palettes.base.border, radius: 2pt,
        )
        h(0.4em)
        text(size: 0.8em, item.label)
      })
    }),
  )
}

/// A proportional bit-field row where cell widths scale by bit count.
///
/// Perfect for network protocol headers and hardware register maps.
/// Each field's width is proportional to its bit count relative to `total`.
///
/// ```typst
/// #bit-row(total: 32, width: 400pt, fields: (
///   (bits: 4,  label: [Ver],  fill: yellow),
///   (bits: 4,  label: [IHL],  fill: yellow),
///   (bits: 8,  label: [DSCP], fill: purple),
///   (bits: 16, label: [Total Length], fill: aqua),
/// ))
/// ```
///
/// - `total`: Total bit width of the row (e.g., 32 for a 32-bit word).
/// - `width`: Total visual width of the row.
/// - `fields`: Array of `(bits, label, fill)` dictionaries.
///   Optional keys: `stroke`, `dash`.
/// - `show-bits`: If `true`, show bit widths as subscript. Default: `true`.
#let bit-row(total: 32, width: 400pt, fields: (), show-bits: true) = {
  box(baseline: 30%, {
    for f in fields {
      cell(
        {
          f.label
          if show-bits { sub-label[#{ str(f.bits) }b] }
        },
        fill: f.fill,
        width: width * f.bits / total,
        stroke: f.at("stroke", default: 0.8pt + palettes.base.border),
        dash: f.at("dash", default: none),
      )
    }
  })
}

/// A row of cells whose widths are distributed by `flex` ratios (fr units).
///
/// Solves the "every column needs an explicit `width: NNpt`" pain point: each
/// item declares a `flex` weight and the row divides its available width
/// proportionally, like CSS `flex-grow`. Backed by Typst `grid` with `fr`
/// column units.
///
/// ```typst
/// #flex-row(
///   (flex: 1, body: cell(fill: blue)[Category Tree]),
///   (flex: 1, body: cell(fill: aqua)[Product Card]),
///   (flex: 2, body: cell(fill: teal)[Search Index]),  // 2× wider
/// )
/// ```
///
/// Child elements with `width: auto` (the default for `cell`) keep their
/// intrinsic width inside the assigned column. To fill the column, set
/// `width: 100%` on the child.
///
/// - `width`: Total row width. `auto` (default) fills the parent.
/// - `gap`: Column gutter. Defaults to `0.4em` so adjacent tiles don't touch;
///   pass `0pt` for flush rows.
/// - `align`: Cross-axis alignment (default `horizon`).
/// - Items: positional `(flex:, body:)` dictionaries.
#let flex-row(width: auto, gap: 0.4em, align: horizon, ..items) = {
  let entries = items.pos()
  let cols = entries.map(e => e.flex * 1fr)
  let bodies = entries.map(e => e.body)
  let actual-width = if width == auto { 100% } else { width }

  block(width: actual-width,
    grid(
      columns: cols,
      column-gutter: gap,
      align: align,
      ..bodies,
    ),
  )
}

/// Vertically stack flow-chart nodes with an auto-inserted down-arrow
/// between each consecutive pair. Each node is centered on the column axis
/// so lines visually align even when node widths differ.
///
/// To label a specific arrow, attach `edge-label:` to the *destination* node
/// — the label is read off the arrow pointing *into* that node. This reads
/// top-down alongside the flow and stays robust under reordering.
///
/// ```typst
/// #flow-col(
///   terminal[Start],
///   process[Load config],
///   decision[Config valid?],
///   process(edge-label: [Yes])[Start server],
///   terminal(status: "danger")[Exit],
/// )
/// ```
///
/// - Positional args: nodes (any content; nodes produced with
///   `edge-label:` are auto-unwrapped).
/// - `edge-style`: default style for auto-inserted edges (`"solid"`,
///   `"dashed"`, `"dotted"`).
/// - `gap`: extra spacing added around each auto-inserted edge.
///
/// For complex 2-D flowcharts (diagonal routing, rejoining branches), reach
/// for `fletcher` / `cetz`; this composite covers the common linear case.
#let flow-col(
  ..nodes,
  edge-style: "solid",
  gap: 0pt,
) = {
  let items = nodes.pos()
  if items.len() == 0 { return }

  // Unwrap sentinel dicts produced by `flow-node(edge-label: ...)`.
  let unwrap(item) = if type(item) == dictionary and item.at("flow-node-wrapped", default: false) {
    (body: item.body, edge-label: item.edge-label)
  } else {
    (body: item, edge-label: none)
  }

  let rows = ()
  for (i, node) in items.enumerate() {
    let u = unwrap(node)
    if i > 0 {
      rows.push(align(center, edge(
        direction: "down",
        style: edge-style,
        label: u.edge-label,
      )))
    }
    rows.push(align(center, u.body))
  }
  std.stack(dir: ttb, spacing: gap, ..rows)
}

/// A titled section card for grouping related diagrams.
#let section(title, fill: palettes.base.surface-alt, stroke: 0.5pt + palettes.base.border-soft, body) = {
  block(
    width: 100%, inset: 1.4em, fill: fill,
    radius: 4pt, stroke: stroke, above: 1.4em,
    {
      text(size: 1.2em, weight: "bold", title)
      v(0.8em)
      body
    },
  )
}

/// A horizontal layer row: a bold colored label on the left + content on
/// the right. Stack several `tier`s vertically to form classic "layered
/// architecture" diagrams (e.g. client → service → data).
///
/// Structurally mirrors `grid-row` — same label-width / label-align semantics —
/// but styles the label bold + colored (not muted) and aligns the body to the
/// top (not center), so a multi-line architectural panel sits flush with its
/// layer name.
///
/// ```typst
/// #tier(label: [Client], accent: palettes.categorical.at(0).darken(30%))[
///   #group(...)[#cell[Web] #cell[Mobile]]
/// ]
/// #tier(label: [Data], accent: palettes.categorical.at(4).darken(30%))[
///   #group(...)[#cell[Users DB] #cell[Orders DB]]
/// ]
/// ```
///
/// - `label`: Tier name (rendered bold in `accent` color).
/// - `accent`: Color for the label — typically one hue per tier to tint
///   the whole row visually.
/// - `label-width`: Width reserved for the label column. `auto` (default)
///   hugs the label's natural width. When stacking tiers whose labels differ
///   in length, pass an explicit length so every body starts at the same x.
/// - `label-align`: Horizontal alignment of the label inside its column
///   (`left` / `right` / `center` — vertical part is managed internally).
/// - `gap`: Gutter between label and body.
#let tier(
  body,
  label: none,
  accent: palettes.base.text,
  label-width: auto,
  label-align: auto,
  gap: 0.6em,
) = context {
  let label-align = if label-align == auto {
    if text.dir == rtl { left } else { right }
  } else { label-align }
  let body-align = if text.dir == rtl { right } else { left }
  let label-pad = 0.2em.to-absolute()
  let rendered-label = if label != none {
    text(weight: "bold", fill: accent, label)
  } else { [] }
  let w = if label-width == auto {
    if label == none { 0pt } else { measure(rendered-label).width + label-pad }
  } else { label-width }
  grid(
    columns: (w, 1fr),
    column-gutter: gap,
    align: (label-align + horizon, body-align + top),
    rendered-label,
    body,
  )
}

/// A row of side-by-side children stretched to the tallest child's height.
///
/// Solves the common "architectural columns with uneven content length"
/// pain point — e.g. a five-item panel next to a two-item panel, where
/// you want the short one to extend its frame to match.
///
/// Children are either rigid content (participates in natural-height
/// measurement) or a factory `h => content` (receives the measured target
/// height — typically passed through as `height:` on a `group` / `box`).
///
/// ```typst
/// #match-row(
///   width-ratio: (1, 1, 1),
///   gap: 8pt,
///   core-panel,          // rigid — measured
///   apps-panel,          // rigid — measured
///   h => service-col(    // factory — stretched to measured height
///     [Legacy], items, faded: true, height: h,
///   ),
/// )
/// ```
///
/// - `width-ratio`: Array of column weights (e.g. `(3, 1)` or `(1, 1, 1)`).
///   Defaults to equal-width columns.
/// - `gap`: Column gutter. Defaults to `0.4em` (same as `flex-row`); pass `0pt`
///   for flush columns.
/// - `align`: Cell alignment (default `top`).
#let match-row(
  width-ratio: none,
  gap: 0.4em,
  align: top,
  ..items,
) = {
  let children = items.pos()
  let n = children.len()
  if n == 0 { return }
  let ratios = if width-ratio == none { (1,) * n } else { width-ratio }
  let total-ratio = ratios.sum()

  layout(size => {
    let usable = size.width - gap * (n - 1)
    let widths = ratios.map(r => usable * r / total-ratio)

    // Measure natural heights; factories contribute 0 (they stretch to fit).
    let h = calc.max(0pt, ..children.enumerate().map(((i, c)) => {
      if type(c) == function { 0pt }
      else { measure(box(width: widths.at(i), c)).height }
    }))

    grid(
      columns: widths,
      column-gutter: gap,
      align: align,
      ..children.map(c => if type(c) == function { c(h) } else { c }),
    )
  })
}
