// ============================================================================
// Atoms: the fundamental visual building blocks
// ============================================================================
//
// cell       - A colored box with a label (the core primitive)
// tag        - A dotted-border cell for markers / discriminants
// note       - Small inline annotation text
// label      - Small muted label text for diagram annotations
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
/// #cell[A]                                             // default gray
/// #cell(fill: rgb("#FA8072"))[T]                       // colored
/// #cell(fill: aqua, stroke: 3pt + rgb("#FFD700"))[len] // thick border
/// #cell(fill: rgb("#FA8072"), expandable: true)[T]     // shows ← T →
/// #cell(phantom: true)[]                               // faded, dashed
/// #cell(fill: green, overlay: [S])[03]                 // state marker
/// #cell(subtitle: [(heap)])[Vec]                       // two-line card
/// ```
///
/// - `subtitle`: When set, renders `body` as the title and `subtitle` as a
///   smaller muted second line below it, vertically centered. Lets rows of
///   cells display "name + qualifier" (common in architecture diagrams)
///   while keeping single- and two-line cells aligned inside a `flex-row`.
#let cell(
  body,
  fill: palettes.base.surface-strong,
  width: auto,
  height: auto,
  stroke: 0.8pt + palettes.base.border,
  dash: none,
  radius: 0pt,
  inset: (x: 0.4em, y: 0.2em),
  expandable: false,
  phantom: false,
  overlay: none,
  subtitle: none,
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
      set align(if subtitle == none { center } else { center + horizon })
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
      if subtitle != none {
        linebreak()
        text(size: 0.75em, fill: palettes.base.text-muted, subtitle)
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

/// Small muted label text for diagram annotations.
///
/// Use for short labels like `(heap)`, `Memory`, `Only on eviction`, or
/// similar explanatory text that is more structural than `note`, but lighter
/// than normal body text.
///
/// ```typst
/// #label[Memory]
/// #label[(heap)]
/// #label[Only on eviction]
/// ```
#let label(body) = text(size: 0.75em, fill: palettes.base.text-muted, body)

/// A compact status badge for indicating states or alerts.
///
/// ```typst
/// #badge[STALLED]
/// #badge(status: "success")[HIT]
/// #badge(status: "danger")[ERROR]
/// #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[CUSTOM]
/// ```
#let badge(body, status: none, fill: rgb("#FFECB3"), stroke: rgb("#FF8F00")) = {
  let colors = if status == none {
    (fill: fill, stroke: stroke)
  } else {
    palettes.status.at(status)
  }

  box(
    fill: colors.fill,
    stroke: (paint: colors.stroke, thickness: 0.8pt),
    radius: 2pt,
    inset: (x: 0.3em, y: 0.1em),
    baseline: 30%,
    text(size: 0.6em, weight: "bold", fill: colors.stroke.darken(40%), body),
  )
}

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
/// #wrap(stroke: 3pt + rgb("#FFD700"))[
///   #cell(fill: rgb("#FA8072"))[`T`]   // keeps its own thin black border
/// ]
/// ```
#let wrap(body, stroke: 3pt + palettes.base.border, radius: 3pt, inset: 0.2em) = {
  box(
    stroke: stroke, radius: radius, inset: inset,
    baseline: 30%, body,
  )
}

