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

// Lay out a lollipop: a small filled circle with the label centered
// below it (UML's "provided interface" notation). Returns the same
// shape as `_layout-class` so callers treat it uniformly.
#let _layout-lollipop(spec) = {
  let name = spec.at("name", default: [])
  let diameter = 14pt
  let gap = 2pt
  let label = text(size: 0.85em, name)
  let m = measure(label)
  // Codegen passes `width` so its mid-x (used for edge anchoring) lines
  // up with the disc center we draw here. Without it, codegen's text
  // measurement and Typst's `measure` disagree, leaving the connector
  // off the disc.
  let total-w = spec.at("width", default: calc.max(m.width, diameter))
  let total-h = diameter + gap + m.height

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + center, dy: 0pt,
      circle(radius: diameter / 2, fill: white, stroke: 0.8pt + black))
    place(top + center, dy: diameter + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: diameter / 2,
    // Edges anchor on the disc, not at the layout's outer edge — the
    // label hangs off the disc but isn't part of the connection point.
    anchor-top: (total-w / 2, 0pt),
    anchor-bot: (total-w / 2, diameter),
    anchor-left: (total-w / 2 - diameter / 2, diameter / 2),
    anchor-right: (total-w / 2 + diameter / 2, diameter / 2),
  )
}

// Lay out a use-case actor (stickman). Renders a simple head + body +
// arms + legs stick figure with the name below. Matches PlantUML's
// default actor style. Returns the same dict shape as `_layout-class`.
#let _layout-actor(spec) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  // Tuned to PlantUML proportions: head ≈ 1/5 of figure height,
  // total figure height ≈ 40pt, arms width ≈ 24pt. Label below.
  let head-r = 4pt
  let body-len = 16pt
  let arm-y = 4pt
  let arm-half = 12pt
  let leg-y = body-len - 2pt
  let leg-half = 8pt
  let stickman-w = arm-half * 2
  let stickman-h = head-r * 2 + body-len + leg-half + 2pt
  let gap = 3pt
  let total-w = calc.max(stickman-w, m.width)
  let total-h = stickman-h + gap + m.height
  let mid-x = total-w / 2

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Head.
    place(top + left, dx: mid-x - head-r, dy: 0pt,
      circle(radius: head-r, fill: white, stroke: 0.9pt + black))
    // Body: vertical line.
    let body-top = 2 * head-r
    place(top + left, dx: mid-x, dy: body-top,
      line(start: (0pt, 0pt), end: (0pt, body-len), stroke: 0.9pt + black))
    // Arms: horizontal line.
    place(top + left, dx: mid-x - arm-half, dy: body-top + arm-y,
      line(start: (0pt, 0pt), end: (2 * arm-half, 0pt), stroke: 0.9pt + black))
    // Left leg.
    place(top + left, dx: mid-x, dy: body-top + leg-y,
      line(start: (0pt, 0pt), end: (-leg-half, leg-half), stroke: 0.9pt + black))
    // Right leg.
    place(top + left, dx: mid-x, dy: body-top + leg-y,
      line(start: (0pt, 0pt), end: (leg-half, leg-half), stroke: 0.9pt + black))
    // Label below.
    place(top + center, dy: stickman-h + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: stickman-h / 2,
    // Edges anchor on the stickman silhouette, not the label.
    anchor-top: (mid-x, 0pt),
    anchor-bot: (mid-x, stickman-h),
    anchor-left: (mid-x - arm-half, stickman-h / 2),
    anchor-right: (mid-x + arm-half, stickman-h / 2),
  )
}

// Lay out a database cylinder. PlantUML draws this as a rectangle with
// a half-ellipse top cap and a curved bottom — we approximate with a
// rectangle whose top edge is replaced by an ellipse outline and a
// curved bottom edge using Typst's `path` element.
#let _layout-database(spec, fill) = {
  let pad-x = 8pt
  let pad-y = 4pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let cap-h = 6pt
  let body-min-h = 32pt
  let body-h = calc.max(m.height + 2 * pad-y, body-min-h)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 40pt))
  let total-h = spec.at("height", default: body-h + 2 * cap-h)

  let stroke = 0.9pt + black
  let content = block(width: total-w, height: total-h, breakable: false, {
    // Body rectangle (no top, no bottom — caps cover them).
    place(top + left, dy: cap-h,
      rect(width: total-w, height: total-h - 2 * cap-h, fill: fill, stroke: none))
    // Side strokes.
    place(top + left, dx: 0pt, dy: cap-h,
      line(start: (0pt, 0pt), end: (0pt, total-h - 2 * cap-h), stroke: stroke))
    place(top + left, dx: total-w, dy: cap-h,
      line(start: (0pt, 0pt), end: (0pt, total-h - 2 * cap-h), stroke: stroke))
    // Top ellipse (full, fills the top cap region).
    place(top + left, dy: 0pt,
      ellipse(width: total-w, height: 2 * cap-h, fill: fill, stroke: stroke))
    // Bottom curve: just the front half of an ellipse.
    place(top + left, dy: total-h - 2 * cap-h,
      ellipse(width: total-w, height: 2 * cap-h, fill: fill, stroke: stroke))
    // Hide the back-half of the bottom ellipse by overlaying a rectangle
    // that's transparent on top of the body but covers the upper half of
    // the bottom ellipse's bounding box. (Typst doesn't have arc paths
    // first-class, so we approximate.)
    place(top + left, dy: total-h - 2 * cap-h,
      rect(width: total-w, height: cap-h, fill: fill, stroke: none))
    // Re-stroke the visible top edge of the bottom ellipse (its widest
    // line, which is the body's bottom edge).
    place(top + left, dy: total-h - 2 * cap-h,
      line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: stroke))
    // Centered label.
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a UML2 component box: a rectangle with the small two-tab icon
// in the top-right corner. Label is centered.
#let _layout-component(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let icon-w = 12pt
  let icon-h = 10pt
  let icon-margin = 4pt
  let total-w = spec.at(
    "width",
    default: m.width + 2 * pad-x + icon-w + icon-margin,
  )
  let total-h = spec.at("height", default: m.height + 2 * pad-y)
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    // Two-tab icon at top-right.
    let icon-x = total-w - icon-w - icon-margin
    let icon-y = icon-margin
    // Lower tab.
    place(top + left, dx: icon-x, dy: icon-y + icon-h * 0.45,
      rect(width: icon-w, height: icon-h * 0.4, fill: fill, stroke: stroke))
    // Upper tab.
    place(top + left, dx: icon-x, dy: icon-y,
      rect(width: icon-w, height: icon-h * 0.4, fill: fill, stroke: stroke))
    // Vertical spine of the icon (connects the tabs to the box edge).
    place(top + left, dx: icon-x + icon-w * 0.25, dy: icon-y,
      line(start: (0pt, 0pt), end: (0pt, icon-h), stroke: stroke))
    // Label.
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a deployment node: a 3D box with the top and right faces
// rendered in parallelogram-perspective. Label centered in the front
// face.
#let _layout-node(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  // Perspective offset for the 3D top/right faces.
  let depth = 6pt
  let front-w = calc.max(m.width + 2 * pad-x, 40pt)
  let front-h = calc.max(m.height + 2 * pad-y, 28pt)
  let total-w = spec.at("width", default: front-w + depth)
  let total-h = spec.at("height", default: front-h + depth)
  let stroke = 0.9pt + black

  let fw = total-w - depth
  let fh = total-h - depth

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Top face: parallelogram from (depth, 0) → (total-w, 0) →
    // (total-w - depth, depth) → (0, depth) but PlantUML's orientation
    // is "perspective right-and-up", so the top tilts away to the
    // upper-right.
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (depth, 0pt),
      (total-w, 0pt),
      (fw, depth),
      (0pt, depth),
    ))
    // Right face: from (total-w, 0) → (total-w, fh) → (fw, total-h) →
    // (fw, depth).
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (total-w, 0pt),
      (total-w, fh),
      (fw, total-h),
      (fw, depth),
    ))
    // Front face (drawn last so it's on top of the perspective seams).
    place(top + left, dx: 0pt, dy: depth,
      rect(width: fw, height: fh, fill: fill, stroke: stroke))
    // Label centered in the front face.
    place(top + left, dx: fw / 2 - m.width / 2, dy: depth + fh / 2 - m.height / 2, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: fw / 2,
    mid-y: depth + fh / 2,
    // Edge anchors clamp to the front face (where labels and arrows
    // visually attach); the back perspective faces are decorative.
    anchor-top: (fw / 2, depth),
    anchor-bot: (fw / 2, total-h),
    anchor-left: (0pt, depth + fh / 2),
    anchor-right: (fw, depth + fh / 2),
  )
}

