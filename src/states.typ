// ============================================================================
// UML state-machine diagrams.
// ============================================================================
//
// `state-layout` is the single painter entry point for PlantUML state
// diagrams. Codegen does the layout (Sugiyama-derived placement + per-node
// sizing) and hands this painter absolute coordinates; the painter only
// draws shapes, edges, and labels.
//
// Node `kind` values:
//   simple / composite  rounded rectangle, optional `entry/exit/do` body rows
//   initial             small filled circle
//   final               ringed filled circle
//   choice              diamond
//   fork / join         solid bar
//   history             circle with "H"
//   deep-history        circle with "H*"
//   synchro-bar         thin solid bar
//
// Painting is three-pass: edge geometry under the nodes (so a line crossing
// an unrelated node is masked by its fill), nodes, then edge labels on top
// (so a label landing on a node stays legible).
// ============================================================================

#import "palettes.typ": palettes

#let _state-fill = rgb("#FDFDF5")
#let _state-stroke = 0.9pt + luma(70)
#let _pseudo-fill = luma(40)
#let _text-fill = luma(20)
#let _muted = palettes.base.text-muted
#let _body-size = 0.82em
#let _label-size = 0.78em

// Reassemble an `event [guard] / action` label from its three optional
// parts. Returns `none` when all three are empty.
#let _join-label(event, guard, action) = {
  let parts = ()
  if event != none and event != "" { parts.push(event) }
  if guard != none and guard != "" { parts.push("[" + guard + "]") }
  let head = parts.join(" ")
  if action != none and action != "" {
    if head == "" { head = "/ " + action } else { head = head + " / " + action }
  }
  if head == "" { none } else { head }
}

// Turn a label string into content, rendering a literal `\n` (the two
// characters backslash + n, as written in PlantUML source) as a line
// break. Used for multi-line transition labels and state names.
#let _with-breaks(s) = {
  if s == none { return none }
  s.split("\\n").map(part => part).join(linebreak())
}

// Resolve a node's border stroke from its `border-style` / `border-color`.
#let _node-stroke(n) = {
  let bs = n.at("border-style", default: "solid")
  let bc = n.at("border-color", default: none)
  let paint = if bc == none { luma(70) } else { bc }
  let thickness = if bs == "bold" { 1.8pt } else { 0.9pt }
  let dash = if bs == "dashed" { "dashed" } else if bs == "dotted" { "dotted" } else { none }
  (paint: paint, thickness: thickness, dash: dash)
}

// Place a triangular arrow head with its tip at (tx, ty) aimed along the
// direction vector (dx, dy). `dx` / `dy` are lengths.
#let _place-head(tx, ty, dx, dy, paint) = {
  let dxf = dx / 1pt
  let dyf = dy / 1pt
  let len = calc.sqrt(dxf * dxf + dyf * dyf)
  if len < 0.0001 { return }
  let ux = dxf / len
  let uy = dyf / len
  let h = 7pt
  let w = 3.4pt
  // base center is behind the tip along -u; the two wings are ±perp.
  let bx = tx - ux * h
  let by = ty - uy * h
  let px = -uy
  let py = ux
  place(top + left, polygon(
    fill: paint,
    stroke: none,
    (tx, ty),
    (bx + px * w, by + py * w),
    (bx - px * w, by - py * w),
  ))
}

// Clip the ray from a node's center toward `(tx, ty)` to the node's
// perimeter. `shape` is "rect" | "circle" | "diamond".
#let _perimeter(cx, cy, hw, hh, shape, tx, ty) = {
  let dx = tx - cx
  let dy = ty - cy
  let adx = calc.abs(dx / 1pt)
  let ady = calc.abs(dy / 1pt)
  if adx < 0.0001 and ady < 0.0001 { return (cx, cy) }
  let t = if shape == "circle" {
    let r = calc.min(hw, hh)
    let len = calc.sqrt(adx * adx + ady * ady)
    r / (len * 1pt)
  } else if shape == "diamond" {
    1 / (adx / (hw / 1pt) + ady / (hh / 1pt))
  } else {
    // rect
    let tx-cand = if adx > 0.0001 { (hw / 1pt) / adx } else { 1e9 }
    let ty-cand = if ady > 0.0001 { (hh / 1pt) / ady } else { 1e9 }
    calc.min(tx-cand, ty-cand)
  }
  (cx + dx * t, cy + dy * t)
}

