// ============================================================================
// State-transition diagrams: linear chain or 2D grid, with loops and jumps
// ============================================================================
//
// state         A named state node (circle) with optional initial / accept
//               markers and fill override. First-positional arg is the `id`
//               used by `loop` / `jump` for cross-reference. Supply `pos:
//               (col, row)` to switch the whole diagram into 2D mode.
// loop          Self-transition — a small arc on one side of a state. Route
//               can be `"above" | "below" | "left" | "right"`.
// jump          Arbitrary state → state transition. In linear mode it arcs
//               above or below the chain (`route:`); in 2D mode it is a
//               direct curve whose curvature is controlled by `bend:`.
// state-chain   Single renderer. If any state has `pos`, it lays states out
//               on a (col, row) grid and draws every edge as a jump; else it
//               auto-wires adjacent states left-to-right.
//
// Conventions:
//   - Default fills: normal = pastel.blue, initial = pastel.green,
//                    accept = pastel.yellow.
//   - Accept states get a double circle border (UML convention).
//   - Any state with `initial: true` gets a UML entry marker (filled bullet
//     + short arrow) drawn to its left, in the muted text tone.
//   - Linear mode: `edge-label:` on a state labels the auto-chain arrow
//     pointing *into* that state (ignored in 2D mode).
//   - `bend` convention: positive = curves to the "visual left" of the
//     direction A→B (for rightward motion, arches upward). Same sign on
//     a bidirectional pair makes the two curves separate onto opposite
//     sides of the straight line — no sign-flipping required.
// ============================================================================

#import "palettes.typ": palettes

/// A state node. `id` cross-references it from `loop` / `jump`. The trailing
/// content block is the visible label. Passing `pos: (col, row)` switches the
/// whole diagram into 2D grid mode; omit it for an auto-linear chain.
#let state(
  id,
  pos: none,
  initial: false,
  accept: false,
  edge-label: none,
  fill: none,
  size: auto,
  body,
) = (
  type: "state",
  id: id,
  pos: pos,
  initial: initial,
  accept: accept,
  edge-label: edge-label,
  fill: fill,
  size: size,
  body: body,
)

/// A self-transition ("self-loop") on a named state.
///
/// ```typst
/// #loop("active", route: "left")[renew]
/// ```
///
/// - `route`: `"above"` (default), `"below"`, `"left"`, `"right"`.
/// - `style`: `"solid"` (default) or `"dashed"`.
#let loop(id, body, route: "above", style: "solid") = (
  type: "loop",
  id: id,
  label: body,
  route: route,
  style: style,
)

/// A one-way transition between two states. Trailing content block (if any)
/// is the edge label — may be omitted for unlabeled arrows.
///
/// ```typst
/// // Linear mode — arcs above/below the chain.
/// #jump("reading", "closed", route: "below")[close()]
///
/// // 2D mode — straight by default; bend for curves.
/// #jump("active", "expired")[取消订阅]
/// #jump("active", "grace", bend: 0.15)[取消订阅]
///
/// // Slide the label along the line (0.0 = from end, 1.0 = to end).
/// #jump("active", "expired", label-pos: 0.75)[取消订阅]
/// ```
///
/// - `route`: linear-mode arc side (`"above"` / `"below"`).
/// - `bend`: 2D-mode signed curvature ratio; positive = visual-left of A→B.
/// - `label-pos`: 2D-mode parametric label position along the line
///   (default `0.5` = midpoint). Useful for dodging a state sitting near
///   the midpoint of a long diagonal.
/// - `label-side`: 2D-mode perpendicular label side — `+1` (default) =
///   `+perp` (visual-left of A→B), `-1` = `-perp`. Flip when the default
///   side points toward an adjacent state.
/// - `style`: `"solid"` or `"dashed"`.
#let jump(from, to, ..rest, route: auto, bend: auto, label-pos: 0.5, label-side: 1, style: "solid") = {
  let pos-args = rest.pos()
  let body = if pos-args.len() > 0 { pos-args.at(0) } else { none }
  (
    type: "jump",
    from: from,
    to: to,
    label: body,
    route: route,
    bend: bend,
    label-pos: label-pos,
    label-side: label-side,
    style: style,
  )
}

