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

/// A self-transition ("self-loop") on a named state. Trailing content block
/// (if any) is the label — may be omitted for unlabeled loops.
///
/// ```typst
/// #loop("active", route: "left")[renew]
/// #loop("active")                       // unlabeled
/// ```
///
/// - `route`: `"above"` (default), `"below"`, `"left"`, `"right"`.
/// - `style`: `"solid"` (default) or `"dashed"`.
#let loop(id, ..rest, route: "above", style: "solid") = {
  let pos-args = rest.pos()
  let body = if pos-args.len() > 0 { pos-args.at(0) } else { none }
  (
    type: "loop",
    id: id,
    label: body,
    route: route,
    style: style,
  )
}

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
/// - `height`: linear-mode arc peak depth, overriding the chain's default
///   `jump-height`. Raise it to push a long jump deeper (clearing a loop
///   label on the same side), or lower it to nest a short jump under a
///   longer one.
/// - `bend`: 2D-mode signed curvature ratio; positive = visual-left of A→B.
/// - `label-pos`: 2D-mode parametric label position along the line
///   (default `0.5` = midpoint). Useful for dodging a state sitting near
///   the midpoint of a long diagonal.
/// - `label-side`: 2D-mode perpendicular label side — `+1` (default) =
///   `+perp` (visual-left of A→B), `-1` = `-perp`. Flip when the default
///   side points toward an adjacent state.
/// - `style`: `"solid"` or `"dashed"`.
#let jump(
  from, to, ..rest,
  route: "above", height: auto, bend: 0,
  label-pos: 0.5, label-side: 1,
  style: "solid",
) = {
  let pos-args = rest.pos()
  let body = if pos-args.len() > 0 { pos-args.at(0) } else { none }
  (
    type: "jump",
    from: from,
    to: to,
    label: body,
    route: route,
    height: height,
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
  //
  // UML state diagrams conventionally draw every circle at the same size, so
  // we pool the natural diameters of all auto-sized states and apply the max
  // uniformly. States with an explicit `size:` opt out of the pool and keep
  // whatever the caller asked for.
  let natural-sizes = states.map(s => {
    let m = measure(s.body)
    calc.max(m.width + 16pt, m.height + 16pt, min-size)
  })
  let auto-natural = natural-sizes.zip(states)
    .filter(((d, s)) => s.size == auto)
    .map(((d, _)) => d)
  let uniform-d = auto-natural.fold(0pt, calc.max)
  let metrics = states.enumerate().map(((i, s)) => (
    id: s.id,
    diameter: if s.size == auto { uniform-d } else { s.size },
    state: s,
  ))
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
    let has-bend = jumps.any(j => j.bend != 0) or bi-jumps.any(b => b.bend != 0)
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

    let jump-effective-h(j) = if j.height == auto { jump-height } else { j.height }
    let above-reserve = {
      let h = 0pt
      if loops.any(l => l.route == "above") { h = calc.max(h, loop-height + 14pt) }
      for j in jumps {
        if j.route == "above" { h = calc.max(h, jump-effective-h(j) + 14pt) }
      }
      h
    }
    let below-reserve = {
      let h = 0pt
      if loops.any(l => l.route == "below") { h = calc.max(h, loop-height + 14pt) }
      for j in jumps {
        if j.route == "below" { h = calc.max(h, jump-effective-h(j) + 14pt) }
      }
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
    // Offset of the loop's two anchor points from the state's edge centre
    // along the perpendicular axis — lets the loop leave a little footprint
    // (12pt wide) instead of a single point, and leaves room in the centre
    // for a jump to anchor on the same side without colliding.
    let tang = 6pt
    let ext = loop-height
    let kick = tang * 4

    let start-p = (0pt, 0pt)
    let end-p = (0pt, 0pt)
    let c1 = (0pt, 0pt)
    let c2 = (0pt, 0pt)
    let label-anchor = (0pt, 0pt)
    let label-edge = "above"

    if route == "above" {
      let y-a = cy - r
      let y-p = y-a - ext
      start-p = (cx - tang, y-a)
      end-p   = (cx + tang, y-a)
      c1 = (cx - tang - kick, y-p)
      c2 = (cx + tang + kick, y-p)
      label-anchor = (cx, y-p)
      label-edge = "above"
    } else if route == "below" {
      let y-a = cy + r
      let y-p = y-a + ext
      start-p = (cx - tang, y-a)
      end-p   = (cx + tang, y-a)
      c1 = (cx - tang - kick, y-p)
      c2 = (cx + tang + kick, y-p)
      label-anchor = (cx, y-p)
      label-edge = "below"
    } else if route == "left" {
      let x-a = cx - r
      let x-p = x-a - ext
      start-p = (x-a, cy - tang)
      end-p   = (x-a, cy + tang)
      c1 = (x-p, cy - tang - kick)
      c2 = (x-p, cy + tang + kick)
      label-anchor = (x-p, cy)
      label-edge = "left"
    } else {  // "right"
      let x-a = cx + r
      let x-p = x-a + ext
      start-p = (x-a, cy - tang)
      end-p   = (x-a, cy + tang)
      c1 = (x-p, cy - tang - kick)
      c2 = (x-p, cy + tang + kick)
      label-anchor = (x-p, cy)
      label-edge = "right"
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
      if label-edge == "above" { ly = ly - m.height / 2 - 4pt }
      else if label-edge == "below" { ly = ly + m.height / 2 + 4pt }
      else if label-edge == "left" { lx = lx - m.width / 2 - 4pt }
      else if label-edge == "right" { lx = lx + m.width / 2 + 4pt }
      place-centered-label(lx, ly, label)
    }
  }

  // Shared 2D edge geometry: from circle A at (ax, ay) with radius ar to
  // circle B at (bx, by) with radius br, with `bend-f` signed curvature.
  //
  //   perp = rotate direction -90° (screen-clockwise) = (uy, -ux).
  //   So (1,0) → (0,-1) "up in screen", matching the bend convention
  //   (positive = visual-left when walking A→B).
  //
  // Returns a dict with start / end (clipped to each circle's edge), cubic
  // control points c1 / c2, the perpendicular unit vector, the stroke, and
  // the signed perpendicular offset of the control points from the direct
  // line (used for label placement). Returns `none` when the two circles
  // share a centre.
  let compute-2d-geom(ax, ay, ar, bx, by, br, bend-f, style) = {
    let dxf = (bx - ax) / 1pt
    let dyf = (by - ay) / 1pt
    let len = calc.sqrt(dxf * dxf + dyf * dyf)
    if len < 0.001 { return none }
    let ux = dxf / len
    let uy = dyf / len
    let perp-x = uy
    let perp-y = -ux
    let offset = (len * bend-f) * 1pt
    let dash = if style == "dashed" { "dashed" } else { none }
    (
      start: (ax + ar * ux, ay + ar * uy),
      end:   (bx - br * ux, by - br * uy),
      c1: (
        ax + (bx - ax) * 0.25 + perp-x * offset,
        ay + (by - ay) * 0.25 + perp-y * offset,
      ),
      c2: (
        ax + (bx - ax) * 0.75 + perp-x * offset,
        ay + (by - ay) * 0.75 + perp-y * offset,
      ),
      perp: (perp-x, perp-y),
      offset: offset,
      stroke: (paint: paint, thickness: 0.8pt, dash: dash),
    )
  }

  // One-way 2D jump. See `draw-loop` for the `phase` convention.
  let draw-jump-2d(ax, ay, ar, bx, by, br, bend-f, label, style,
                   label-pos: 0.5, label-side: 1, phase: "geom") = {
    let g = compute-2d-geom(ax, ay, ar, bx, by, br, bend-f, style)
    if g == none { return }
    if phase == "geom" {
      place(top + left,
        curve(stroke: g.stroke, fill: none,
          curve.move(g.start),
          curve.cubic(g.c1, g.c2, g.end)))
      place-head-along(g.end.at(0), g.end.at(1),
        g.end.at(0) - g.c2.at(0), g.end.at(1) - g.c2.at(1))
    } else if phase == "label" and label != none {
      let m = measure(text(size: 0.7em, label))
      // Perpendicular half-extent of the label's bounding box — ensures wide
      // labels don't sit on top of the line even for bend = 0.
      let half-ext = (calc.abs(g.perp.at(0)) * m.width / 2
        + calc.abs(g.perp.at(1)) * m.height / 2)
      let min-perp = half-ext + 4pt
      let base-offset = if bend-f >= 0 {
        calc.max(g.offset, min-perp)
      } else {
        -calc.max(-g.offset, min-perp)
      }
      let signed-offset = base-offset * label-side
      let mid-x = ax + (bx - ax) * label-pos + g.perp.at(0) * signed-offset
      let mid-y = ay + (by - ay) * label-pos + g.perp.at(1) * signed-offset
      place-centered-label(mid-x, mid-y, label)
    }
  }

  // Bidirectional 2D edge: one line, arrow on each end, two direction labels
  // by default placed on opposite perpendicular sides.
  let draw-bi-edge(ax, ay, ar, bx, by, br, forward, back, bend-f,
                   forward-side, back-side, style, phase: "geom") = {
    let g = compute-2d-geom(ax, ay, ar, bx, by, br, bend-f, style)
    if g == none { return }
    if phase == "geom" {
      place(top + left,
        curve(stroke: g.stroke, fill: none,
          curve.move(g.start),
          curve.cubic(g.c1, g.c2, g.end)))
      // Arrow head at B end (tangent at end of cubic = end - c2).
      place-head-along(g.end.at(0), g.end.at(1),
        g.end.at(0) - g.c2.at(0), g.end.at(1) - g.c2.at(1))
      // Arrow head at A end (tangent at start of cubic = start - c1).
      place-head-along(g.start.at(0), g.start.at(1),
        g.start.at(0) - g.c1.at(0), g.start.at(1) - g.c1.at(1))
    } else if phase == "label" {
      // Labels are placed at the label's own t along the direct line (not
      // along the curve) — perpendicular distance uses the label's projected
      // half-extent so long / diagonal labels don't sit on the line.
      let place-dir-label(label, t, side) = {
        if label == none { return }
        let m = measure(text(size: 0.7em, label))
        let half-ext = (calc.abs(g.perp.at(0)) * m.width / 2
          + calc.abs(g.perp.at(1)) * m.height / 2)
        let off = (half-ext + 4pt) * side
        let pos-x = ax + (bx - ax) * t + g.perp.at(0) * off
        let pos-y = ay + (by - ay) * t + g.perp.at(1) * off
        place-centered-label(pos-x, pos-y, label)
      }
      place-dir-label(forward, 0.68, forward-side)
      place-dir-label(back,    0.32, back-side)
    }
  }

  // Linear-mode jump: over/under arc sharing the chain's y-axis.
  //
  // Anchors sit at 45° from the state's top/bottom, offset *toward* the
  // other state. This keeps the jump's anchor off the top/bottom centre so
  // it doesn't collide with a self-loop on the same state — the loop owns
  // the centre ±6pt, the jump emerges from ~70 % of the radius to the side.
  //
  // See `draw-loop` for the `phase` parameter convention.
  let draw-jump-linear(from-idx, to-idx, j, phase: "geom") = {
    let from-cx = centers.at(from-idx).at(0)
    let to-cx = centers.at(to-idx).at(0)
    let from-r = metrics.at(from-idx).diameter / 2
    let to-r = metrics.at(to-idx).diameter / 2
    let above = j.route == "above"

    let s45 = calc.sin(45deg)  // = cos(45deg) ≈ 0.707
    let sign-from = if to-cx > from-cx { 1 } else { -1 }
    let sign-to = -sign-from
    let vertical-sign = if above { -1 } else { 1 }
    let start-x = from-cx + sign-from * from-r * s45
    let start-y = y-center + vertical-sign * from-r * s45
    let end-x = to-cx + sign-to * to-r * s45
    let end-y = y-center + vertical-sign * to-r * s45

    let jh = if j.height == auto { jump-height } else { j.height }
    let peak-y = if above {
      y-center - calc.max(from-r, to-r) - jh
    } else {
      y-center + calc.max(from-r, to-r) + jh
    }
    let span = end-x - start-x
    let cp1-x = start-x + span * 0.25
    let cp2-x = start-x + span * 0.75
    let dash = if j.style == "dashed" { "dashed" } else { none }
    let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)
    let c2 = (cp2-x, peak-y)
    if phase == "geom" {
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((start-x, start-y)),
          curve.cubic((cp1-x, peak-y), c2, (end-x, end-y)),
        ))
      place-head-along(end-x, end-y, end-x - c2.at(0), end-y - c2.at(1))
    } else if phase == "label" and j.label != none {
      let label-y = if above { peak-y - 4pt } else { peak-y + 4pt }
      place-centered-label((start-x + end-x) / 2, label-y, j.label)
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

  // Resolve a state `id` to its position and radius.
  let resolve(id) = {
    let idx = id-to-idx.at(id)
    let c = centers.at(idx)
    (idx: idx, cx: c.at(0), cy: c.at(1), r: metrics.at(idx).diameter / 2)
  }

  // Render every edge in the given phase. Called twice — "geom" (lines +
  // arrow heads, painted under the states) and "label" (text, painted on
  // top of the states so it never disappears inside a crossed circle).
  let paint-edges(phase) = {
    for l in loops {
      let s = resolve(l.id)
      draw-loop(s.cx, s.cy, s.r, l.route, l.label, l.style, phase: phase)
    }
    for j in jumps {
      let a = resolve(j.from)
      let b = resolve(j.to)
      if is-2d {
        draw-jump-2d(a.cx, a.cy, a.r, b.cx, b.cy, b.r,
          j.bend, j.label, j.style,
          label-pos: j.label-pos, label-side: j.label-side,
          phase: phase)
      } else {
        draw-jump-linear(a.idx, b.idx, j, phase: phase)
      }
    }
    for bi in bi-jumps {
      let a = resolve(bi.from)
      let b = resolve(bi.to)
      draw-bi-edge(a.cx, a.cy, a.r, b.cx, b.cy, b.r,
        bi.forward, bi.back, bi.bend,
        bi.forward-side, bi.back-side,
        bi.style, phase: phase)
    }
  }

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
        place-head-along(x-end, y-center, 1pt, 0pt)
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
    paint-edges("geom")

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
    paint-edges("label")
  })
}