/// A directed connector with optional label and arrow head.
///
/// Renders as a line with a solid triangular arrowhead and an optional label.
/// Horizontal directions (`"right"` / `"left"`) produce an inline element that
/// fits between sibling cells in a row — the classic "A → B" connector.
/// Vertical directions (`"down"` / `"up"`) produce a block-friendly element
/// used between stacked nodes (see `flow-col`); the label sits to the right
/// of the line.
///
/// ```typst
/// #cell[Controller] #edge(label: [HTTP]) #cell[Business]
/// #cell[Business]   #edge(label: [SQL], style: "dashed") #cell[MySQL]
/// #edge(direction: "down", label: [Yes])
/// ```
///
/// - `direction`: `auto` (default — `"right"` in LTR, `"left"` in RTL),
///   `"right"`, `"left"`, `"down"`, or `"up"`.
/// - `style`: `"solid"` (default), `"dashed"`, or `"dotted"`.
/// - `head`: `"arrow"` (default, solid triangle) or `"none"`.
/// - `length`: Total extent along the direction axis (default depends on label).
#let edge(
  label: none,
  direction: auto,
  style: "solid",
  head: "arrow",
  stroke: 0.8pt + palettes.base.border,
  length: auto,
) = context {
  let direction = if direction == auto {
    if text.dir == rtl { "left" } else { "right" }
  } else { direction }
  let em = 1em.to-absolute()
  let head-size = 0.6 * em
  let line-stroke = _stroke-with-dash(stroke, if style == "solid" { none } else { style })
  let arrow-color = std.stroke(stroke).paint
  let horizontal = direction == "right" or direction == "left"

  if horizontal {
    let min-len = 3.2 * em
    let label-pad = 1.4 * em
    let actual-length = if length == auto {
      if label == none { 2.8 * em } else {
        let lbl-w = measure(text(size: 0.6em, label)).width
        calc.max(min-len, lbl-w + label-pad)
      }
    } else { length }

    let head-poly(direction) = if direction == "right" {
      polygon(fill: arrow-color, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size))
    } else {
      polygon(fill: arrow-color, stroke: none,
        (head-size, 0pt), (0pt, head-size / 2), (head-size, head-size))
    }

    box(width: actual-length, height: 1.4 * em, baseline: 30%, {
      if label != none {
        place(top + center,
          text(size: 0.6em, fill: palettes.base.text-muted, label))
      }
      place(horizon + left, line(length: actual-length, stroke: line-stroke))
      if head == "arrow" {
        let anchor = if direction == "right" { horizon + right } else { horizon + left }
        place(anchor, head-poly(direction))
      }
    })
  } else {
    let label-content = if label == none { none } else {
      text(size: 0.6em, fill: palettes.base.text-muted, label)
    }
    let label-w = if label == none { 0pt } else { measure(label-content).width }
    let label-gap = if label == none { 0pt } else { 0.5 * em }

    let actual-length = if length == auto {
      if label == none { 2.4 * em } else {
        let lbl-h = measure(label-content).height
        calc.max(2.8 * em, lbl-h + 1.4 * em)
      }
    } else { length }

    let head-poly-v(direction) = if direction == "down" {
      polygon(fill: arrow-color, stroke: none,
        (0pt, 0pt), (head-size, 0pt), (head-size / 2, head-size))
    } else {
      polygon(fill: arrow-color, stroke: none,
        (0pt, head-size), (head-size, head-size), (head-size / 2, 0pt))
    }

    // Pad symmetrically around the line so the line sits at the box's
    // horizontal center — keeps align(center) working when nodes of
    // different widths stack in flow-col.
    let side-pad = label-gap + label-w
    let total-width = head-size + 2 * side-pad
    let line-x = total-width / 2
    let head-x = line-x - head-size / 2

    box(width: total-width, height: actual-length, {
      place(top + left, dx: line-x,
        line(start: (0pt, 0pt), end: (0pt, actual-length), stroke: line-stroke))
      if head == "arrow" {
        let y-anchor = if direction == "down" { bottom + left } else { top + left }
        place(y-anchor, dx: head-x, head-poly-v(direction))
      }
      if label != none {
        place(horizon + left, dx: line-x + head-size / 2 + label-gap, label-content)
      }
    })
  }
}

