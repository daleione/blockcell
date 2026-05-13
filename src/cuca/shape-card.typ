// ============================================================================
// Class-card family painters: the 3-compartment class card plus its
// companions (note sticky, lollipop interface).
// ============================================================================
//
// All three return the same dict shape
//   (content, width, height, mid-x, mid-y, [anchor-{top,bot,left,right}])
// that `cuca-layout` consumes, so callers treat the family uniformly.

#import "../palettes.typ": palettes
#import "theme.typ": _kind-style, _render-member

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

// Object diagram instance card — 2-compartment box (underlined name on
// top, `name = value` rows below). No marker chip, no method
// compartment, no generic corner box. `spec.fields` is a list of
// `(name, value)` dicts emitted by `src/codegen/cuca/emit.rs` for
// `EntityKindData::Object`.
#let _layout-object(spec, fill, stroke, inner-stroke, radius, inset) = {
  let pad-x = inset.at("x").to-absolute()
  let pad-y = inset.at("y").to-absolute()

  let name-body = spec.at("name", default: [])
  let stereo = spec.at("stereotype", default: none)
  let fields = spec.at("fields", default: ())

  let stereo-line = if stereo == none { none } else {
    text(size: 0.78em, fill: palettes.base.text-muted, [«#stereo»])
  }
  // PlantUML object diagrams underline the instance name (UML
  // convention for distinguishing an instance from its class).
  let name-line = text(weight: "bold", underline(name-body))

  // Field rows are pre-joined `name = value` content blocks emitted by
  // codegen so the painter doesn't need to concatenate (which throws
  // off inline `measure`).
  let field-bodies = fields

  let stereo-m = if stereo-line == none { (width: 0pt, height: 0pt) }
                 else { measure(stereo-line) }
  let name-m = measure(name-line)
  let field-ms = field-bodies.map(measure)

  let content-w = (
    (calc.max(stereo-m.width, name-m.width),) + field-ms.map(m => m.width)
  ).fold(0pt, (a, w) => calc.max(a, w))
  let measured-total-w = content-w + 2 * pad-x

  let stereo-gap = if stereo-line == none { 0pt } else { 0.2em.to-absolute() }
  let stereo-h = if stereo-line == none { 0pt } else { stereo-m.height + stereo-gap }
  let name-row-h = name-m.height
  let name-h = stereo-h + name-row-h + 2 * pad-y
  let row-h(ms) = ms.fold(0pt, (acc, m) => acc + m.height + 2 * pad-y)
  let fields-h = if fields.len() == 0 { 0pt } else { row-h(field-ms) }
  let measured-total-h = name-h + fields-h

  let total-w = spec.at("width", default: measured-total-w)
  let total-h = spec.at("height", default: measured-total-h)

  let body = box(
    width: total-w, height: total-h,
    fill: fill, stroke: stroke, radius: radius,
    {
      // Compartment separator between name row and fields.
      if fields-h > 0pt {
        place(top + left, dx: 0pt, dy: name-h,
          line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: inner-stroke))
      }

      if stereo-line != none {
        place(top + left, dx: pad-x, dy: pad-y, stereo-line)
      }

      // Name row, centered horizontally.
      let name-row-top = pad-y + stereo-h
      place(top + center, dy: name-row-top, name-line)

      let cy = name-h + pad-y
      for (i, b) in field-bodies.enumerate() {
        place(top + left, dx: pad-x, dy: cy, b)
        cy = cy + field-ms.at(i).height + 2 * pad-y
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
