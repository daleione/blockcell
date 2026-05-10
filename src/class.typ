// ============================================================================
// Class diagrams: 3-compartment cards (name / fields / methods) linked by
// arrows whose head shape encodes UML semantics (extends / aggregation /
// composition / association / dependency).
// ============================================================================
//
// class-layout  Painter for class diagrams whose record positions and edge
//               bezier paths are computed externally (TypstUML's
//               codegen/class.rs). Companion to `record-layout` — we keep
//               the two separate because class arrows draw one of seven
//               head shapes per side (vs. record-layout's single dashed
//               triangle), and a class card carries a stereotype circle
//               and three fixed compartments rather than the free
//               key-value rows record-layout draws.
//
// The painter is a pure layout consumer: it does not run any graph
// algorithm. Codegen estimates per-class bounding boxes, runs Sugiyama
// (top-to-bottom rank progression) and pathplan, and emits absolute
// positions plus per-edge cubic-bezier segments.
// ============================================================================

#import "palettes.typ": palettes

// Default tint and single-letter glyph for the stereotype circle, keyed by
// entity kind. Loosely mirrors PlantUML's default skin
// (orange/blue/lavender/pink). Codegen passes a `kind` string we look up
// here; unknown kinds fall back to gray + no glyph so a user-defined
// stereotype still renders something readable.
#let _kind-styles = (
  "class":      (fill: rgb("#ADD1B2"), letter: "C"),
  "struct":     (fill: rgb("#ADD1B2"), letter: "C"),
  "exception":  (fill: rgb("#ADD1B2"), letter: "C"),
  "interface":  (fill: rgb("#B4A7E5"), letter: "I"),
  "protocol":   (fill: rgb("#B4A7E5"), letter: "I"),
  "abstract":   (fill: rgb("#A9DCDF"), letter: "A"),
  "enum":       (fill: rgb("#EB937F"), letter: "E"),
  "annotation": (fill: rgb("#E3664A"), letter: "@"),
  "entity":     (fill: rgb("#ADD1B2"), letter: "E"),
)

#let _kind-style(kind) = _kind-styles.at(kind,
  default: (fill: rgb("#D0D0D0"), letter: none))

// Render one compartment row (a field or method). `member` is a dict with
// keys `vis` (string ∈ {"+", "-", "#", "~", ""}), `body` (content),
// `static` (bool), `abstract` (bool). The visibility glyph is rendered
// monospace so a column of `+`/`-`/`#`/`~` lines up cleanly.
#let _render-member(member) = {
  let vis = member.at("vis", default: "")
  let body = member.at("body", default: [])
  let is-static = member.at("static", default: false)
  let is-abstract = member.at("abstract", default: false)
  let glyph = if vis == "" { [] } else {
    text(font: ("DejaVu Sans Mono", "Menlo", "Consolas"),
         size: 0.95em, fill: palettes.base.text-muted, vis)
  }
  let rendered = body
  if is-abstract { rendered = emph(rendered) }
  if is-static { rendered = underline(rendered) }
  // Visibility glyph + thin gap + body. Inline so a row's height is one
  // text line.
  if vis == "" { rendered }
  else {
    glyph
    h(0.35em)
    rendered
  }
}

// Lay out a free-text note as a yellow sticky with a dog-eared corner.
// Returns the same shape as `_layout-class` so the caller can treat
// notes and classes uniformly.
#let _layout-note(spec, inset) = {
  let pad-x = inset.at("x").to-absolute()
  let pad-y = inset.at("y").to-absolute()
  let body-content = spec.at("body", default: [])
  let body = text(size: 0.85em, body-content)
  let m = measure(body)
  let dog-ear = 8pt
  // Body-min ensures the dog-ear has room even for a one-character note.
  let total-w = calc.max(m.width + 2 * pad-x + dog-ear, 4 * dog-ear)
  let total-h = calc.max(m.height + 2 * pad-y, 2 * dog-ear)

  let fill-color = rgb("#FBFB77")
  let fold-color = rgb("#E0E060")
  let border = 0.6pt + rgb("#9C9C40")

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Body shape with the top-right corner cut away.
    place(top + left, polygon(
      fill: fill-color,
      stroke: border,
      (0pt, 0pt),
      (total-w - dog-ear, 0pt),
      (total-w, dog-ear),
      (total-w, total-h),
      (0pt, total-h),
    ))
    // Triangular fold tucked into the corner.
    place(top + left, polygon(
      fill: fold-color,
      stroke: border,
      (total-w - dog-ear, 0pt),
      (total-w, dog-ear),
      (total-w - dog-ear, dog-ear),
    ))
    // Body text. PlantUML left-aligns notes; we match.
    place(top + left, dx: pad-x, dy: pad-y, body)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a single class card. Returns a dict