/// Bidirectional transition — one line between two states with an arrow head
/// on *each* end, plus an optional label per direction. The right primitive
/// for "A goes to B, and B goes back to A" — draws one edge, not two.
///
/// ```typst
/// #bi-jump("active", "billing",
///   forward: [60天内扣款失败],   // labels the A → B direction (near B)
///   back:    [60天内成功续期],   // labels the B → A direction (near A)
/// )
///
/// // Flip both labels to the same side when the default split would land
/// // one of them on a neighbouring edge.
/// #bi-jump("active", "grace", forward: [x], back: [y], back-side: 1)
/// ```
///
/// - `forward` / `back`: the two direction labels.
/// - `bend`: signed curvature; 0 (default) = straight.
/// - `forward-side` / `back-side`: `+1` = `+perp` side of the line, `-1` =
///   `-perp` side. Default `(+1, -1)` gives the conventional mirrored
///   layout; set both to the same sign to stack both labels on one side.
/// - `style`: `"solid"` (default) or `"dashed"`.
#let bi-jump(
  from, to,
  forward: none, back: none,
  bend: 0,
  forward-side: 1, back-side: -1,
  style: "solid",
) = (
  type: "bi-jump",
  from: from,
  to: to,
  forward: forward,
  back: back,
  bend: bend,
  forward-side: forward-side,
  back-side: back-side,
  style: style,
)