// Lay out a use-case ellipse. PlantUML's `usecase Foo` / `(Foo)`
// renders as an oval with the label inside.
#let _layout-usecase(spec, fill) = {
  let pad-x = 12pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  // Ellipses need extra horizontal padding because the rounded ends
  // visually "shrink" the usable label space. PlantUML's heuristic is
  // roughly 1.5× wider than tall for a one-line label.
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 48pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 28pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + left,
      ellipse(width: total-w, height: total-h, fill: fill, stroke: stroke))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a cloud outline. Approximated with a sequence of overlapping
// circles forming a fluffy boundary, sized to fit the label.
#let _layout-cloud(spec, fill) = {
  let pad-x = 14pt
  let pad-y = 10pt
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 64pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 40pt))
  let stroke = 0.9pt + black

  // Cloud silhouette = three overlapping bumps along the top edge
  // backed by a flat-bottom curve. Approximate with a rounded box +
  // three filled circles on the top.
  let bump-r = total-h * 0.32
  let content = block(width: total-w, height: total-h, breakable: false, {
    // Base capsule, slightly inset so the bumps protrude.
    place(top + left, dx: bump-r * 0.4, dy: bump-r * 0.6,
      rect(width: total-w - bump-r * 0.8, height: total-h - bump-r * 0.6,
           fill: fill, stroke: stroke, radius: 10pt))
    // Three top bumps.
    place(top + left, dx: bump-r * 0.5, dy: 0pt,
      circle(radius: bump-r, fill: fill, stroke: stroke))
    place(top + left, dx: total-w / 2 - bump-r, dy: -bump-r * 0.15,
      circle(radius: bump-r * 1.1, fill: fill, stroke: stroke))
    place(top + left, dx: total-w - 2.5 * bump-r, dy: 0pt,
      circle(radius: bump-r, fill: fill, stroke: stroke))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a plain rectangle. PlantUML's most generic container /
// leaf shape — equivalent to `_layout-class` minus the compartment
// dividers and stereotype chip. Used directly for `rectangle Foo` and
// as the painter fallback for unimplemented USymbols.
#let _layout-rectangle(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 40pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 24pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a folder shape: a rectangle with a small tab on the top-left
// edge, matching PlantUML's `folder Foo`.
#let _layout-folder(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 8pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let tab-w = 18pt
  let tab-h = 6pt
  let tab-skew = 4pt
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 50pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y + tab-h, 32pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Body rectangle (below the tab).
    place(top + left, dy: tab-h,
      rect(width: total-w, height: total-h - tab-h, fill: fill, stroke: stroke))
    // Tab outline — trapezoid jutting up from the body's top edge.
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (0pt, tab-h),
      (0pt, 0pt),
      (tab-w - tab-skew, 0pt),
      (tab-w, tab-h),
    ))
    // Label centered in the body.
    place(top + left, dx: 0pt, dy: tab-h,
      block(width: total-w, height: total-h - tab-h,
        align(center + horizon, label)))
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: tab-h + (total-h - tab-h) / 2,
  )
}

// Lay out a UML frame: a rectangle with a small labeled notch in the
// top-left corner. PlantUML uses this for "package as frame" style.
#let _layout-frame(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 8pt
  let name = spec.at("name", default: [])
  let label-text = text(size: 0.8em, weight: "bold", name)
  let m = measure(label-text)
  let notch-w = m.width + 12pt
  let notch-h = m.height + 4pt
  let notch-corner = 4pt
  let total-w = spec.at("width", default: calc.max(notch-w + 16pt, 60pt))
  let total-h = spec.at("height", default: calc.max(notch-h + m.height + 2 * pad-y, 40pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    // Notch polygon: top-left corner with a stepped notch carved out.
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (0pt, 0pt),
      (notch-w, 0pt),
      (notch-w, notch-h - notch-corner),
      (notch-w - notch-corner, notch-h),
      (0pt, notch-h),
    ))
    place(top + left, dx: 6pt, dy: 2pt, label-text)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a file shape: a rectangle with the top-right corner folded