#let _shape-of(kind) = {
  if kind == "initial" or kind == "final" or kind == "history" or kind == "deep-history" {
    "circle"
  } else if kind == "choice" {
    "diamond"
  } else {
    "rect"
  }
}

// --------------------------------------------------------------------------
// Node renderers. Each draws within the box (x, y) .. (x + w, y + h).
// --------------------------------------------------------------------------

#let _render-simple(n) = {
  let body = n.at("body", default: ())
  let display = n.at("display", default: "")
  let fill = n.at("fill", default: none)
  let fill = if fill == none { _state-fill } else { fill }
  let stroke = _node-stroke(n)
  place(top + left, dx: n.x, dy: n.y, box(
    width: n.w,
    height: n.h,
    radius: 7pt,
    fill: fill,
    stroke: stroke,
    {
      if body.len() == 0 {
        // name vertically centered
        place(center + horizon, text(fill: _text-fill, _with-breaks(display)))
      } else {
        // name band on top, divider, body rows
        set text(fill: _text-fill)
        place(top + left, dx: 0pt, dy: 0pt, box(
          width: n.w,
          height: 1.9em,
          inset: (x: 6pt),
          align(left + horizon, _with-breaks(display)),
        ))
        place(top + left, dy: 1.9em, line(
          start: (0pt, 0pt),
          end: (n.w, 0pt),
          stroke: stroke,
        ))
        place(top + left, dy: 1.9em, box(
          width: n.w,
          inset: (x: 6pt, y: 4pt),
          text(size: _body-size, body.map(l => _with-breaks(l)).join(linebreak())),
        ))
      }
    },
  ))
}

#let _render-initial(n) = {
  let d = calc.min(n.w, n.h)
  place(top + left, dx: n.x + (n.w - d) / 2, dy: n.y + (n.h - d) / 2, circle(
    width: d,
    fill: _pseudo-fill,
    stroke: none,
  ))
}

#let _render-final(n) = {
  let d = calc.min(n.w, n.h)
  let ox = n.x + (n.w - d) / 2
  let oy = n.y + (n.h - d) / 2
  place(top + left, dx: ox, dy: oy, circle(
    width: d,
    fill: none,
    stroke: 1pt + _pseudo-fill,
  ))
  let inner = d * 0.52
  place(top + left, dx: ox + (d - inner) / 2, dy: oy + (d - inner) / 2, circle(
    width: inner,
    fill: _pseudo-fill,
    stroke: none,
  ))
}

#let _render-choice(n) = {
  let fill = n.at("fill", default: none)
  let fill = if fill == none { _state-fill } else { fill }
  place(top + left, dx: n.x, dy: n.y, polygon(
    fill: fill,
    stroke: _node-stroke(n),
    (n.w / 2, 0pt),
    (n.w, n.h / 2),
    (n.w / 2, n.h),
    (0pt, n.h / 2),
  ))
}

#let _render-bar(n) = {
  place(top + left, dx: n.x, dy: n.y, box(
    width: n.w,
    height: n.h,
    radius: 1.5pt,
    fill: _pseudo-fill,
    stroke: none,
  ))
}

#let _render-history(n, deep) = {
  let d = calc.min(n.w, n.h)
  let ox = n.x + (n.w - d) / 2
  let oy = n.y + (n.h - d) / 2
  place(top + left, dx: ox, dy: oy, circle(
    width: d,
    fill: _state-fill,
    stroke: _node-stroke(n),
  ))
  place(top + left, dx: ox, dy: oy, box(
    width: d,
    height: d,
    align(center + horizon, text(size: _body-size, fill: _text-fill, if deep { "H*" } else { "H" })),
  ))
}

// A composite state: rounded-rect frame with a label band + divider at the
// top. Child states are separate `nodes` entries drawn on top of the frame.
#let _render-composite(n) = {
  let fill = n.at("fill", default: none)
  let fill = if fill == none { _state-fill } else { fill }
  let stroke = _node-stroke(n)
  let band = 1.7em
  place(top + left, dx: n.x, dy: n.y, box(
    width: n.w,
    height: n.h,
    radius: 7pt,
    fill: fill,
    stroke: stroke,
    {
      place(top + left, box(
        width: n.w,
        height: band,
        inset: (x: 8pt),
        align(left + horizon, text(weight: "bold", _with-breaks(n.at("display", default: "")))),
      ))
      place(top + left, dy: band, line(
        start: (0pt, 0pt),
        end: (n.w, 0pt),
        stroke: stroke,
      ))
    },
  ))
}

