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
    inset: (x: 3pt, y: 1pt),
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
#let wrap(body, stroke: 3pt + palettes.base.border, radius: 3pt, inset: 2pt) = {
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
/// - `direction`: `"right"` (default), `"left"`, `"down"`, or `"up"`.
/// - `style`: `"solid"` (default), `"dashed"`, or `"dotted"`.
/// - `head`: `"arrow"` (default, solid triangle) or `"none"`.
/// - `length`: Total extent along the direction axis (default depends on label).
#let edge(
  label: none,
  direction: "right",
  style: "solid",
  head: "arrow",
  stroke: 0.8pt + palettes.base.border,
  length: auto,
) = context {
  let head-size = 6pt
  let line-stroke = _stroke-with-dash(stroke, if style == "solid" { none } else { style })
  let arrow-color = std.stroke(stroke).paint
  let horizontal = direction == "right" or direction == "left"

  if horizontal {
    let actual-length = if length == auto {
      if label == none { 28pt } else {
        let lbl-w = measure(text(size: 0.6em, label)).width
        calc.max(32pt, lbl-w + 14pt)
      }
    } else { length }

    let head-poly(direction) = if direction == "right" {
      polygon(fill: arrow-color, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size))
    } else {
      polygon(fill: arrow-color, stroke: none,
        (head-size, 0pt), (0pt, head-size / 2), (head-size, head-size))
    }

    box(width: actual-length, height: 14pt, baseline: 30%, {
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
    let label-gap = if label == none { 0pt } else { 5pt }

    let actual-length = if length == auto {
      if label == none { 24pt } else {
        let lbl-h = measure(label-content).height
        calc.max(28pt, lbl-h + 14pt)
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
  inset: (x: 10pt, y: 6pt),
  status: none,
  edge-label: none,
) = {
  let (f, s) = if status == none {
    (fill, stroke)
  } else {
    let c = palettes.status.at(status)
    (c.fill, 0.8pt + c.stroke)
  }

  let default-h = 28pt
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
    let sz = if width == auto and height == auto { 32pt } else { width }
    box(
      width: sz, height: if height == auto { sz } else { height },
      fill: f, stroke: s,
      radius: 50%, inset: inset, baseline: 40%,
      { set align(center + horizon); body },
    )
  } else if shape == "diamond" {
    // Auto-width: measure body and pad generously so the diamond's inscribed
    // rectangle (~70% of width) still comfortably fits the text. Floor at 80pt.
    context {
      let w = if width == auto {
        calc.max(measure(text(size: 0.9em, body)).width * 1.8 + 16pt, 80pt)
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
#let junction(body, size: 32pt, fill: palettes.pastel.cyan, ..args) = flow-node(
  body, shape: "circle", width: size, height: size, fill: fill, ..args,
)

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