// down to form a small dog-ear. Matches PlantUML's `file Foo`.
#let _layout-file(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let fold = 10pt
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x + fold, 60pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 30pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Body: rectangle with the upper-right corner cut.
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (0pt, 0pt),
      (total-w - fold, 0pt),
      (total-w, fold),
      (total-w, total-h),
      (0pt, total-h),
    ))
    // Folded-corner triangle.
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (total-w - fold, 0pt),
      (total-w, fold),
      (total-w - fold, fold),
    ))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a queue — a horizontal cylinder (database rotated 90°),
// matching PlantUML's `queue Foo`. The label sits centered in the
// straight body, with rounded caps on the left and right.
#let _layout-queue(spec, fill) = {
  let pad-x = 6pt
  let pad-y = 4pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let cap-w = 6pt
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x + 2 * cap-w, 48pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 28pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Body rectangle (between caps).
    place(top + left, dx: cap-w, dy: 0pt,
      rect(width: total-w - 2 * cap-w, height: total-h, fill: fill, stroke: none))
    // Top and bottom strokes.
    place(top + left, dx: cap-w, dy: 0pt,
      line(start: (0pt, 0pt), end: (total-w - 2 * cap-w, 0pt), stroke: stroke))
    place(top + left, dx: cap-w, dy: total-h,
      line(start: (0pt, 0pt), end: (total-w - 2 * cap-w, 0pt), stroke: stroke))
    // Left cap (full ellipse).
    place(top + left, dx: 0pt, dy: 0pt,
      ellipse(width: 2 * cap-w, height: total-h, fill: fill, stroke: stroke))
    // Right cap (full ellipse — but the front-half is the visible part).
    place(top + left, dx: total-w - 2 * cap-w, dy: 0pt,
      ellipse(width: 2 * cap-w, height: total-h, fill: fill, stroke: stroke))
    // Mask the left-half of the right cap so the "back" curve is hidden.
    place(top + left, dx: total-w - 2 * cap-w, dy: 0pt,
      rect(width: cap-w, height: total-h, fill: fill, stroke: none))
    // Re-stroke the visible front of the right cap.
    place(top + left, dx: total-w - 2 * cap-w + cap-w, dy: 0pt,
      line(start: (0pt, 0pt), end: (0pt, total-h), stroke: stroke))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a storage — rounded capsule (pill). Matches PlantUML's
// `storage Foo`.
#let _layout-storage(spec, fill) = {
  let pad-x = 12pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 60pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 28pt))
  let radius = total-h / 2
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + left,
      rect(width: total-w, height: total-h, fill: fill, stroke: stroke,
           radius: radius))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a hexagon (6 sides). Matches PlantUML's `hexagon Foo`.
#let _layout-hexagon(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  // Hexagon proportions: 6 vertices, side cuts angle in 1/4 of the
  // total width on each side.
  let cut = 10pt
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x + 2 * cut, 56pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 30pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (cut, 0pt),
      (total-w - cut, 0pt),
      (total-w, total-h / 2),
      (total-w - cut, total-h),
      (cut, total-h),
      (0pt, total-h / 2),
    ))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a card — rounded rectangle. Matches PlantUML's `card Foo`.
#let _layout-card(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 50pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 28pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke, radius: 6pt)
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out an artifact: rectangle with a small folded-page icon
// in the top-right corner. PlantUML's `artifact Foo` shape.
#let _layout-artifact(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let icon-w = 10pt
  let icon-h = 12pt
  let icon-margin = 4pt
  let total-w = spec.at(
    "width",
    default: calc.max(m.width + 2 * pad-x + icon-w + icon-margin, 56pt),
  )
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 32pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    // Folded-page icon (top-right).
    let icon-x = total-w - icon-w - icon-margin
    let icon-y = icon-margin
    let fold = icon-w * 0.4
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (icon-x, icon-y),
      (icon-x + icon-w - fold, icon-y),
      (icon-x + icon-w, icon-y + fold),
      (icon-x + icon-w, icon-y + icon-h),
      (icon-x, icon-y + icon-h),
    ))
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (icon-x + icon-w - fold, icon-y),
      (icon-x + icon-w, icon-y + fold),
      (icon-x + icon-w - fold, icon-y + fold),
    ))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a collections: two stacked rectangles with the back one
// offset up-right. PlantUML's `collections Foo` shape.
#let _layout-collections(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let offset = 4pt
  // Effective inner width excludes the offset so the back layer
  // doesn't overhang the labeled face.
  let inner-w = calc.max(m.width + 2 * pad-x, 48pt)
  let inner-h = calc.max(m.height + 2 * pad-y, 26pt)
  let total-w = spec.at("width", default: inner-w + offset)
  let total-h = spec.at("height", default: inner-h + offset)
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Back rectangle (offset up-right).
    place(top + left, dx: offset, dy: 0pt,
      rect(width: inner-w, height: inner-h, fill: fill, stroke: stroke))
    // Front rectangle.
    place(top + left, dx: 0pt, dy: offset,
      rect(width: inner-w, height: inner-h, fill: fill, stroke: stroke))
    // Label centered on the front rectangle.
    place(top + left, dx: 0pt, dy: offset,
      block(width: inner-w, height: inner-h,
        align(center + horizon, label)))
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: inner-w / 2,
    mid-y: offset + inner-h / 2,
    // Anchor on the front rectangle (the labeled face), not the
    // overall bbox — otherwise edges would point at the back layer's
    // protruding corners.
    anchor-top: (inner-w / 2, offset),
    anchor-bot: (inner-w / 2, total-h),
    anchor-left: (0pt, offset + inner-h / 2),
    anchor-right: (inner-w, offset + inner-h / 2),
  )
}

// Lay out an action: rounded rectangle. PlantUML's `action Foo` shape.
// Visually similar to `card` but slightly tighter radius — a flow-block
// look rather than a card look.
#let _layout-action(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 50pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 26pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke,
         radius: 12pt)
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a process: chevron (arrow-shaped rectangle pointing right).
// PlantUML's `process Foo` shape — a workflow / pipeline step.
#let _layout-process(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  // Chevron tip protrudes from both left (concave) and right (convex)
  // ends. The label sits in the rectangular core.
  let tip = 8pt
  let core-w = calc.max(m.width + 2 * pad-x, 48pt)
  let total-w = spec.at("width", default: core-w + 2 * tip)
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y, 28pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (0pt, 0pt),
      (total-w - tip, 0pt),
      (total-w, total-h / 2),
      (total-w - tip, total-h),
      (0pt, total-h),
      (tip, total-h / 2),
    ))
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
    // Edges anchor on the rectangular core, not the chevron tips —
    // arrows pointing at the tip read as "the chevron's pointer",
    // not as a connection point.
    anchor-top: (total-w / 2, 0pt),
    anchor-bot: (total-w / 2, total-h),
    anchor-left: (tip, total-h / 2),
    anchor-right: (total-w - tip, total-h / 2),
  )
}