#let _render-node(n) = {
  let k = n.kind
  if k == "initial" {
    _render-initial(n)
  } else if k == "final" {
    _render-final(n)
  } else if k == "choice" {
    _render-choice(n)
  } else if k == "fork" or k == "join" or k == "synchro-bar" {
    _render-bar(n)
  } else if k == "history" {
    _render-history(n, false)
  } else if k == "deep-history" {
    _render-history(n, true)
  } else if k == "composite" {
    _render-composite(n)
  } else {
    _render-simple(n)
  }
}

// A concurrent-region divider: a dashed line segment inside a composite
// state's frame, separating two orthogonal regions (`--` horizontal,
// `||` vertical). Codegen hands over absolute endpoints.
#let _render-divider(seg) = {
  place(top + left, line(
    start: (seg.x0, seg.y0),
    end: (seg.x1, seg.y1),
    stroke: (paint: luma(120), thickness: 0.7pt, dash: "dashed"),
  ))
}

// A note: a pale-yellow sticky with a dashed connector to its anchor state.
#let _render-note(note) = {
  let body = _with-breaks(note.at("body", default: ""))
  let a = note.anchor
  let side = note.at("side", default: "right")
  // Connector: from the note's inner edge to the anchor's facing edge,
  // both at vertical mid-height.
  let note-mid-y = note.y + note.h / 2
  let anchor-mid-y = a.y + a.h / 2
  let (cx0, cx1) = if side == "right" {
    (note.x, a.x + a.w)
  } else {
    (note.x + note.w, a.x)
  }
  place(top + left, line(
    start: (cx0, note-mid-y),
    end: (cx1, anchor-mid-y),
    stroke: (paint: luma(130), thickness: 0.7pt, dash: "dashed"),
  ))
  place(top + left, dx: note.x, dy: note.y, box(
    width: note.w,
    height: note.h,
    fill: rgb("#FFF7C0"),
    stroke: 0.7pt + rgb("#C8B560"),
    inset: (x: 6pt, y: 4pt),
    text(size: _body-size, fill: _text-fill, body),
  ))
}

// --------------------------------------------------------------------------
// Entry point.
// --------------------------------------------------------------------------

