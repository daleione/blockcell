// ============================================================================
// Desc-family shape painters: the 27 non-class entity shapes that
// PlantUML's class-flavor parser can name (component / node / database /
// usecase / cloud / rectangle / folder / frame / file / queue / storage /
// hexagon / card / artifact / collections / action / process / label /
// stack / agent / person / boundary / control / entity-domain / actor).
// ============================================================================
//
// All painters return the same dict shape
//   (content, width, height, mid-x, mid-y, [anchor-{top,bot,left,right}])
// as `_layout-class`, so the dispatcher in `cuca.typ` treats every shape
// uniformly. None of these consult the stereotype tint table — each
// shape carries its own visual identity and uses the `fill` argument
// straight from codegen.

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
  // Two independent spacings keep the figure visually balanced:
  // `top-gap` is the visible clearance between the leg tips and the
  // label glyphs; `bot-pad` is the breathing room between the label
  // and the bbox bottom (= edge attachment point), so a downward
  // outgoing arrow doesn't graze the descenders of the label text.
  let top-gap = 3pt
  let bot-pad = 4pt
  let total-w = calc.max(stickman-w, m.width)
  let total-h = stickman-h + top-gap + m.height + bot-pad
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
    place(top + center, dy: stickman-h + top-gap, label)
  })

  (
    content: content,
    width: total-w,
    height: total-h,
    mid-x: mid-x,
    mid-y: stickman-h / 2,
    // Edge anchors. Top is at the head, left/right at the arms — both
    // sit on the silhouette so heads cup the figure cleanly. Bottom
    // must be below the label, otherwise a downward outgoing edge
    // crosses through the label text on its way out of the bbox.
    anchor-top: (mid-x, 0pt),
    anchor-bot: (mid-x, total-h),
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