// Lay out a label: borderless text. PlantUML's `label Foo` shape —
// used for annotations that aren't entities. Renders as just the
// text with no surrounding box.
#let _layout-label(spec) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let total-w = spec.at("width", default: m.width)
  let total-h = spec.at("height", default: m.height)

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(center + horizon, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a stack: rectangle plus two thin horizontal lines at the
// bottom suggesting a stack of pages. PlantUML's `stack Foo` shape.
#let _layout-stack(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 6pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let m = measure(label)
  let stack-gap = 3pt
  let stack-lines = 2 * stack-gap
  let total-w = spec.at("width", default: calc.max(m.width + 2 * pad-x, 48pt))
  let total-h = spec.at("height", default: calc.max(m.height + 2 * pad-y + stack-lines, 30pt))
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    // Two thin horizontal "page edge" lines near the bottom.
    place(top + left, dx: 0pt, dy: total-h - stack-lines,
      line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: 0.5pt + black))
    place(top + left, dx: 0pt, dy: total-h - stack-gap,
      line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: 0.5pt + black))
    place(top + left, dx: 0pt, dy: 0pt,
      block(width: total-w, height: total-h - stack-lines,
        align(center + horizon, label)))
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: (total-h - stack-lines) / 2,
  )
}

// Lay out an agent: rectangle plus a small <<agent>> stereotype tag
// at the top. PlantUML's `agent Foo` shape.
#let _layout-agent(spec, fill) = {
  let pad-x = 10pt
  let pad-y = 4pt
  let name = spec.at("name", default: [])
  let label = text(weight: "bold", name)
  let stereo-text = text(size: 0.75em, fill: rgb("#666666"), "«agent»")
  let m = measure(label)
  let stereo-m = measure(stereo-text)
  let stereo-h = stereo-m.height + 2pt
  let total-w = spec.at(
    "width",
    default: calc.max(calc.max(m.width, stereo-m.width) + 2 * pad-x, 48pt),
  )
  let total-h = spec.at(
    "height",
    default: stereo-h + m.height + 2 * pad-y + 2pt,
  )
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    rect(width: total-w, height: total-h, fill: fill, stroke: stroke)
    place(top + center, dy: pad-y, stereo-text)
    place(top + center, dy: pad-y + stereo-h, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: total-w / 2,
    mid-y: total-h / 2,
  )
}

// Lay out a person (C4-style): a head circle on top of a body
// trapezoid. PlantUML's `person Foo` shape.
#let _layout-person(spec, fill) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let head-r = 7pt
  let body-h = 22pt
  let body-top-w = head-r * 2.4
  let body-bot-w = head-r * 4
  let person-h = head-r * 2 + body-h
  let person-w = body-bot-w
  let gap = 3pt
  let total-w = spec.at("width", default: calc.max(person-w, m.width))
  let total-h = spec.at("height", default: person-h + gap + m.height)
  let mid-x = total-w / 2
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Head circle.
    place(top + left, dx: mid-x - head-r, dy: 0pt,
      circle(radius: head-r, fill: fill, stroke: stroke))
    // Body trapezoid (narrow top, wide bottom).
    place(top + left, polygon(
      fill: fill, stroke: stroke,
      (mid-x - body-top-w / 2, head-r * 2),
      (mid-x + body-top-w / 2, head-r * 2),
      (mid-x + body-bot-w / 2, head-r * 2 + body-h),
      (mid-x - body-bot-w / 2, head-r * 2 + body-h),
    ))
    // Label below.
    place(top + center, dy: person-h + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: person-h / 2,
    anchor-top: (mid-x, 0pt),
    anchor-bot: (mid-x, person-h),
    anchor-left: (mid-x - body-bot-w / 2, person-h - body-h / 2),
    anchor-right: (mid-x + body-bot-w / 2, person-h - body-h / 2),
  )
}

// Lay out a boundary: a circle with a small T-shaped stick attached on
// its left. PlantUML's sequence-side `boundary Foo` symbol.
#let _layout-boundary(spec, fill) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let disc-r = 8pt
  let stick = 8pt
  let figure-h = disc-r * 2
  let figure-w = disc-r * 2 + stick
  let gap = 3pt
  let total-w = spec.at("width", default: calc.max(figure-w, m.width))
  let total-h = spec.at("height", default: figure-h + gap + m.height)
  let mid-x = total-w / 2
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Disc, offset right to make room for the stick.
    place(top + left, dx: mid-x - disc-r + stick / 2, dy: 0pt,
      circle(radius: disc-r, fill: fill, stroke: stroke))
    // T-stick: a horizontal stub + a vertical bar.
    let stick-x = mid-x - disc-r + stick / 2 - stick
    place(top + left, dx: stick-x, dy: disc-r,
      line(start: (0pt, 0pt), end: (stick, 0pt), stroke: stroke))
    place(top + left, dx: stick-x, dy: disc-r - stick / 2,
      line(start: (0pt, 0pt), end: (0pt, stick), stroke: stroke))
    // Label.
    place(top + center, dy: figure-h + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: figure-h / 2,
  )
}

// Lay out a control: a circle with a small upward arrow on the top
// edge. PlantUML's sequence-side `control Foo` symbol.
#let _layout-control(spec, fill) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let disc-r = 8pt
  let arrow = 4pt
  let figure-h = disc-r * 2 + arrow
  let figure-w = disc-r * 2
  let gap = 3pt
  let total-w = spec.at("width", default: calc.max(figure-w, m.width))
  let total-h = spec.at("height", default: figure-h + gap + m.height)
  let mid-x = total-w / 2
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    // Disc, offset down to make room for the arrow.
    place(top + left, dx: mid-x - disc-r, dy: arrow,
      circle(radius: disc-r, fill: fill, stroke: stroke))
    // Upward arrow on top.
    place(top + left, dx: mid-x, dy: arrow,
      line(start: (0pt, 0pt), end: (-arrow, -arrow), stroke: stroke))
    place(top + left, dx: mid-x, dy: arrow,
      line(start: (0pt, 0pt), end: (arrow, -arrow), stroke: stroke))
    // Label.
    place(top + center, dy: figure-h + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: figure-h / 2,
  )
}