//   (content: ..., width: ..., height: ..., mid-x: ..., mid-y: ...)
// `mid-x` / `mid-y` are the centre offsets within the local frame; the
// painter uses (x + mid-x, y) as the top-mid edge anchor and (x + mid-x,
// y + height) as the bottom-mid anchor.
#let _layout-class(spec, fill, stroke, inner-stroke, radius, inset) = {
  let pad-x = inset.at("x").to-absolute()
  let pad-y = inset.at("y").to-absolute()

  let kind = spec.at("kind", default: "class")
  let name-body = spec.at("name", default: [])
  let generic = spec.at("generic", default: none)
  let stereo = spec.at("stereotype", default: none)
  let fields = spec.at("fields", default: ())
  let methods = spec.at("methods", default: ())

  // Stereotype line and name line are measured / placed independently so
  // the marker can be vertically centered against the name line alone
  // (not against the combined block, which would shift it upward when a
  // stereotype line is present above).
  let stereo-line = if stereo == none { none } else {
    text(size: 0.78em, fill: palettes.base.text-muted, [«#stereo»])
  }
  let name-line = text(weight: "bold", {
    name-body
    if generic != none {
      text(weight: "regular", size: 0.85em, [ \<#generic\>])
    }
  })

  // Marker glyph (the small `C` / `I` / `A` / … chip in the corner).
  let style = _kind-style(kind)
  let letter = style.letter
  let marker-r = 0.55em.to-absolute()
  let marker = if letter == none { none } else {
    box(width: 2 * marker-r, height: 2 * marker-r, fill: style.fill,
        stroke: 0.5pt + palettes.base.border, radius: 50%,
        place(center + horizon, text(size: 0.75em, weight: "bold", letter)))
  }

  // Reserve room for the marker on the left of the name compartment.
  let marker-w = if letter == none { 0pt } else { 1.4em.to-absolute() }

  let field-bodies = fields.map(_render-member)
  let method-bodies = methods.map(_render-member)

  let stereo-m = if stereo-line == none { (width: 0pt, height: 0pt) }
                 else { measure(stereo-line) }
  let name-m = measure(name-line)
  let field-ms = field-bodies.map(measure)
  let method-ms = method-bodies.map(measure)

  // Width: stereotype, name (with marker), each field row, each method row.
  let title-w = calc.max(stereo-m.width, name-m.width + marker-w)
  let content-w = (
    (title-w,) + field-ms.map(m => m.width) + method-ms.map(m => m.width)
  ).fold(0pt, (a, w) => calc.max(a, w))
  let total-w = content-w + 2 * pad-x

  // Stereotype line gets a 0.2em bottom margin. Inside the name row, the
  // row height is the larger of the name text and the marker, so a tall
  // marker doesn't get clipped.
  let stereo-gap = if stereo-line == none { 0pt } else { 0.2em.to-absolute() }
  let stereo-h = if stereo-line == none { 0pt } else { stereo-m.height + stereo-gap }
  let name-row-h = calc.max(name-m.height, 2 * marker-r)
  let name-h = stereo-h + name-row-h + 2 * pad-y
  let row-h(ms) = ms.fold(0pt, (acc, m) => acc + m.height + 2 * pad-y)
  let fields-h = if fields.len() == 0 { 0pt } else { row-h(field-ms) }
  let methods-h = if methods.len() == 0 { 0pt } else { row-h(method-ms) }

  // Empty compartments still get an empty band so PlantUML's "always 3
  // compartments" look is preserved when the class has neither fields nor
  // methods (PlantUML draws the box with one section in that case — we
  // match that by collapsing both empty compartments).
  let total-h = name-h + fields-h + methods-h

  let body = box(
    width: total-w, height: total-h,
    fill: fill, stroke: stroke, radius: radius,
    {
      // Compartment separators.
      if fields-h > 0pt or methods-h > 0pt {
        place(top + left, dx: 0pt, dy: name-h,
          line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: inner-stroke))
      }
      if methods-h > 0pt and fields-h > 0pt {
        place(top + left, dx: 0pt, dy: name-h + fields-h,
          line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: inner-stroke))
      }

      // Stereotype line (above the name, no marker beside it).
      if stereo-line != none {
        place(top + left,
          dx: pad-x + marker-w,
          dy: pad-y,
          stereo-line)
      }

      // Name row: marker and name share a row whose height is
      // `name-row-h`; both are vertically centered inside that row.
      let name-row-top = pad-y + stereo-h
      if marker != none {
        place(top + left,
          dx: pad-x,
          dy: name-row-top + (name-row-h - 2 * marker-r) / 2,
          marker)
      }
      place(top + left,
        dx: pad-x + marker-w,
        dy: name-row-top + (name-row-h - name-m.height) / 2,
        name-line)

      // Fields.
      let cy = name-h + pad-y
      for (i, body) in field-bodies.enumerate() {
        place(top + left, dx: pad-x, dy: cy, body)
        cy = cy + field-ms.at(i).height + 2 * pad-y
      }

      // Methods.
      cy = name-h + fields-h + pad-y
      for (i, body) in method-bodies.enumerate() {
        place(top + left, dx: pad-x, dy: cy, body)
        cy = cy + method-ms.at(i).height + 2 * pad-y
      }
    },
  )

  (
    content: body,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Draw the head decoration `head` at point `at`, oriented so the shape's
// "tip" points at `at` and its "tail" extends back along `-tangent`.
// `tangent` is a (x, y) length tuple (normalised here, so the caller can
// pass raw differences).
//
// `head` ∈ "none" | "triangle-open" | "arrow-open" | "diamond-open" |
//          "diamond-filled" | "cross" | "plus" | "circle"
//
// Returns content. "Open" heads (triangle-open, diamond-open, circle)
// use `bg-color` as their fill so the underlying line is hidden inside
// the head shape — no need to clip the line to the head boundary.
#let _draw-head(at, tangent, head, color, bg-color, head-size, thickness) = {
  if head == "none" { return [] }
  let tx = tangent.at(0)
  let ty = tangent.at(1)
  let lenn = calc.sqrt((tx / 1pt) * (tx / 1pt) + (ty / 1pt) * (ty / 1pt))
  if lenn == 0 { return [] }
  let ux = tx / (lenn * 1pt)
  let uy = ty / (lenn * 1pt)
  let px = -uy
  let py = ux

  let tip-x = at.at(0)
  let tip-y = at.at(1)

  if head == "triangle-open" or head == "triangle-filled" {
    let bx = tip-x - ux * head-size
    let by = tip-y - uy * head-size
    let half = head-size * 0.6
    let fill-paint = if head == "triangle-filled" { color } else { bg-color }
    place(top + left, polygon(
      fill: fill-paint,
      stroke: thickness + color,
      (tip-x, tip-y),
      (bx + px * half, by + py * half),
      (bx - px * half, by - py * half),
    ))
  } else if head == "diamond-open" or head == "diamond-filled" {
    let len = head-size * 1.6
    let bx = tip-x - ux * len
    let by = tip-y - uy * len
    let mx = tip-x - ux * (len / 2)
    let my = tip-y - uy * (len / 2)
    let half = head-size * 0.45
    let fill-paint = if head == "diamond-filled" { color } else { bg-color }
    place(top + left, polygon(
      fill: fill-paint,
      stroke: thickness + color,
      (tip-x, tip-y),
      (mx + px * half, my + py * half),
      (bx, by),
      (mx - px * half, my - py * half),
    ))
  } else if head == "arrow-open" {
    let bx = tip-x - ux * head-size
    let by = tip-y - uy * head-size
    let half = head-size * 0.55
    place(top + left, line(
      start: (bx + px * half, by + py * half),
      end: (tip-x, tip-y),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (bx - px * half, by - py * half),
      end: (tip-x, tip-y),
      stroke: thickness + color,
    ))
  } else if head == "cross" {
    let half = head-size * 0.5
    place(top + left, line(
      start: (tip-x - ux * half + px * half, tip-y - uy * half + py * half),
      end: (tip-x + ux * half - px * half, tip-y + uy * half - py * half),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (tip-x - ux * half - px * half, tip-y - uy * half - py * half),
      end: (tip-x + ux * half + px * half, tip-y + uy * half + py * half),
      stroke: thickness + color,
    ))
  } else if head == "plus" {
    let half = head-size * 0.5
    place(top + left, line(
      start: (tip-x - ux * half, tip-y - uy * half),
      end: (tip-x + ux * half, tip-y + uy * half),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (tip-x - px * half, tip-y - py * half),
      end: (tip-x + px * half, tip-y + py * half),
      stroke: thickness + color,
    ))
  } else if head == "circle" {
    let r = head-size * 0.5
    place(top + left, dx: tip-x - r, dy: tip-y - r,
      circle(radius: r, fill: bg-color, stroke: thickness + color))
  }
  // Unknown heads silently render nothing.
}

// Draw a multi-segment cubic bezier from `start` through `segments` to
// `end`. Each segment is `(c1: ..., c2: ..., end: ...)`. The first
// segment's start equals `start`; subsequent starts equal the previous
// segment's end; the last segment's end is overridden by the resolved
// `end` here. Boundary control handles are translated to keep the path
// tangent into the resolved endpoints — same scheme as
// records.typ::_draw-bezier-path.
//
// Heads are drawn with their tips snapped to the resolved endpoints, so
// they stay glued to the class edge even if Rust-side endpoint estimates
// differ slightly from Typst's measured geometry.
#let _draw-edge(
  start, segments, end,
  head-from, head-to, line-style,
  color, bg-color, thickness, head-size,
) = {
  let n = segments.len()
  if n == 0 { return }

  // The painter-side endpoints are snapped to the rendered class
  // geometry, which can drift from codegen's estimate. The two boundary
  // control handles compensate differently:
  //   • first c1: x is forced to start.x (giving a vertical launch
  //     tangent, since class edges run along the TB rank-progression
  //     axis); y is kept as codegen emitted it.
  //   • last c2: translated by (end - last.end) so the codegen-emitted
  //     incoming tangent is preserved against the snapped endpoint.
  // Same scheme as records.typ but transposed for the TB orientation
  // (records.typ is LR, so it forces a horizontal launch instead).
  let first-c1 = (start.at(0), segments.at(0).c1.at(1))
  let last = segments.at(n - 1)
  let last-c2 = (
    last.c2.at(0) + end.at(0) - last.end.at(0),
    last.c2.at(1) + end.at(1) - last.end.at(1),
  )

  let cmds = (curve.move(start),)
  for i in range(n) {
    let seg = segments.at(i)
    let seg-end = if i == n - 1 { end } else { seg.end }
    let seg-c1 = if i == 0 { first-c1 } else { seg.c1 }
    let seg-c2 = if i == n - 1 { last-c2 } else { seg.c2 }
    cmds.push(curve.cubic(seg-c1, seg-c2, seg-end))
  }
  let dash-pat = if line-style == "dashed" { "dashed" }
                 else if line-style == "dotted" { "dotted" }
                 else { none }
  place(top + left, curve(
    ..cmds,
    stroke: (paint: color, thickness: thickness, dash: dash-pat),
  ))

  // Head at start: tip = start, body extends back along start - c1.
  let from-tan = (start.at(0) - first-c1.at(0), start.at(1) - first-c1.at(1))
  _draw-head(start, from-tan, head-from, color, bg-color, head-size, thickness)
  // Head at end: tip = end, body extends back along end - c2.
  let to-tan = (end.at(0) - last-c2.at(0), end.at(1) - last-c2.at(1))
  _draw-head(end, to-tan, head-to, color, bg-color, head-size, thickness)
}

// Place an edge label centered on a parametric position along the chord.
// `t` ∈ [0, 1]: 0 = start anchor, 1 = end anchor. `perp` shifts the label
// perpendicular to the edge — positive values drift to the chord's left,
// negative to its right (using the (dx, dy) → (-dy, dx) 90° CCW rotation).
// Used to keep multiplicity and role labels from stacking on top of each
// other when both are present at the same end.
#let _place-edge-label(start, end, t, body, perp: 0pt) = {
  if body == none { return }
  let dx = end.at(0) - start.at(0)
  let dy = end.at(1) - start.at(1)
  let len-pt = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt))
  let (px, py) = if len-pt == 0 { (0, 0) }
    else { (-dy / (len-pt * 1pt), dx / (len-pt * 1pt)) }
  let x = start.at(0) + dx * t + px * perp
  let y = start.at(1) + dy * t + py * perp
  let lbl = box(inset: 2pt, fill: rgb("#FFFFFFCC"),
    text(size: 0.78em, fill: palettes.base.text, body))
  let m = measure(lbl)
  place(top + left, dx: x - m.width / 2, dy: y - m.height / 2, lbl)
}