/// A flowchart node — rectangle, diamond, stadium (pill), or circle.
///
/// Combine with `edge` to express conditional branches and process flows.
/// Use the `process` / `decision` / `terminal` aliases at call sites for
/// flowchart-standard semantics.
///
/// ```typst
/// #process[支付回调到达]
/// #edge(direction: "right")
/// #decision(width: 160pt)[state == CLOSED?]
/// #edge(label: [Yes], stroke: red)
/// #process[恢复 + 退款]
/// ```
///
/// - `shape`: `"rect"`, `"diamond"`, `"stadium"`, or `"circle"`.
/// - `width` / `height`: `diamond` auto-widens to fit text (with a floor of
///   80pt); override to pin an explicit diagonal.
/// - `inset`: Wider default than `cell` to read as a standalone node.
/// - `status`: Shorthand for `..palettes.status.<name>` — fills and strokes
///   the node with a semantic state color (`success` / `warning` / `danger`
///   / `info` / `neutral`). Overrides `fill` / `stroke` when set.
/// - `edge-label`: When set, attaches a label to the arrow *pointing into*
///   this node inside a `flow-col`. Turns the return value into a sentinel
///   dict; has no effect outside `flow-col`.
#let flow-node(
  body,
  shape: "rect",
  fill: palettes.base.surface,
  stroke: 0.8pt + palettes.base.border,
  width: auto,
  height: auto,
  inset: (x: 1em, y: 0.6em),
  status: none,
  edge-label: none,
) = {
  let (f, s) = if status == none {
    (fill, stroke)
  } else {
    let c = palettes.status.at(status)
    (c.fill, 0.8pt + c.stroke)
  }

  let default-h = 2.8em
  let rendered = if shape == "rect" {
    box(
      width: width, height: if height == auto { default-h } else { height },
      fill: f, stroke: s,
      radius: 2pt, inset: inset, baseline: 40%,
      { set align(center + horizon); body },
    )
  } else if shape == "stadium" {
    box(
      width: width, height: if height == auto { default-h } else { height },
      fill: f, stroke: s,
      radius: 999pt, inset: inset, baseline: 40%,
      { set align(center + horizon); body },
    )
  } else if shape == "circle" {
    let sz = if width == auto and height == auto { 3.2em } else { width }
    box(
      width: sz, height: if height == auto { sz } else { height },
      fill: f, stroke: s,
      radius: 50%, inset: inset, baseline: 40%,
      { set align(center + horizon); body },
    )
  } else if shape == "diamond" {
    // Auto-width: measure body and pad generously so the diamond's inscribed
    // rectangle (~70% of width) still comfortably fits the text.
    context {
      let em = 1em.to-absolute()
      let w = if width == auto {
        calc.max(measure(text(size: 0.9em, body)).width * 1.8 + 1.6 * em, 8 * em)
      } else { width }
      let h = if height == auto { default-h } else { height }
      box(width: w, height: h, baseline: 40%, {
        place(top + left,
          polygon(fill: f, stroke: s,
            (0pt, h / 2), (w / 2, 0pt), (w, h / 2), (w / 2, h)))
        place(center + horizon,
          block(width: w * 0.7, { set align(center); text(size: 0.9em, body) }))
      })
    }
  }

  if edge-label == none {
    rendered
  } else {
    (flow-node-wrapped: true, body: rendered, edge-label: edge-label)
  }
}

/// Rectangular process node. Defaults to `palettes.pastel.blue` — the
/// conventional "action step" color in flowcharts.
#let process(body, fill: palettes.pastel.blue, ..args) = flow-node(
  body, shape: "rect", fill: fill, ..args,
)

/// Diamond-shaped decision node. Defaults to `palettes.pastel.yellow`
/// (conventional "condition" color) and auto-widens to fit the question text.
#let decision(body, fill: palettes.pastel.yellow, ..args) = flow-node(
  body, shape: "diamond", fill: fill, ..args,
)

/// Stadium-shaped (pill) start/end terminal node. Defaults to
/// `palettes.pastel.green` (conventional "entry/exit" color). Pass
/// `status: "danger"` for an error-exit terminal.
#let terminal(body, fill: palettes.pastel.green, ..args) = flow-node(
  body, shape: "stadium", fill: fill, ..args,
)

/// Small circular node. Typically used as a cross-page junction / connector
/// point (a labeled circle like ➀ that continues elsewhere).
#let junction(body, size: 3.2em, fill: palettes.pastel.cyan, ..args) = flow-node(
  body, shape: "circle", width: size, height: size, fill: fill, ..args,
)