// Lay out an entity-domain: a circle with an underline stripe at the
// bottom edge. PlantUML's sequence-side `entity Foo` (when in
// desc-flavor / sequence-flavor as opposed to class-flavor) symbol.
#let _layout-entity-domain(spec, fill) = {
  let name = spec.at("name", default: [])
  let label = text(name)
  let m = measure(label)
  let disc-r = 8pt
  let under-extra = 4pt
  let under-h = 2pt
  let figure-h = disc-r * 2 + under-h
  let figure-w = disc-r * 2 + 2 * under-extra
  let gap = 3pt
  let total-w = spec.at("width", default: calc.max(figure-w, m.width))
  let total-h = spec.at("height", default: figure-h + gap + m.height)
  let mid-x = total-w / 2
  let stroke = 0.9pt + black

  let content = block(width: total-w, height: total-h, breakable: false, {
    place(top + left, dx: mid-x - disc-r, dy: 0pt,
      circle(radius: disc-r, fill: fill, stroke: stroke))
    // Horizontal underline below the disc.
    place(top + left, dx: mid-x - disc-r - under-extra, dy: disc-r * 2,
      line(start: (0pt, 0pt), end: (disc-r * 2 + 2 * under-extra, 0pt), stroke: stroke))
    place(top + center, dy: figure-h + gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: figure-h / 2,
  )
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
  // The generic parameter list lives in a small dashed box at the
  // top-right corner of the class card (UML's signature look) — not
  // inline next to the name. When `hide-marker` is the only override
  // we still keep the corner box.
  let name-line = text(weight: "bold", name-body)

  // Marker glyph (the small `C` / `I` / `A` / … chip in the corner).
  // `hide-marker: true` on the spec suppresses it (used by `hide
  // circle` global directive). `marker-letter` / `marker-color` on the
  // spec override the kind defaults — used by PlantUML's
  // `<<(L, color) text>>` custom-marker syntax.
  let hide-marker = spec.at("hide-marker", default: false)
  let style = _kind-style(kind)
  let custom-letter = spec.at("marker-letter", default: none)
  let custom-color = spec.at("marker-color", default: none)
  let letter = if hide-marker { none }
               else if custom-letter != none { custom-letter }
               else { style.letter }
  let marker-fill = if custom-color != none { custom-color } else { style.fill }
  let marker-r = 0.55em.to-absolute()
  let marker = if letter == none { none } else {
    box(width: 2 * marker-r, height: 2 * marker-r, fill: marker-fill,
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
  let measured-total-w = content-w + 2 * pad-x

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
  let measured-total-h = name-h + fields-h + methods-h

  // Honor explicit width / height from codegen so the painter's mid-x
  // (used for edge anchoring) matches codegen's routing assumptions.
  // Without this the Typst measure of a class's text drifts from
  // codegen's text approximation by a few points and edges land off
  // the box centre.
  let total-w = spec.at("width", default: measured-total-w)
  let total-h = spec.at("height", default: measured-total-h)

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

      // Generic corner tag — small dashed box hovering at the top-right
      // corner with the parameter list inside (UML's signature look).
      // The box overlaps the class corner so codegen's bbox needs no
      // extra allowance for it.
      if generic != none {
        let g-text = text(size: 0.7em, generic)
        let gm = measure(g-text)
        let gpad = 1.5pt
        let gw = gm.width + 2 * gpad
        let gh = gm.height + 2 * gpad
        // Bottom-left of the corner box sits at (total-w - gw + 6pt,
        // -gh/2): the box hangs ~half a height above the top edge and
        // overlaps ~6pt back into the class's right side.
        let gx = total-w - gw + 6pt
        let gy = 0pt - gh / 2
        place(top + left, dx: gx, dy: gy,
          box(width: gw, height: gh,
              fill: white,
              stroke: (paint: black, thickness: 0.4pt, dash: "dashed"),
              place(center + horizon, g-text)))
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
  } else if head == "socket-open" or head == "socket-closed" {
    // Component-interface socket: a half-circle ARC whose open side
    // faces the line direction (i.e. "cups" the incoming line). The
    // arc center is offset OUTWARD from the tip so the cup opens toward
    // the source. Approximated with an arc-shaped polygon — Typst's
    // primitive `circle` doesn't support arc spans, so we draw a full
    // circle and overlay a rectangle to mask the unwanted half.
    let r = head-size * 0.55
    // Center sits past the tip in the line's direction (so the open
    // side faces back toward the source).
    let cx = tip-x + ux * r
    let cy = tip-y + uy * r
    place(top + left, dx: cx - r, dy: cy - r,
      circle(radius: r, fill: none, stroke: thickness + color))
    // Mask the "back" half (the half on the far side of the tip from
    // the source) by overlaying a rectangle in bg-color.
    let mask-half = r + thickness.to-absolute()
    let mask-cx = cx + ux * (mask-half / 2)
    let mask-cy = cy + uy * (mask-half / 2)
    let mask-w = if calc.abs(ux) > 0.5 { mask-half } else { 2 * r + 2pt }
    let mask-h = if calc.abs(uy) > 0.5 { mask-half } else { 2 * r + 2pt }
    place(top + left,
      dx: mask-cx - mask-w / 2,
      dy: mask-cy - mask-h / 2,
      rect(width: mask-w, height: mask-h, fill: bg-color, stroke: none))
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
  from-side: none, to-side: none,
) = {
  let n = segments.len()
  if n == 0 { return }

  // The painter-side endpoints are snapped to the rendered class
  // geometry, which can drift from codegen's estimate. The two boundary
  // control handles compensate differently:
  //   • first c1: collapsed onto the launch axis dictated by `from-side`
  //     so the head tangent is axis-aligned and never degenerate. For
  //     top/bot (the TB default) that's the vertical axis; for left/right
  //     it's horizontal.
  //   • last c2: translated by (end - last.end) so the codegen-emitted
  //     incoming tangent is preserved against the snapped endpoint, then
  //     collapsed onto the arrival axis dictated by `to-side` for the
  //     same reason.
  let from-horizontal = from-side == "left" or from-side == "right"
  let to-horizontal = to-side == "left" or to-side == "right"
  let first-c1 = if from-horizontal {
    (segments.at(0).c1.at(0), start.at(1))
  } else {
    (start.at(0), segments.at(0).c1.at(1))
  }
  let last = segments.at(n - 1)
  let last-c2-translated = (
    last.c2.at(0) + end.at(0) - last.end.at(0),
    last.c2.at(1) + end.at(1) - last.end.at(1),
  )
  let last-c2 = if to-horizontal {
    (last-c2-translated.at(0), end.at(1))
  } else {
    (end.at(0), last-c2-translated.at(1))
  }

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

// Returns true iff the rect (x, y, x+w, y+h) overlaps any class /
// note / lollipop bbox in `classes` × `metas`.
#let _overlaps-any-class(x, y, w, h, classes, metas) = {
  let hit = false
  for i in range(classes.len()) {
    let r = classes.at(i)
    let mw = metas.at(i).width
    let mh = metas.at(i).height
    let cx = r.x
    let cy = r.y
    if not (x + w <= cx or x >= cx + mw
            or y + h <= cy or y >= cy + mh) {
      hit = true
      break
    }
  }
  hit
}

// Place an edge label centered on a parametric position along the
// chord. `t` ∈ [0, 1]: 0 = start anchor, 1 = end anchor. `perp` shifts
// the label perpendicular to the edge — positive values drift to the
// chord's left (using the (dx, dy) → (-dy, dx) 90° CCW rotation).
//
// If `classes` and `metas` are non-empty, the label's bbox is checked
// against every class bbox; on overlap the perp offset is doubled,
// then doubled again, before falling back to the original position
// (some overlap may remain in dense diagrams — proper avoidance needs
// a layout solver).
#let _place-edge-label(start, end, t, body, perp: 0pt,
                       classes: (), metas: (), shift-x: 0pt, shift-y: 0pt) = {
  if body == none { return }
  let dx = end.at(0) - start.at(0)
  let dy = end.at(1) - start.at(1)
  let len-pt = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt))
  let (px, py) = if len-pt == 0 { (0, 0) }
    else { (-dy / (len-pt * 1pt), dx / (len-pt * 1pt)) }
  let lbl = box(inset: 2pt, fill: rgb("#FFFFFFCC"),
    text(size: 0.78em, fill: palettes.base.text, body))
  let m = measure(lbl)

  // Pick the first perp offset whose label bbox doesn't clip a class.
  let perps = if perp == 0pt {
    (0pt, 12pt, -12pt, 24pt)
  } else {
    (perp, perp * 1.8, perp * 2.6)
  }
  let chosen-perp = perp
  let found = false
  for p in perps {
    if not found {
      let x = start.at(0) + dx * t + px * p - m.width / 2
      let y = start.at(1) + dy * t + py * p - m.height / 2
      let check-x = x - shift-x
      let check-y = y - shift-y
      let collides = (classes.len() != 0) and _overlaps-any-class(
        check-x, check-y, m.width, m.height, classes, metas)
      if not collides {
        chosen-perp = p
        found = true
      }
    }
  }
  let x = start.at(0) + dx * t + px * chosen-perp - m.width / 2
  let y = start.at(1) + dy * t + py * chosen-perp - m.height / 2
  place(top + left, dx: x, dy: y, lbl)
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
  packages: (),
  direction: "tb",
  bg-color: white,
  default-fill: rgb("#FEFECE"),
  stroke: 1pt + black,
  inner-stroke: 0.5pt + black,
  radius: 4pt,
  inset: (x: 0.6em, y: 0.3em),
  edge-color: black,
  edge-thickness: 0.8pt,
  head-size: 6pt,
  package-stroke: 0.6pt + rgb("#888888"),
  package-fill: rgb("#FAFAFA"),
) = context {
  let head-size = head-size.to-absolute()

  let metas = classes.map(spec => {
    let kind = spec.at("kind", default: "class")
    let cls-fill = spec.at("fill", default: default-fill)
    if kind == "note" {
      _layout-note(spec, inset)
    } else if kind == "lollipop" or kind == "circle" {
      _layout-lollipop(spec)
    } else if kind == "actor" {
      _layout-actor(spec)
    } else if kind == "database" {
      _layout-database(spec, cls-fill)
    } else if kind == "component" {
      _layout-component(spec, cls-fill)
    } else if kind == "node" {
      _layout-node(spec, cls-fill)
    } else if kind == "usecase" {
      _layout-usecase(spec, cls-fill)
    } else if kind == "cloud" {
      _layout-cloud(spec, cls-fill)
    } else if kind == "rectangle" {
      _layout-rectangle(spec, cls-fill)
    } else if kind == "folder" {
      _layout-folder(spec, cls-fill)
    } else if kind == "frame" {
      _layout-frame(spec, cls-fill)
    } else if kind == "file" {
      _layout-file(spec, cls-fill)
    } else if kind == "queue" {
      _layout-queue(spec, cls-fill)
    } else if kind == "storage" {
      _layout-storage(spec, cls-fill)
    } else if kind == "hexagon" {
      _layout-hexagon(spec, cls-fill)
    } else if kind == "card" {
      _layout-card(spec, cls-fill)
    } else if kind == "artifact" {
      _layout-artifact(spec, cls-fill)
    } else if kind == "collections" {
      _layout-collections(spec, cls-fill)
    } else if kind == "action" {
      _layout-action(spec, cls-fill)
    } else if kind == "process" {
      _layout-process(spec, cls-fill)
    } else if kind == "label" {
      _layout-label(spec)
    } else if kind == "stack" {
      _layout-stack(spec, cls-fill)
    } else if kind == "agent" {
      _layout-agent(spec, cls-fill)
    } else if kind == "person" {
      _layout-person(spec, cls-fill)
    } else if kind == "boundary" {
      _layout-boundary(spec, cls-fill)
    } else if kind == "control" {
      _layout-control(spec, cls-fill)
    } else if kind == "entity-domain" {
      _layout-entity-domain(spec, cls-fill)
    } else {
      _layout-class(spec, cls-fill, stroke, inner-stroke, radius, inset)
    }
  })

  let is-lr = direction == "lr"
  // Edge anchors snapped to the painter's measured geometry. Each meta
  // may declare `anchor-{top,bot,left,right}` points relative to its
  // local frame (lollipops use this so edges attach to the disc,
  // not below the label that hangs off the layout box). When absent
  // we fall back to the box midpoints.
  let local-anchor(i, side) = {
    let m = metas.at(i)
    let key = "anchor-" + side
    if key in m {
      m.at(key)
    } else if side == "top" {
      (m.mid-x, 0pt)
    } else if side == "bot" {
      (m.mid-x, m.height)
    } else if side == "left" {
      (0pt, m.mid-y)
    } else { // "right"
      (m.width, m.mid-y)
    }
  }
  let world-anchor(i, side) = {
    let local = local-anchor(i, side)
    (classes.at(i).x + local.at(0), classes.at(i).y + local.at(1))
  }
  // Per-edge `from-side` / `to-side` overrides take precedence (so
  // sibling-cluster edges that go side-to-side don't get forced into
  // bot/top anchoring). The defaults follow `direction`. An optional
  // `from-x` / `from-y` / `to-x` / `to-y` overrides the anchor's
  // free-axis coordinate (y for left/right sides, x for top/bot)
  // — codegen sets this when it wants to align both anchors so the
  // Manhattan route collapses to a single segment.
  let default-from-side = if is-lr { "right" } else { "bot" }
  let default-to-side = if is-lr { "left" } else { "top" }
  let resolved-anchor(i, side, override-x, override-y) = {
    let p = world-anchor(i, side)
    let px = p.at(0)
    let py = p.at(1)
    if (side == "top" or side == "bot") and override-x != none {
      px = override-x
    }
    if (side == "left" or side == "right") and override-y != none {
      py = override-y
    }
    (px, py)
  }
  let from-anchor(i, override-side) = resolved-anchor(
    i,
    if override-side != none { override-side } else { default-from-side },
    none, none,
  )
  let to-anchor(i, override-side) = resolved-anchor(
    i,
    if override-side != none { override-side } else { default-to-side },
    none, none,
  )

  // Canvas size = farthest extent across classes, packages, and bezier
  // handles. Packages can extend further than their members because of
  // their padding band; include them explicitly. Classes (and edge
  // handles) can also dip into negative x/y when codegen has pushed
  // an association class past the chord — the shift below compensates.
  let canvas-x0 = 0pt
  let canvas-y0 = 0pt
  let canvas-w = 0pt
  let canvas-h = 0pt
  for i in range(classes.len()) {
    let r = classes.at(i)
    let m = metas.at(i)
    canvas-w = calc.max(canvas-w, r.x + m.width)
    canvas-h = calc.max(canvas-h, r.y + m.height)
    canvas-x0 = calc.min(canvas-x0, r.x)
    canvas-y0 = calc.min(canvas-y0, r.y)
  }
  for p in packages {
    canvas-w = calc.max(canvas-w, p.x + p.w)
    canvas-h = calc.max(canvas-h, p.y + p.h)
    canvas-x0 = calc.min(canvas-x0, p.x)
    canvas-y0 = calc.min(canvas-y0, p.y)
  }
  for e in edges {
    for seg in e.path {
      for p in (seg.c1, seg.c2, seg.end) {
        canvas-w = calc.max(canvas-w, p.at(0))
        canvas-h = calc.max(canvas-h, p.at(1))
      }
    }
  }

  // If any package extends to negative coords (its outer pad pushes left
  // / above the layout origin), shift everything right / down so the
  // resulting block doesn't clip.
  let shift-x = if canvas-x0 < 0pt { -canvas-x0 } else { 0pt }
  let shift-y = if canvas-y0 < 0pt { -canvas-y0 } else { 0pt }
  let final-w = canvas-w + shift-x
  let final-h = canvas-h + shift-y

  let body = block(width: final-w, height: final-h, breakable: false, {
    // Packages first, so classes draw on top of the labeled rectangles.
    // `together` is anonymous and rendered with no fill / dashed border
    // to visually mark it as a soft hint rather than a real container.
    for p in packages {
      let kind = p.at("kind", default: "package")
      let label = p.at("label", default: [])
      let stereotype = p.at("stereotype", default: none)
      let is-together = kind == "together"
      let pkg-fill = if is-together { none } else { package-fill }
      let pkg-stroke = if is-together {
        (paint: rgb("#999999"), thickness: 0.5pt, dash: "dashed")
      } else { package-stroke }
      place(top + left, dx: p.x + shift-x, dy: p.y + shift-y,
        rect(width: p.w, height: p.h, fill: pkg-fill, stroke: pkg-stroke,
          radius: 3pt))
      if not is-together and label != [] {
        // Header strip at the top of the rectangle (~14pt). Label is
        // bold, slight inset from the left.
        place(top + left, dx: p.x + shift-x + 6pt, dy: p.y + shift-y + 2pt,
          text(weight: "bold", size: 0.85em, label))
      }
      if stereotype != none {
        place(top + right, dx: -(final-w - (p.x + shift-x + p.w)) - 6pt,
              dy: p.y + shift-y + 2pt,
          text(size: 0.7em, fill: rgb("#666666"), [«#stereotype»]))
      }
    }
    // Classes.
    for i in range(classes.len()) {
      let r = classes.at(i)
      place(top + left, dx: r.x + shift-x, dy: r.y + shift-y, metas.at(i).content)
    }
    // Edges. Source = bottom-mid of `from`; target = top-mid of `to`.
    // Codegen ensures Sugiyama TB ordering so this anchoring is sane;
    // see codegen/class.rs::orient_relation for the swap rule.
    let shift-pt(p) = (p.at(0) + shift-x, p.at(1) + shift-y)
    for e in edges {
      // Couple-link edges (`(A, B) -- C`) carry an explicit `start` and
      // a `from-couple: (a, b)` index pair instead of `from`. We honor
      // the explicit start; the regular `from` lookup is skipped.
      let raw-start = if e.at("from", default: none) == none {
        e.at("start")
      } else {
        resolved-anchor(
          e.from,
          if "from-side" in e { e.from-side } else { default-from-side },
          e.at("from-x", default: none),
          e.at("from-y", default: none),
        )
      }
      let raw-end = resolved-anchor(
        e.to,
        if "to-side" in e { e.to-side } else { default-to-side },
        e.at("to-x", default: none),
        e.at("to-y", default: none),
      )
      let start = shift-pt(raw-start)
      let end = shift-pt(raw-end)
      // Path segments need the same shift since they're absolute coords.
      let shifted-path = e.path.map(seg => (
        c1: shift-pt(seg.c1),
        c2: shift-pt(seg.c2),
        end: shift-pt(seg.end),
      ))
      let style = e.at("style", default: "solid")
      let color = e.at("color", default: edge-color)
      _draw-edge(
        start, shifted-path, end,
        e.at("head-from", default: "none"),
        e.at("head-to", default: "none"),
        style, color, bg-color, edge-thickness, head-size,
        from-side: if "from-side" in e { e.from-side } else { default-from-side },
        to-side: if "to-side" in e { e.to-side } else { default-to-side },
      )
      // Couple-link "apoint" — small filled dot on the A-B chord
      // marking where the association class is attached. PlantUML
      // renders this as a 2pt black disc.
      if e.at("from-couple", default: none) != none {
        let dot-r = 1.5pt
        place(top + left,
          dx: start.at(0) - dot-r, dy: start.at(1) - dot-r,
          circle(radius: dot-r, fill: color, stroke: none))
      }
      _place-edge-label(start, end, 0.5, e.at("label", default: none),
        classes: classes, metas: metas, shift-x: shift-x, shift-y: shift-y)
      // Mult and role share the same `t`; they're split apart by a small
      // perpendicular offset so both fit beside the edge without
      // overlapping. Positive perp = chord's left, negative = right.
      _place-edge-label(start, end, 0.12, e.at("mult-from", default: none),
        perp: 10pt,
        classes: classes, metas: metas, shift-x: shift-x, shift-y: shift-y)
      _place-edge-label(start, end, 0.12, e.at("role-from", default: none),
        perp: -10pt,
        classes: classes, metas: metas, shift-x: shift-x, shift-y: shift-y)
      _place-edge-label(start, end, 0.88, e.at("mult-to", default: none),
        perp: 10pt,
        classes: classes, metas: metas, shift-x: shift-x, shift-y: shift-y)
      _place-edge-label(start, end, 0.88, e.at("role-to", default: none),
        perp: -10pt,
        classes: classes, metas: metas, shift-x: shift-x, shift-y: shift-y)
      // `note on link`: a tiny yellow sticky next to the chord midpoint.
      let edge-note = e.at("note", default: none)
      if edge-note != none {
        let mx = start.at(0) + (end.at(0) - start.at(0)) * 0.5
        let my = start.at(1) + (end.at(1) - start.at(1)) * 0.5
        let nbody = text(size: 0.78em, edge-note)
        let nm = measure(nbody)
        let pad = 2pt
        let nw = nm.width + 2 * pad
        let nh = nm.height + 2 * pad
        // Offset perpendicular to the chord so the sticky doesn't sit
        // on top of the line.
        let dx = end.at(0) - start.at(0)
        let dy = end.at(1) - start.at(1)
        let len-pt = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt))
        let (px, py) = if len-pt == 0 { (0, 0) }
          else { (-dy / (len-pt * 1pt), dx / (len-pt * 1pt)) }
        let off = 14pt
        place(top + left,
          dx: mx + px * off - nw / 2,
          dy: my + py * off - nh / 2,
          box(width: nw, height: nh,
              fill: rgb("#FBFB77"),
              stroke: 0.4pt + rgb("#9C9C40"),
              place(center + horizon, nbody)))
      }
    }
  })

  if title != none {
    align(center)[#strong(title)]
    v(0.5em, weak: true)
  }
  body
}

// ============================================================================
// Measure protocol
// ============================================================================
//
// `class-probe` measures the natural width / height of a single class /
// note / lollipop spec — the exact same value `class-layout` would
// compute for `total-w` / `total-h` when codegen does NOT pass `width:` /
// `height:` overrides. It emits a `metadata((id, w, h))` element with
// the `<typstuml_measure>` label; the TypstUML Rust runtime queries
// this label after a pass-1 compile to read measurements back into the
// layout pipeline.
//
// Caller contract: `spec` MUST NOT carry `width:` / `height:` (those
// would short-circuit the natural-size computation). `x:` / `y:` are
// ignored if present.
//
// Defaults for `inset` MUST stay in sync with `class-layout`'s defaults
// above — pass-1 and pass-2 must use byte-identical inset for the
// measurement to be meaningful. Codegen should always pass `inset:` to
// both ends if it customizes the value.
#let class-probe(
  id: none,
  spec: (:),
  inset: (x: 0.6em, y: 0.3em),
) = context {
  let kind = spec.at("kind", default: "class")
  let m = if kind == "note" {
    _layout-note(spec, inset)
  } else if kind == "lollipop" or kind == "circle" {
    _layout-lollipop(spec)
  } else if kind == "actor" {
    _layout-actor(spec)
  } else if kind == "database" {
    _layout-database(spec, white)
  } else if kind == "component" {
    _layout-component(spec, white)
  } else if kind == "node" {
    _layout-node(spec, white)
  } else if kind == "usecase" {
    _layout-usecase(spec, white)
  } else if kind == "cloud" {
    _layout-cloud(spec, white)
  } else if kind == "rectangle" {
    _layout-rectangle(spec, white)
  } else if kind == "folder" {
    _layout-folder(spec, white)
  } else if kind == "frame" {
    _layout-frame(spec, white)
  } else if kind == "file" {
    _layout-file(spec, white)
  } else if kind == "queue" {
    _layout-queue(spec, white)
  } else if kind == "storage" {
    _layout-storage(spec, white)
  } else if kind == "hexagon" {
    _layout-hexagon(spec, white)
  } else if kind == "card" {
    _layout-card(spec, white)
  } else if kind == "artifact" {
    _layout-artifact(spec, white)
  } else if kind == "collections" {
    _layout-collections(spec, white)
  } else if kind == "action" {
    _layout-action(spec, white)
  } else if kind == "process" {
    _layout-process(spec, white)
  } else if kind == "label" {
    _layout-label(spec)
  } else if kind == "stack" {
    _layout-stack(spec, white)
  } else if kind == "agent" {
    _layout-agent(spec, white)
  } else if kind == "person" {
    _layout-person(spec, white)
  } else if kind == "boundary" {
    _layout-boundary(spec, white)
  } else if kind == "control" {
    _layout-control(spec, white)
  } else if kind == "entity-domain" {
    _layout-entity-domain(spec, white)
  } else {
    // Use neutral theme args — they don't affect measurement, only paint.
    _layout-class(spec, white, 1pt + black, 0.5pt + black, 4pt, inset)
  }
  [#metadata((id: id, w: m.width.pt(), h: m.height.pt())) <typstuml_measure>]
}

// Measure the *label content* of a `package` / `namespace` / similar
// container as `class-layout`'s package painter would render it: bold
// 0.85em text, no insets included. Callers add the painter's left /
// right / top / bottom margins themselves to derive the outer band
// dimensions.
//
// Returns w / h as float pt via the `<typstuml_measure>` metadata
// channel.
#let package-probe(
  id: none,
  label: [],
) = context {
  let m = measure(text(weight: "bold", size: 0.85em, label))
  [#metadata((id: id, w: m.width.pt(), h: m.height.pt())) <typstuml_measure>]
}