/// Painter for class diagrams whose class positions and edge bezier
/// paths are computed by codegen (TypstUML's `codegen/class.rs`).
///
/// ```typst
/// #class-layout(
///   classes: (
///     (x: 0pt, y: 0pt, kind: "class", name: [Animal],
///      fields: ((vis: "+", body: [name: String]),),
///      methods: ((vis: "+", body: [speak()]),)),
///     (x: 0pt, y: 80pt, kind: "class", name: [Dog],
///      fields: (), methods: (())),
///   ),
///   edges: (
///     (from: 1, to: 0,
///      head-from: "none", head-to: "triangle-open",
///      style: "solid",
///      path: ((c1: (50pt, 70pt), c2: (50pt, 30pt), end: (50pt, 0pt)),)),
///   ),
/// )
/// ```
///
/// - `title`: optional bold title above the diagram.
/// - `classes`: array of dicts. Required keys: `x`, `y`, `kind`, `name`.
///   Optional: `generic`, `stereotype`, `fields`, `methods`, `fill`.
/// - `edges`: array of dicts. Required: `from`, `to`, `head-from`,
///   `head-to`, `style`, `path`. Optional: `label`, `mult-from`,
///   `mult-to`, `color`.
/// - `bg-color`: page background (used to fill "open" head shapes so the
///   underlying line doesn't show through). Defaults to white.
/// - `default-fill`: fallback class fill when a class spec has no `fill`.
/// - `stroke` / `inner-stroke`: outer class border and compartment
///   separator strokes.
/// - `radius`: corner radius of class boxes.
/// - `inset`: per-cell padding inside class compartments as `(x:, y:)`.
/// - `edge-color` / `edge-thickness`: default edge stroke styling
///   (overridden per-edge by `color` in an edge dict).
/// - `head-size`: tip size for arrow / triangle / diamond / circle heads.
#let class-layout(
  title: none,
  classes: (),
  edges: (),
  bg-color: white,
  default-fill: rgb("#FEFECE"),
  stroke: 1pt + black,
  inner-stroke: 0.5pt + black,
  radius: 4pt,
  inset: (x: 0.6em, y: 0.3em),
  edge-color: black,
  edge-thickness: 0.8pt,
  head-size: 6pt,
) = context {
  let head-size = head-size.to-absolute()

  let metas = classes.map(spec => {
    if spec.at("kind", default: "class") == "note" {
      _layout-note(spec, inset)
    } else {
      let cls-fill = spec.at("fill", default: default-fill)
      _layout-class(spec, cls-fill, stroke, inner-stroke, radius, inset)
    }
  })

  // Top-mid (incoming anchor) and bottom-mid (outgoing anchor) for each
  // class, snapped to the painter's actual rendered geometry. Codegen's
  // estimate may differ from Typst's measured width; using the measured
  // mid-x here keeps the edge endpoints glued to the box edges.
  let top-mid(i) = (
    classes.at(i).x + metas.at(i).mid-x,
    classes.at(i).y,
  )
  let bot-mid(i) = (
    classes.at(i).x + metas.at(i).mid-x,
    classes.at(i).y + metas.at(i).height,
  )

  // Canvas size = farthest extent across classes and bezier handles.
  let canvas-w = 0pt
  let canvas-h = 0pt
  for i in range(classes.len()) {
    let r = classes.at(i)
    let m = metas.at(i)
    canvas-w = calc.max(canvas-w, r.x + m.width)
    canvas-h = calc.max(canvas-h, r.y + m.height)
  }
  for e in edges {
    for seg in e.path {
      for p in (seg.c1, seg.c2, seg.end) {
        canvas-w = calc.max(canvas-w, p.at(0))
        canvas-h = calc.max(canvas-h, p.at(1))
      }
    }
  }

  let body = block(width: canvas-w, height: canvas-h, breakable: false, {
    // Classes.
    for i in range(classes.len()) {
      let r = classes.at(i)
      place(top + left, dx: r.x, dy: r.y, metas.at(i).content)
    }
    // Edges. Source = bottom-mid of `from`; target = top-mid of `to`.
    // Codegen ensures Sugiyama TB ordering so this anchoring is sane;
    // see codegen/class.rs::orient_relation for the swap rule.
    for e in edges {
      let start = bot-mid(e.from)
      let end = top-mid(e.to)
      let style = e.at("style", default: "solid")
      let color = e.at("color", default: edge-color)
      _draw-edge(
        start, e.path, end,
        e.at("head-from", default: "none"),
        e.at("head-to", default: "none"),
        style, color, bg-color, edge-thickness, head-size,
      )
      _place-edge-label(start, end, 0.5, e.at("label", default: none))
      // Mult and role share the same `t`; they're split apart by a small
      // perpendicular offset so both fit beside the edge without
      // overlapping. Positive perp = chord's left, negative = right.
      _place-edge-label(start, end, 0.12, e.at("mult-from", default: none),
        perp: 10pt)
      _place-edge-label(start, end, 0.12, e.at("role-from", default: none),
        perp: -10pt)
      _place-edge-label(start, end, 0.88, e.at("mult-to", default: none),
        perp: 10pt)
      _place-edge-label(start, end, 0.88, e.at("role-to", default: none),
        perp: -10pt)
    }
  })

  if title != none {
    align(center)[#strong(title)]
    v(0.5em, weak: true)
  }
  body
}