/// A brace marking a horizontal or vertical span, with a centered label.
///
/// `direction` controls orientation and which side the label sits on:
/// - `"down"` (default): horizontal brace, label below.
/// - `"up"`: horizontal brace, label above.
/// - `"right"`: vertical brace, label on the right.
/// - `"left"`: vertical brace, label on the left.
///
/// `width` sets the span of horizontal braces; `height` sets the span of
/// vertical braces. The label is always centered along the brace axis.
///
/// ```typst
/// #brace(span: 160pt)[capacity]
/// #brace(direction: "up", span: 160pt)[header]
/// #brace(direction: "right", span: 80pt)[payload]
/// ```
// Draws a curly brace as a single stroked path. `axis` is the span length,
// `depth` is the arm body's transverse reach, `cusp` is how far the center
// tip protrudes toward the label. The arm tips flare AWAY from the label
// (opposite the cusp) so the shape reads as a real `{`/`}` S-curve, not a
// simple arch. `orient` picks which axis the span runs along and which side
// the cusp points toward ("down" / "up" / "right" / "left").
#let _brace-path(axis, depth, cusp, orient, stroke) = {
  let L = axis
  let D = depth
  let C = cusp

  // Normalized (t, d) space: t ∈ [0, L] along the span, d transverse.
  // d = -0.9D: arm tips (outer flare, opposite the cusp/label side)
  // d = 0:     arm baseline
  // d = C:     cusp (toward the label)
  let pts = (
    (0pt, -D * 0.9),
    // end curl → arm
    ((0.015 * L, -D * 0.45), (0.04 * L, 0pt), (0.08 * L, 0pt)),
    // arm → approach cusp
    ((0.30 * L, 0pt), (0.45 * L, 0pt), (0.48 * L, D * 0.25)),
    // descent to cusp
    ((0.49 * L, D * 0.55), (0.5 * L, C * 0.7), (0.5 * L, C)),
    // rise out of cusp
    ((0.5 * L, C * 0.7), (0.51 * L, D * 0.55), (0.52 * L, D * 0.25)),
    // approach end
    ((0.55 * L, 0pt), (0.7 * L, 0pt), (0.92 * L, 0pt)),
    // arm → end curl
    ((0.96 * L, 0pt), (0.985 * L, -D * 0.45), (L, -D * 0.9)),
  )

  // Project (t, d) into box coordinates. Bounding box is (L, 0.9D + C) for
  // horizontal orientations and (0.9D + C, L) for vertical.
  let tip = D * 0.9
  let project = (t, d) => {
    if orient == "down" { (t, d + tip) }
    else if orient == "up" { (t, C - d) }
    else if orient == "right" { (d + tip, t) }
    else { (C - d, t) }
  }
  let p = (xy) => project(xy.at(0), xy.at(1))

  let segs = (curve.move(p(pts.at(0))),)
  for i in range(1, pts.len()) {
    let (c1, c2, end) = pts.at(i)
    segs.push(curve.cubic(p(c1), p(c2), p(end)))
  }
  curve(stroke: stroke, fill: none, ..segs)
}

#let brace(
  body,
  span: 10em,
  direction: "down",
) = {
  assert(
    direction in ("up", "down", "left", "right"),
    message: "brace: direction must be one of \"up\", \"down\", \"left\", \"right\"",
  )

  let stroke = 0.7pt + palettes.base.text-subtle
  let label-content = text(size: 0.7em, fill: palettes.base.text-muted, body)
  // Depth = arm reach (tips flare 0.9·depth opposite the cusp);
  // cusp = inward protrusion toward the label.
  let depth = 0.28em
  let cusp = 0.55em
  let transverse = depth * 0.9 + cusp

  // Extra breathing room on the brace-tip side (toward the content being
  // marked); the label side stays tight.
  let tip-gap = 0.45em
  let label-gap = 0.1em

  if direction == "down" or direction == "up" {
    let brace = box(
      width: span, height: transverse,
      _brace-path(span, depth, cusp, direction, stroke),
    )
    let label = box(width: span, align(center, label-content))
    let (above, below) = if direction == "down" { (tip-gap, label-gap) } else { (label-gap, tip-gap) }
    block(width: span, above: above, below: below, {
      set par(spacing: 0.2em)
      if direction == "down" {
        brace; v(0.05em); label
      } else {
        label; v(0.05em); brace
      }
    })
  } else {
    let brace = box(
      width: transverse, height: span,
      _brace-path(span, depth, cusp, direction, stroke),
    )
    let label = box(height: span, align(horizon, label-content))
    let cells = if direction == "right" { (brace, label) } else { (label, brace) }
    block(height: span, above: label-gap, below: label-gap, grid(
      columns: (auto, auto),
      rows: 100%,
      column-gutter: 0.3em,
      align: horizon,
      ..cells,
    ))
  }
}