/// Render a UML state diagram from pre-computed geometry.
///
/// - `nodes`: array of dicts `(id, kind, x, y, w, h, display, body, fill)`.
///   `x` / `y` are the box top-left; lengths are absolute pt.
/// - `transitions`: array of dicts
///   `(from, to, event, guard, action, style, self-loop)`.
/// - `notes`: array of dicts `(x, y, w, h, body, side, anchor)` — a
///   pale-yellow sticky with a dashed connector to `anchor`.
/// - `regions`: array of dicts `(parent, orientation, dividers)` — one per
///   composite state with `--` / `||` concurrent regions. `dividers` is an
///   array of `(x0, y0, x1, y1)` dashed-line segments in absolute pt.
/// - `page`: `(w, h)` canvas size.
/// - `title`: optional diagram title rendered above the canvas.
/// - `hide-empty-description`: PlantUML's `hide empty description` — when
///   set, a composite state with no description of its own skips the empty
///   header compartment. Simple states already render name-only, so this
///   only affects composite frames (S2).
/// - `direction`: `"tb"` (default) or `"lr"`. Decides which axis self-loop
///   arcs and back-edge bows curl onto — the right side in TB, the bottom
///   in LR — so they stay clear of the rank flow.
#let state-layout(
  nodes: (),
  transitions: (),
  notes: (),
  regions: (),
  page: (0pt, 0pt),
  title: none,
  hide-empty-description: false,
  direction: "tb",
) = context {
  let canvas-w = page.at(0)
  let canvas-h = page.at(1)
  let _ = hide-empty-description // simple states already render name-only
  let is-lr = direction == "lr"

  // id → node lookup.
  let by-id = (:)
  for n in nodes { by-id.insert(n.id, n) }

  let paint = luma(70)

  // Geometry of one node: center + half-extents + perimeter shape.
  let geom(n) = (
    cx: n.x + n.w / 2,
    cy: n.y + n.h / 2,
    hw: n.w / 2,
    hh: n.h / 2,
    shape: _shape-of(n.kind),
  )

  // Draw one transition's line + arrow head (phase "geom") or its label
  // (phase "label").
  let draw-edge(tr, phase) = {
    let a = by-id.at(tr.from, default: none)
    let b = by-id.at(tr.to, default: none)
    if a == none or b == none { return }
    let dash = if tr.at("style", default: "solid") == "dashed" {
      "dashed"
    } else if tr.at("style", default: "solid") == "dotted" {
      "dotted"
    } else {
      none
    }
    // Per-edge color override (`-[#blue]->`); falls back to the default tone.
    let edge-paint = tr.at("color", default: none)
    let edge-paint = if edge-paint == none { paint } else { edge-paint }
    let stroke = (paint: edge-paint, thickness: 0.9pt, dash: dash)

    let edge-label() = _with-breaks(_join-label(
      tr.at("event", default: none),
      tr.at("guard", default: none),
      tr.at("action", default: none),
    ))

    if tr.at("self-loop", default: false) {
      // Self-loop: a small arc bulging onto the perpendicular axis — the
      // right side in TB, the bottom in LR. That side is usually clear,
      // whereas curling back along the rank axis collides with neighbours.
      let ext = 26pt
      if is-lr {
        let by = a.y + a.h
        let sx = a.x + a.w * 0.30
        let ex = a.x + a.w * 0.70
        if phase == "geom" {
          place(top + left, curve(
            stroke: stroke,
            fill: none,
            curve.move((sx, by)),
            curve.cubic((sx, by + ext), (ex, by + ext), (ex, by)),
          ))
          _place-head(ex, by, 0pt, -ext, edge-paint)
        } else {
          let lbl = edge-label()
          if lbl != none {
            let m = measure(text(size: _label-size, lbl))
            place(top + left, dx: (sx + ex) / 2 - m.width / 2, dy: by + ext + 3pt, text(
              size: _label-size, fill: _muted, lbl,
            ))
          }
        }
      } else {
        let rx = a.x + a.w
        let sy = a.y + a.h * 0.30
        let ey = a.y + a.h * 0.70
        if phase == "geom" {
          place(top + left, curve(
            stroke: stroke,
            fill: none,
            curve.move((rx, sy)),
            curve.cubic((rx + ext, sy), (rx + ext, ey), (rx, ey)),
          ))
          _place-head(rx, ey, -ext, 0pt, edge-paint)
        } else {
          let lbl = edge-label()
          if lbl != none {
            let m = measure(text(size: _label-size, lbl))
            place(top + left, dx: rx + ext + 3pt, dy: (sy + ey) / 2 - m.height / 2, text(
              size: _label-size, fill: _muted, lbl,
            ))
          }
        }
      }
      return
    }

    if tr.at("back", default: false) {
      // Back-edge (runs against the rank flow). Drawn as a C-bow on the
      // perpendicular axis so it doesn't shoot straight back through the
      // intervening states. `bow-side` ("min" / "max") picks which side
      // to curl onto — codegen routes it around the *outside* of the
      // graph (toward whichever extreme the endpoints sit nearer to).
      let ga = geom(a)
      let gb = geom(b)
      let side = tr.at("bow-side", default: "max")
      let ext = 30pt
      if is-lr {
        // Bow onto the y axis: "min" = above the row, "max" = below it.
        let sx = ga.cx
        let ex = gb.cx
        let sy = if side == "min" { a.y } else { a.y + a.h }
        let ey = if side == "min" { b.y } else { b.y + b.h }
        let bow = if side == "min" {
          calc.min(a.y, b.y) - ext
        } else {
          calc.max(a.y + a.h, b.y + b.h) + ext
        }
        if phase == "geom" {
          place(top + left, curve(
            stroke: stroke,
            fill: none,
            curve.move((sx, sy)),
            curve.cubic((sx, bow), (ex, bow), (ex, ey)),
          ))
          _place-head(ex, ey, 0pt, ey - bow, edge-paint)
        } else {
          let lbl = edge-label()
          if lbl != none {
            let m = measure(text(size: _label-size, lbl))
            let ly = if side == "min" { bow - m.height - 3pt } else { bow + 3pt }
            place(top + left, dx: (sx + ex) / 2 - m.width / 2, dy: ly, text(
              size: _label-size, fill: _muted, lbl,
            ))
          }
        }
      } else {
        // Bow onto the x axis: "min" = left of the column, "max" = right.
        let sy = ga.cy
        let ey = gb.cy
        let sx = if side == "min" { a.x } else { a.x + a.w }
        let ex = if side == "min" { b.x } else { b.x + b.w }
        let bow = if side == "min" {
          calc.min(a.x, b.x) - ext
        } else {
          calc.max(a.x + a.w, b.x + b.w) + ext
        }
        if phase == "geom" {
          place(top + left, curve(
            stroke: stroke,
            fill: none,
            curve.move((sx, sy)),
            curve.cubic((bow, sy), (bow, ey), (ex, ey)),
          ))
          _place-head(ex, ey, ex - bow, 0pt, edge-paint)
        } else {
          let lbl = edge-label()
          if lbl != none {
            let m = measure(text(size: _label-size, lbl))
            let lx = if side == "min" { bow - m.width - 3pt } else { bow + 3pt }
            place(top + left, dx: lx, dy: (sy + ey) / 2 - m.height / 2, text(
              size: _label-size, fill: _muted, lbl,
            ))
          }
        }
      }
      return
    }

    let ga = geom(a)
    let gb = geom(b)
    let start = _perimeter(ga.cx, ga.cy, ga.hw, ga.hh, ga.shape, gb.cx, gb.cy)
    let end = _perimeter(gb.cx, gb.cy, gb.hw, gb.hh, gb.shape, ga.cx, ga.cy)

    if phase == "geom" {
      place(top + left, line(start: start, end: end, stroke: stroke))
      _place-head(end.at(0), end.at(1), end.at(0) - start.at(0), end.at(1) - start.at(1), edge-paint)
    } else {
      let lbl = _with-breaks(_join-label(
        tr.at("event", default: none),
        tr.at("guard", default: none),
        tr.at("action", default: none),
        ))
      if lbl != none {
        let mx = (start.at(0) + end.at(0)) / 2
        let my = (start.at(1) + end.at(1)) / 2
        let m = measure(text(size: _label-size, lbl))
        // Nudge the label off the line, perpendicular to it. The offset
        // clears the label box's *own* half-extent projected onto the
        // perpendicular — so even a wide label on a near-vertical edge
        // sits fully clear of the line, and an antiparallel pair (A→B
        // and B→A, whose perpendiculars point to opposite sides) never
        // stacks on the shared midpoint.
        let dx = end.at(0) - start.at(0)
        let dy = end.at(1) - start.at(1)
        let len = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt))
        let nx = if len > 0.0001 { -(dy / 1pt) / len } else { 0 }
        let ny = if len > 0.0001 { (dx / 1pt) / len } else { -1 }
        let half-ext = calc.abs(nx) * m.width / 2 + calc.abs(ny) * m.height / 2
        let off = half-ext + 4pt
        place(top + left, dx: mx + nx * off - m.width / 2, dy: my + ny * off - m.height / 2, box(
          fill: white.transparentize(15%),
          inset: (x: 1.5pt),
          text(size: _label-size, fill: _muted, lbl),
        ))
      }
    }
  }

  let body = {
    // Pass 0 — composite frames. Drawn first (declaration order keeps a
    // parent frame under any nested frame) so interior edges and child
    // nodes land on top of the frame fill rather than being masked by it.
    for n in nodes {
      if n.kind == "composite" { _render-node(n) }
    }
    // Pass 1 — edge geometry, over the composite frames but under the
    // leaf nodes (so an edge crossing an unrelated leaf is still masked).
    for tr in transitions { draw-edge(tr, "geom") }
    // Pass 2 — leaf states + pseudostates.
    for n in nodes {
      if n.kind != "composite" { _render-node(n) }
    }
    // Pass 2.5 — concurrent-region dividers, over the composite frames.
    for rg in regions {
      for seg in rg.dividers { _render-divider(seg) }
    }
    // Pass 3 — edge labels, on top of the nodes.
    for tr in transitions { draw-edge(tr, "label") }
    // Pass 4 — notes (sticky + connector), above everything.
    for note in notes { _render-note(note) }
  }

  let diagram = block(width: canvas-w, height: canvas-h, breakable: false, body)

  if title != none {
    block(align(center, {
      text(weight: "bold", size: 1.1em, title)
      v(6pt)
      diagram
    }))
  } else {
    diagram
  }
}
