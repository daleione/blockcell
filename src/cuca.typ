// ============================================================================
// Cuca (description-family) diagrams: class / object / component /
// deployment / use case. Compartment / shape entities linked by arrows
// whose head shape encodes UML semantics (extends / aggregation /
// composition / association / dependency / interface socket).
// ============================================================================
//
// cuca-layout  Painter for cuca diagrams whose entity positions and edge
//              bezier paths are computed externally (TypstUML's
//              codegen/cuca). The painter is a pure layout consumer: it
//              does not run any graph algorithm. Codegen estimates per-
//              entity bboxes, runs Sugiyama (top-to-bottom rank
//              progression) and pathplan, and emits absolute positions
//              plus per-edge cubic-bezier segments.
//
// Implementation is split across `cuca/`:
//   theme.typ        kind→stereotype tint table + compartment row renderer
//   shape-card.typ   _layout-class / _layout-note / _layout-lollipop
//                    (the 3-compartment card family — the "real" class
//                    diagram core)
//   shape-desc.typ   the 27 desc-family shape painters (actor /
//                    component / database / node / usecase / cloud /
//                    rectangle / folder / frame / file / queue /
//                    storage / hexagon / card / artifact / collections /
//                    action / process / label / stack / agent / person /
//                    boundary / control / entity-domain)
//   edges.typ        edge head shapes, multi-segment bezier draw,
//                    label placement with class-bbox avoidance
// ============================================================================

#import "cuca/shape-card.typ": _layout-class, _layout-note, _layout-lollipop, _layout-object
#import "cuca/shape-desc.typ": *
#import "cuca/edges.typ": _draw-edge, _place-edge-label

// Resolve a kind string to a painter result. Shared by `cuca-layout`
// (which passes the spec's `fill` and the global stroke / radius / inset
// for class cards) and `cuca-probe` (which passes neutral theme args
// since measurement is paint-independent).
#let _paint(spec, default-fill, class-stroke, inner-stroke, radius, inset) = {
  let kind = spec.at("kind", default: "class")
  let cls-fill = spec.at("fill", default: default-fill)
  if kind == "note" {
    _layout-note(spec, inset)
  } else if kind == "object" {
    _layout-object(spec, cls-fill, class-stroke, inner-stroke, radius, inset)
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
    _layout-class(spec, cls-fill, class-stroke, inner-stroke, radius, inset)
  }
}

/// Painter for cuca diagrams whose entity positions and edge bezier
/// paths are computed by codegen (TypstUML's `codegen/cuca`).
///
/// ```typst
/// #cuca-layout(
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
#let cuca-layout(
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

  let metas = classes.map(spec =>
    _paint(spec, default-fill, stroke, inner-stroke, radius, inset))

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
    // For ellipse-shaped entities (usecase) the bbox corners sit
    // outside the visible silhouette, so an off-midpoint anchor lands
    // in a visible gap between the line end and the curved boundary.
    // Project the anchor onto the actual ellipse where it crosses the
    // override coord so the arrowhead sits flush with the shape.
    let kind = classes.at(i).at("kind", default: "")
    if kind == "usecase" {
      let m = metas.at(i)
      let cx = classes.at(i).x + m.mid-x
      let cy = classes.at(i).y + m.mid-y
      let a = m.width / 2
      let b = m.height / 2
      if (side == "left" or side == "right") and override-y != none {
        let dy = py - cy
        let frac = 1 - (dy / b) * (dy / b)
        if frac > 0 {
          let dx = a * calc.sqrt(frac)
          px = if side == "left" { cx - dx } else { cx + dx }
        }
      }
      if (side == "top" or side == "bot") and override-x != none {
        let dx = px - cx
        let frac = 1 - (dx / a) * (dx / a)
        if frac > 0 {
          let dy = b * calc.sqrt(frac)
          py = if side == "top" { cy - dy } else { cy + dy }
        }
      }
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
    // see codegen/cuca::orient_relation for the swap rule.
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
      let from-overridden = (e.at("from-x", default: none) != none) or (e.at("from-y", default: none) != none)
      let to-overridden = (e.at("to-x", default: none) != none) or (e.at("to-y", default: none) != none)
      _draw-edge(
        start, shifted-path, end,
        e.at("head-from", default: "none"),
        e.at("head-to", default: "none"),
        style, color, bg-color, edge-thickness, head-size,
        from-side: if "from-side" in e { e.from-side } else { default-from-side },
        to-side: if "to-side" in e { e.to-side } else { default-to-side },
        // When codegen explicitly placed the anchor (e.g. sibling
        // distribution along a shared face), trust its emitted tangent
        // and skip the axis collapse — otherwise the head would be
        // forced perpendicular to the face even when the line arrives
        // at a diagonal.
        from-axis-snap: not from-overridden,
        to-axis-snap: not to-overridden,
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
      let label-pos = e.at("label-pos", default: none)
      _place-edge-label(start, end, 0.5, e.at("label", default: none),
        label-pos: if label-pos == none { none } else { shift-pt(label-pos) },
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
// `cuca-probe` measures the natural width / height of a single entity
// spec — the exact same value `cuca-layout` would compute for `total-w` /
// `total-h` when codegen does NOT pass `width:` / `height:` overrides.
// It emits a `metadata((id, w, h))` element with the `<typstuml_measure>`
// label; the TypstUML Rust runtime queries this label after a pass-1
// compile to read measurements back into the layout pipeline.
//
// Caller contract: `spec` MUST NOT carry `width:` / `height:` (those
// would short-circuit the natural-size computation). `x:` / `y:` are
// ignored if present.
//
// Defaults for `inset` MUST stay in sync with `cuca-layout`'s defaults
// above — pass-1 and pass-2 must use byte-identical inset for the
// measurement to be meaningful. Codegen should always pass `inset:` to
// both ends if it customizes the value.
#let cuca-probe(
  id: none,
  spec: (:),
  inset: (x: 0.6em, y: 0.3em),
) = context {
  // Use neutral theme args — they don't affect measurement, only paint.
  let m = _paint(spec, white, 1pt + black, 0.5pt + black, 4pt, inset)
  [#metadata((id: id, w: m.width.pt(), h: m.height.pt())) <typstuml_measure>]
}

// Measure the *label content* of a `package` / `namespace` / similar
// container as `cuca-layout`'s package painter would render it: bold
// 0.85em text, no insets included. Callers add the painter's left /
// right / top / bottom margins themselves to derive the outer band
// dimensions.
//
// Returns w / h as float pt via the `<typstuml_measure>` metadata
// channel.
#let container-probe(
  id: none,
  label: [],
) = context {
  let m = measure(text(weight: "bold", size: 0.85em, label))
  [#metadata((id: id, w: m.width.pt(), h: m.height.pt())) <typstuml_measure>]
}