/// Render a state-transition diagram.
///
/// ```typst
/// // Linear chain
/// #state-chain(
///   state("a", initial: true)[a],
///   state("b", edge-label: [step])[b],
///   state("c", accept: true)[c],
///   loop("a")[retry],
///   jump("a", "c", route: "below")[skip],
/// )
///
/// // 2D grid (any state with `pos` switches modes)
/// #state-chain(
///   state("x", pos: (0, 0), initial: true)[x],
///   state("y", pos: (2, 0))[y],
///   state("z", pos: (1, 1))[z],
///   jump("x", "y", bend: 0.12)[→],
///   jump("y", "x", bend: 0.12)[←],
///   jump("x", "z")[down],
/// )
/// ```
///
/// - `gap`: linear-mode horizontal gap between adjacent circles.
/// - `col-gap` / `row-gap`: 2D-mode grid cell size (pt per unit).
/// - `loop-height` / `jump-height`: vertical rise of linear-mode overlays.
/// - `min-size`: minimum state diameter (states grow to fit their text).
#let state-chain(
  ..items,
  gap: 60pt,
  col-gap: 90pt,
  row-gap: 100pt,
  loop-height: 28pt,
  jump-height: 48pt,
  min-size: 44pt,
) = context {
  let all = items.pos()
  let states = all.filter(x => x.type == "state")
  let loops = all.filter(x => x.type == "loop")
  let jumps = all.filter(x => x.type == "jump")
  let bi-jumps = all.filter(x => x.type == "bi-jump")

  if states.len() == 0 { return [] }

  let is-2d = states.any(s => s.pos != none)

  // Measure each state body and compute its circle diameter.
  let metrics = states.map(s => {
    let m = measure(s.body)
    let natural-d = calc.max(m.width + 16pt, m.height + 16pt, min-size)
    let d = if s.size == auto { natural-d } else { s.size }
    (id: s.id, diameter: d, state: s)
  })
  let max-d = metrics.fold(0pt, (a, m) => calc.max(a, m.diameter))

  let id-to-idx = (:)
  for (i, m) in metrics.enumerate() { id-to-idx.insert(m.id, i) }

  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let head-size = 6pt
  let initial-paint = palettes.base.text-muted
  let initial-stroke = 0.8pt + initial-paint
  let initial-bullet-r = 4pt
  let initial-gap = 26pt

  // ------------------------------------------------------------------------
  // Layout: compute each state's (cx, cy) plus total canvas size.
  // ------------------------------------------------------------------------
  let centers = ()
  let canvas-w = 0pt
  let canvas-h = 0pt
  let y-center = 0pt  // linear-mode chain y axis

  if is-2d {
    // Validate positions; treat missing pos as (0, 0) so earlier errors don't
    // cascade into confusing layout math.
    let with-pos = metrics.map(m => {
      let p = m.state.pos
      if p == none { p = (0, 0) }
      (col: p.at(0) * 1.0, row: p.at(1) * 1.0)
    })
    let cols = with-pos.map(w => w.col)
    let rows = with-pos.map(w => w.row)
    let min-col = calc.min(..cols)
    let max-col = calc.max(..cols)
    let min-row = calc.min(..rows)
    let max-row = calc.max(..rows)

    // Reserve extra margin so loops / bent edges don't clip at the canvas
    // edge. Bend magnitude is hard to predict, so we over-reserve slightly.
    let has-loop = loops.len() > 0
    let has-bend = (
      jumps.any(j => j.bend != auto and j.bend != 0)
        or bi-jumps.any(b => b.bend != 0)
    )
    let extra = calc.max(
      if has-loop { loop-height + 14pt } else { 0pt },
      if has-bend { 28pt } else { 0pt },
    )
    let has-initial = metrics.any(m => m.state.initial)
    let initial-extra = if has-initial {
      initial-gap + initial-bullet-r * 2 + 6pt
    } else { 0pt }

    let pad-top = max-d / 2 + extra
    let pad-bot = max-d / 2 + extra
    let pad-right = max-d / 2 + extra
    let pad-left = max-d / 2 + extra + initial-extra

    centers = with-pos.map(w => (
      pad-left + (w.col - min-col) * col-gap,
      pad-top + (w.row - min-row) * row-gap,
    ))
    canvas-w = pad-left + (max-col - min-col) * col-gap + pad-right
    canvas-h = pad-top + (max-row - min-row) * row-gap + pad-bot
  } else {
    // Linear mode — equal-gap horizontal layout (current behaviour).
    let x-centers = ()
    let cursor = 0pt
    for m in metrics {
      x-centers.push(cursor + m.diameter / 2)
      cursor += m.diameter + gap
    }
    let chain-width = cursor - gap

    let first-initial = metrics.at(0).state.initial
    let left-pad = if first-initial {
      initial-gap + initial-bullet-r * 2 + 6pt
    } else { 0pt }

    let above-reserve = {
      let h = 0pt
      if loops.any(l => l.route == "above") { h = calc.max(h, loop-height + 14pt) }
      if jumps.any(j => j.route == "above") { h = calc.max(h, jump-height + 14pt) }
      h
    }
    let below-reserve = {
      let h = 0pt
      if loops.any(l => l.route == "below") { h = calc.max(h, loop-height + 14pt) }
      if jumps.any(j => j.route == "below") { h = calc.max(h, jump-height + 14pt) }
      h
    }

    y-center = above-reserve + max-d / 2
    canvas-w = left-pad + chain-width
    canvas-h = above-reserve + max-d + below-reserve
    centers = x-centers.map(xc => (left-pad + xc, y-center))
  }

  // ------------------------------------------------------------------------
  // Rendering primitives (shared by both modes).
  // ------------------------------------------------------------------------

  let place-head-right(tip-x, tip-y) = {
    place(top + left, dx: tip-x - head-size, dy: tip-y - head-size / 2,
      polygon(fill: paint, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size)))
  }

  // Place a triangular arrow head with its tip at (tip-x, tip-y) aimed along
  // the direction vector (dir-x, dir-y). For curved transitions the tangent
  // at the end of a cubic bezier equals `end - control2`.
  let place-head-along(tip-x, tip-y, dir-x, dir-y) = {
    let angle = calc.atan2(dir-x / 1pt, dir-y / 1pt)
    let c = calc.cos(angle)
    let s = calc.sin(angle)
    let v0 = (0pt, 0pt)
    let v1-unrot = (-head-size, -head-size / 2)
    let v2-unrot = (-head-size,  head-size / 2)
    let rot(p) = (
      p.at(0) * c - p.at(1) * s,
      p.at(0) * s + p.at(1) * c,
    )
    let v1 = rot(v1-unrot)
    let v2 = rot(v2-unrot)
    let xs = (v0.at(0), v1.at(0), v2.at(0))
    let ys = (v0.at(1), v1.at(1), v2.at(1))
    let min-x = calc.min(..xs)
    let min-y = calc.min(..ys)
    place(top + left, dx: tip-x + min-x, dy: tip-y + min-y,
      polygon(fill: paint, stroke: none,
        (v0.at(0) - min-x, v0.at(1) - min-y),
        (v1.at(0) - min-x, v1.at(1) - min-y),
        (v2.at(0) - min-x, v2.at(1) - min-y)))
  }

  let render-state(s, d) = {
    let fill = if s.fill != none { s.fill }
      else if s.initial { palettes.pastel.green }
      else if s.accept { palettes.pastel.yellow }
      else { palettes.pastel.blue }
    box(width: d, height: d, {
      place(top + left,
        circle(width: d, fill: fill, stroke: stroke))
      if s.accept {
        place(top + left, dx: 3pt, dy: 3pt,
          circle(width: d - 6pt, stroke: 0.6pt + palettes.base.border))
      }
      place(center + horizon,
        block(width: d - 12pt,
          align(center + horizon,
            text(size: 0.85em, s.body))))
    })
  }

  let place-centered-label(cx, cy, body) = {
    let m = measure(text(size: 0.7em, body))
    place(top + left, dx: cx - m.width / 2, dy: cy - m.height / 2,
      text(size: 0.7em, fill: palettes.base.text-muted, body))
  }

  let draw-initial-marker(cx, cy, r) = {
    let arrow-end = cx - r
    let arrow-start = arrow-end - initial-gap
    let bullet-cx = arrow-start - 2pt - initial-bullet-r
    place(top + left, dx: bullet-cx - initial-bullet-r, dy: cy - initial-bullet-r,
      circle(width: initial-bullet-r * 2, fill: initial-paint, stroke: none))
    place(top + left, dy: cy,
      line(start: (arrow-start, 0pt), end: (arrow-end - head-size, 0pt),
           stroke: initial-stroke))
    place(top + left, dx: arrow-end - head-size, dy: cy - head-size / 2,
      polygon(fill: initial-paint, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size)))
  }

  // Self-loop in any of 4 directions around (cx, cy). `phase` selects which
  // drawing pass to run: "geom" emits the line + arrow head (painted under
  // states), "label" emits the text (painted on top of states so it never
  // disappears inside a crossed circle).
  let draw-loop(cx, cy, r, route, label, style, phase: "geom") = {
    let dash = if style == "dashed" { "dashed" } else { none }
    let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)
    let tang = 6pt
    let ext = loop-height
    let kick = tang * 4

    let start-p = (0pt, 0pt)
    let end-p = (0pt, 0pt)
    let c1 = (0pt, 0pt)
    let c2 = (0pt, 0pt)
    let label-anchor = (0pt, 0pt)
    let label-side = "above"

    if route == "above" {
      let y-a = cy - r
      let y-p = y-a - ext
      start-p = (cx - tang, y-a)
      end-p   = (cx + tang, y-a)
      c1 = (cx - tang - kick, y-p)
      c2 = (cx + tang + kick, y-p)
      label-anchor = (cx, y-p)
      label-side = "above"
    } else if route == "below" {
      let y-a = cy + r
      let y-p = y-a + ext
      start-p = (cx - tang, y-a)
      end-p   = (cx + tang, y-a)
      c1 = (cx - tang - kick, y-p)
      c2 = (cx + tang + kick, y-p)
      label-anchor = (cx, y-p)
      label-side = "below"
    } else if route == "left" {
      let x-a = cx - r
      let x-p = x-a - ext
      start-p = (x-a, cy - tang)
      end-p   = (x-a, cy + tang)
      c1 = (x-p, cy - tang - kick)
      c2 = (x-p, cy + tang + kick)
      label-anchor = (x-p, cy)
      label-side = "left"
    } else {  // "right"
      let x-a = cx + r
      let x-p = x-a + ext
      start-p = (x-a, cy - tang)
      end-p   = (x-a, cy + tang)
      c1 = (x-p, cy - tang - kick)
      c2 = (x-p, cy + tang + kick)
      label-anchor = (x-p, cy)
      label-side = "right"
    }

    if phase == "geom" {
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move(start-p),
          curve.cubic(c1, c2, end-p)))
      place-head-along(end-p.at(0), end-p.at(1),
        end-p.at(0) - c2.at(0), end-p.at(1) - c2.at(1))
    } else if phase == "label" and label != none {
      let m = measure(text(size: 0.7em, label))
      let lx = label-anchor.at(0)
      let ly = label-anchor.at(1)
      if label-side == "above" { ly = ly - m.height / 2 - 4pt }
      else if label-side == "below" { ly = ly + m.height / 2 + 4pt }
      else if label-side == "left" { lx = lx - m.width / 2 - 4pt }
      else if label-side == "right" { lx = lx + m.width / 2 + 4pt }
      place-centered-label(lx, ly, label)
    }
  }

  // 2D-mode edge between two circles at arbitrary centers.
  //   perp = rotate direction -90° (screen-clockwise) = (uy, -ux).
  //   So (1,0) → (0,-1) "up in screen", matching the bend convention
  //   (positive = visual-left when walking A→B).
  // See `draw-loop` for the `phase` parameter convention.
  let draw-edge-2d(ax, ay, ar, bx, by, br, bend-f, label, style,
                   label-pos: 0.5, label-side: 1, phase: "geom") = {
    let dxf = (bx - ax) / 1pt
    let dyf = (by - ay) / 1pt
    let len = calc.sqrt(dxf * dxf + dyf * dyf)
    if len < 0.001 { return }
    let ux = dxf / len
    let uy = dyf / len
    let perp-x = uy
    let perp-y = -ux

    let start-x = ax + ar * ux
    let start-y = ay + ar * uy
    let end-x = bx - br * ux
    let end-y = by - br * uy

    let offset = (len * bend-f) * 1pt
    let c1-x = ax + (bx - ax) * 0.25 + perp-x * offset
    let c1-y = ay + (by - ay) * 0.25 + perp-y * offset
    let c2-x = ax + (bx - ax) * 0.75 + perp-x * offset
    let c2-y = ay + (by - ay) * 0.75 + perp-y * offset

    let dash = if style == "dashed" { "dashed" } else { none }
    let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)

    if phase == "geom" {
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((start-x, start-y)),
          curve.cubic((c1-x, c1-y), (c2-x, c2-y), (end-x, end-y))))
      place-head-along(end-x, end-y, end-x - c2-x, end-y - c2-y)
    } else if phase == "label" and label != none {
      let m = measure(text(size: 0.7em, label))
      // Perpendicular half-extent of the label's bounding box — ensures wide
      // labels don't sit on top of the line even for bend = 0.
      let half-ext = calc.abs(perp-x) * m.width / 2 + calc.abs(perp-y) * m.height / 2
      let min-perp = half-ext + 4pt
      let base-offset = if bend-f >= 0 {
        calc.max(offset, min-perp)
      } else {
        -calc.max(-offset, min-perp)
      }
      let signed-offset = base-offset * label-side
      let mid-x = ax + (bx - ax) * label-pos + perp-x * signed-offset
      let mid-y = ay + (by - ay) * label-pos + perp-y * signed-offset
      place-centered-label(mid-x, mid-y, label)
    }
  }

  // Bidirectional edge: one line between two circles, arrow head on each
  // end, two direction labels placed on opposite perpendicular sides so they
  // visually mirror the arrow they describe.
  // See `draw-loop` for the `phase` parameter convention.
  let draw-bi-edge(ax, ay, ar, bx, by, br, forward, back, bend-f,
                   forward-side, back-side, style, phase: "geom") = {
    let dxf = (bx - ax) / 1pt
    let dyf = (by - ay) / 1pt
    let len = calc.sqrt(dxf * dxf + dyf * dyf)
    if len < 0.001 { return }
    let ux = dxf / len
    let uy = dyf / len
    let perp-x = uy
    let perp-y = -ux

    let start-x = ax + ar * ux
    let start-y = ay + ar * uy
    let end-x = bx - br * ux
    let end-y = by - br * uy

    let offset = (len * bend-f) * 1pt
    let c1-x = ax + (bx - ax) * 0.25 + perp-x * offset
    let c1-y = ay + (by - ay) * 0.25 + perp-y * offset
    let c2-x = ax + (bx - ax) * 0.75 + perp-x * offset
    let c2-y = ay + (by - ay) * 0.75 + perp-y * offset

    let dash = if style == "dashed" { "dashed" } else { none }
    let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)

    if phase == "geom" {
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((start-x, start-y)),
          curve.cubic((c1-x, c1-y), (c2-x, c2-y), (end-x, end-y))))
      // Arrow head at B end (tangent of bezier at end = end - c2)
      place-head-along(end-x, end-y, end-x - c2-x, end-y - c2-y)
      // Arrow head at A end (tangent at start of bezier = start - c1)
      place-head-along(start-x, start-y, start-x - c1-x, start-y - c1-y)
    } else if phase == "label" {
      // Labels: forward near B end on +perp side, back near A end on -perp side.
      // Perpendicular distance uses the label's own projected half-extent so it
      // doesn't sit on the line even for long / diagonal labels.
      let place-dir-label(label, t, side) = {
        if label == none { return }
        let m = measure(text(size: 0.7em, label))
        let half-ext = calc.abs(perp-x) * m.width / 2 + calc.abs(perp-y) * m.height / 2
        let pos-x = ax + (bx - ax) * t
        let pos-y = ay + (by - ay) * t
        let off = (half-ext + 4pt) * side
        place-centered-label(pos-x + perp-x * off, pos-y + perp-y * off, label)
      }
      place-dir-label(forward, 0.68, forward-side)
      place-dir-label(back,    0.32, back-side)
    }
  }

  // Linear-mode jump: over/under arc sharing the chain's y-axis.
  // See `draw-loop` for the `phase` parameter convention.
  let draw-jump-linear(from-idx, to-idx, j, phase: "geom") = {
    let from-cx = centers.at(from-idx).at(0)
    let to-cx = centers.at(to-idx).at(0)
    let from-r = metrics.at(from-idx).diameter / 2
    let to-r = metrics.at(to-idx).diameter / 2
    let above = if j.route != auto { j.route == "above" } else { true }
    let start-y = if above { y-center - from-r } else { y-center + from-r }
    let end-y   = if above { y-center - to-r } else { y-center + to-r }
    let peak-y = if above {
      calc.min(start-y, end-y) - jump-height
    } else {
      calc.max(start-y, end-y) + jump-height
    }
    let span = to-cx - from-cx
    let cp1-x = from-cx + span * 0.25
    let cp2-x = from-cx + span * 0.75
    let dash = if j.style == "dashed" { "dashed" } else { none }
    let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)
    let c2 = (cp2-x, peak-y)
    if phase == "geom" {
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((from-cx, start-y)),
          curve.cubic((cp1-x, peak-y), c2, (to-cx, end-y)),
        ))
      place-head-along(to-cx, end-y, to-cx - c2.at(0), end-y - c2.at(1))
    } else if phase == "label" and j.label != none {
      let label-y = if above { peak-y - 4pt } else { peak-y + 4pt }
      place-centered-label((from-cx + to-cx) / 2, label-y, j.label)
    }
  }

  // ------------------------------------------------------------------------
  // Paint the canvas in three passes:
  //   1. Edge geometry (lines + arrow heads) — painted under states so lines
  //      that cross unrelated states are cleanly masked by their circle fills.
  //   2. States — painted on top of edge geometry.
  //   3. Edge labels — painted above states so a label that lands on a circle
  //      stays legible instead of being hidden by the fill.
  // ------------------------------------------------------------------------

  // Pass-agnostic iteration over every edge: re-used for geometry and labels
  // so the position math stays in one place.
  let for-each-edge(action) = {
    for l in loops {
      let idx = id-to-idx.at(l.id)
      let cx = centers.at(idx).at(0)
      let cy = centers.at(idx).at(1)
      let r = metrics.at(idx).diameter / 2
      action("loop", (cx: cx, cy: cy, r: r, item: l))
    }
    for j in jumps {
      let from-idx = id-to-idx.at(j.from)
      let to-idx = id-to-idx.at(j.to)
      if is-2d {
        action("jump-2d", (
          ax: centers.at(from-idx).at(0),
          ay: centers.at(from-idx).at(1),
          bx: centers.at(to-idx).at(0),
          by: centers.at(to-idx).at(1),
          ar: metrics.at(from-idx).diameter / 2,
          br: metrics.at(to-idx).diameter / 2,
          item: j,
        ))
      } else {
        action("jump-linear", (from-idx: from-idx, to-idx: to-idx, item: j))
      }
    }
    for b in bi-jumps {
      let from-idx = id-to-idx.at(b.from)
      let to-idx = id-to-idx.at(b.to)
      action("bi-jump", (
        ax: centers.at(from-idx).at(0),
        ay: centers.at(from-idx).at(1),
        bx: centers.at(to-idx).at(0),
        by: centers.at(to-idx).at(1),
        ar: metrics.at(from-idx).diameter / 2,
        br: metrics.at(to-idx).diameter / 2,
        item: b,
      ))
    }
  }

  let run-edge-pass(phase) = for-each-edge((kind, ctx) => {
    if kind == "loop" {
      draw-loop(ctx.cx, ctx.cy, ctx.r, ctx.item.route, ctx.item.label,
        ctx.item.style, phase: phase)
    } else if kind == "jump-2d" {
      let bend-f = if ctx.item.bend == auto { 0 } else { ctx.item.bend }
      draw-edge-2d(ctx.ax, ctx.ay, ctx.ar, ctx.bx, ctx.by, ctx.br,
        bend-f, ctx.item.label, ctx.item.style,
        label-pos: ctx.item.label-pos,
        label-side: ctx.item.label-side,
        phase: phase)
    } else if kind == "jump-linear" {
      draw-jump-linear(ctx.from-idx, ctx.to-idx, ctx.item, phase: phase)
    } else if kind == "bi-jump" {
      draw-bi-edge(ctx.ax, ctx.ay, ctx.ar, ctx.bx, ctx.by, ctx.br,
        ctx.item.forward, ctx.item.back, ctx.item.bend,
        ctx.item.forward-side, ctx.item.back-side,
        ctx.item.style, phase: phase)
    }
  })

  // Chain auto-arrow (linear mode) — kept inline because it's tightly coupled
  // to the shared y-center and the "label from destination state" rule.
  let chain-arrows(phase) = {
    if is-2d { return }
    for i in range(1, metrics.len()) {
      let prev = metrics.at(i - 1)
      let curr = metrics.at(i)
      let prev-cx = centers.at(i - 1).at(0)
      let curr-cx = centers.at(i).at(0)
      let x-start = prev-cx + prev.diameter / 2
      let x-end = curr-cx - curr.diameter / 2
      if phase == "geom" {
        place(top + left, dy: y-center,
          line(start: (x-start, 0pt), end: (x-end - head-size, 0pt),
               stroke: stroke))
        place-head-right(x-end, y-center)
      } else if phase == "label" {
        let lbl = curr.state.edge-label
        if lbl != none {
          place-centered-label((x-start + x-end) / 2, y-center - 10pt, lbl)
        }
      }
    }
  }

  block(width: canvas-w, height: canvas-h, {
    // Pass 1 — geometry.
    for (i, m) in metrics.enumerate() {
      if m.state.initial {
        let cx = centers.at(i).at(0)
        let cy = centers.at(i).at(1)
        draw-initial-marker(cx, cy, m.diameter / 2)
      }
    }
    chain-arrows("geom")
    run-edge-pass("geom")

    // Pass 2 — states on top of geometry.
    for (i, m) in metrics.enumerate() {
      let cx = centers.at(i).at(0)
      let cy = centers.at(i).at(1)
      let d = m.diameter
      place(top + left, dx: cx - d / 2, dy: cy - d / 2,
        render-state(m.state, d))
    }

    // Pass 3 — labels on top of states.
    chain-arrows("label")
    run-edge-pass("label")
  })
}
