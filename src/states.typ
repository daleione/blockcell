// ============================================================================
// State-transition diagrams: linear state chain + self-loops + jump arcs
// ============================================================================
//
// state         A named state node (circle) with optional initial / accept
//               markers and fill override. First-positional arg is the `id`
//               used by `loop` / `jump` for cross-reference.
// loop          Self-transition — drawn as a small arc above (or below) a
//               named state with a label.
// jump          Non-adjacent transition — drawn as a curved arc above (or
//               below) the chain, connecting two named states.
// state-chain   Renderer. Variadic: interleave `state` / `loop` / `jump`
//               entries in any order; it separates them by type, lays the
//               states out left-to-right, and paints the overlays.
//
// Conventions:
//   - Default fill: normal states = pastel.blue,
//                   initial = pastel.green, accept = pastel.yellow.
//   - Accept states get a double circle border (UML convention).
//   - The first state with `initial: true` gets a UML entry marker
//     (filled bullet + short arrow) drawn to its left.
//   - Chain edges: between adjacent states; label via `edge-label:` on the
//     destination state (same rule as `flow-col`).
//   - Loop / jump `route:` picks `"above"` or `"below"`.
// ============================================================================

#import "palettes.typ": palettes

/// A state node. `id` is the cross-reference name (string) used by
/// `loop(id)` and `jump(from, to)`. The trailing content block is the
/// display label rendered inside the circle.
#let state(
  id,
  initial: false,
  accept: false,
  edge-label: none,
  fill: none,
  size: auto,
  body,
) = (
  type: "state",
  id: id,
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
/// #loop("reading")[read()]
/// ```
///
/// - `route`: `"above"` (default) or `"below"` the state.
/// - `style`: `"solid"` (default) or `"dashed"`.
#let loop(id, body, route: "above", style: "solid") = (
  type: "loop",
  id: id,
  label: body,
  route: route,
  style: style,
)

/// A non-adjacent transition between two states, drawn as a curved arc.
///
/// ```typst
/// #jump("reading", "closed", route: "below")[close()]
/// ```
///
/// - `route`: `"above"` (default) or `"below"` the chain.
/// - `style`: `"solid"` or `"dashed"`.
#let jump(from, to, body, route: "above", style: "solid") = (
  type: "jump",
  from: from,
  to: to,
  label: body,
  route: route,
  style: style,
)

/// Render a linear state-transition diagram. Positional args interleave
/// `state(...)`, `loop(...)`, and `jump(...)` entries in any order.
///
/// ```typst
/// #state-chain(
///   state("reading", initial: true)[reading],
///   state("eof",    edge-label: [read()])[eof],
///   state("closed", edge-label: [close()], accept: true)[closed],
///   loop("reading")[read()],
///   jump("reading", "closed", route: "below")[close()],
/// )
/// ```
///
/// - `gap`: horizontal space between adjacent state circles (default 60pt).
/// - `loop-height` / `jump-height`: vertical rise of the arc overlays.
/// - `min-size`: minimum state diameter; states auto-grow to fit text.
#let state-chain(
  ..items,
  gap: 60pt,
  loop-height: 28pt,
  jump-height: 48pt,
  min-size: 44pt,
) = context {
  let all = items.pos()
  let states = all.filter(x => x.type == "state")
  let loops = all.filter(x => x.type == "loop")
  let jumps = all.filter(x => x.type == "jump")

  if states.len() == 0 { return [] }

  // Measure each state body and compute its circle diameter.
  let metrics = states.map(s => {
    let m = measure(s.body)
    let natural-d = calc.max(m.width + 16pt, m.height + 16pt, min-size)
    let d = if s.size == auto { natural-d } else { s.size }
    (id: s.id, diameter: d, state: s)
  })

  // Equal-gap horizontal layout. x-centers are circle centers relative to
  // the chain's own origin (before left-pad is added for the initial marker).
  let x-centers = ()
  let cursor = 0pt
  for m in metrics {
    x-centers.push(cursor + m.diameter / 2)
    cursor += m.diameter + gap
  }
  let chain-width = cursor - gap

  let id-to-col = (:)
  for (i, m) in metrics.enumerate() { id-to-col.insert(m.id, i) }

  let max-d = metrics.fold(0pt, (a, m) => calc.max(a, m.diameter))

  // Initial-state marker (filled bullet + short arrow) lives to the left
  // of the first state when it has `initial: true`. Uses a muted gray so
  // it reads as a delicate "entry mark", not a competing node.
  let initial-paint = palettes.base.text-muted
  let initial-stroke = 0.8pt + initial-paint
  let initial-bullet-r = 4pt
  let initial-gap = 26pt
  let first-initial = metrics.at(0).state.initial
  let left-pad = if first-initial {
    initial-gap + initial-bullet-r * 2 + 6pt
  } else { 0pt }

  // Vertical space above / below the chain for loops and jumps. Generous
  // even when a given route is empty so label baselines don't shift.
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

  let y-center = above-reserve + max-d / 2
  let total-w = left-pad + chain-width
  let total-h = above-reserve + max-d + below-reserve

  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let head-size = 6pt

  // Place a right-pointing arrow head whose tip lands exactly at (tip-x, tip-y).
  let place-head-right(tip-x, tip-y) = {
    place(top + left, dx: tip-x - head-size, dy: tip-y - head-size / 2,
      polygon(fill: paint, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size)))
  }

  // Place a triangular arrow head with its tip at (tip-x, tip-y) aimed along
  // the direction vector (dir-x, dir-y). Used for curved transitions so the
  // head always matches the tangent at the curve's endpoint (the tangent of
  // a cubic bezier at its end point is along `end - control2`).
  let place-head-along(tip-x, tip-y, dir-x, dir-y) = {
    let angle = calc.atan2(dir-x / 1pt, dir-y / 1pt)
    let c = calc.cos(angle)
    let s = calc.sin(angle)
    // Base triangle before rotation: tip at origin, pointing +x (right).
    let v0 = (0pt, 0pt)
    let v1-unrot = (-head-size, -head-size / 2)
    let v2-unrot = (-head-size,  head-size / 2)
    // Apply 2D rotation (y-down Typst coords; positive angle = clockwise).
    let rot(p) = (
      p.at(0) * c - p.at(1) * s,
      p.at(0) * s + p.at(1) * c,
    )
    let v1 = rot(v1-unrot)
    let v2 = rot(v2-unrot)
    // Shift so bbox starts at (0,0) so polygon() has non-negative vertices.
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

  // Render a single state: filled circle, optional inner circle for
  // `accept`, body text centered inside.
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

  // Render a label centered at (cx, cy) — measured so it sits symmetrically
  // and doesn't clip arcs or nodes.
  let place-centered-label(cx, cy, body) = {
    let m = measure(text(size: 0.7em, body))
    place(top + left, dx: cx - m.width / 2, dy: cy - m.height / 2,
      text(size: 0.7em, fill: palettes.base.text-muted, body))
  }

  block(width: total-w, height: total-h, {
    // Initial marker: filled bullet + short arrow entering the first state,
    // both rendered in the muted paint so the marker recedes visually.
    if first-initial {
      let first-cx = left-pad + x-centers.at(0)
      let first-r = metrics.at(0).diameter / 2
      let bullet-x = 0pt
      place(top + left, dx: bullet-x, dy: y-center - initial-bullet-r,
        circle(width: initial-bullet-r * 2, fill: initial-paint, stroke: none))
      let arrow-start = bullet-x + initial-bullet-r * 2 + 2pt
      let arrow-end = first-cx - first-r
      place(top + left, dy: y-center,
        line(start: (arrow-start, 0pt), end: (arrow-end - head-size, 0pt),
             stroke: initial-stroke))
      place(top + left, dx: arrow-end - head-size, dy: y-center - head-size / 2,
        polygon(fill: initial-paint, stroke: none,
          (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size)))
    }

    // States
    for (i, m) in metrics.enumerate() {
      let cx = left-pad + x-centers.at(i)
      let d = m.diameter
      place(top + left, dx: cx - d / 2, dy: y-center - d / 2,
        render-state(m.state, d))
    }

    // Forward chain arrows (between adjacent states).
    for i in range(1, metrics.len()) {
      let prev = metrics.at(i - 1)
      let curr = metrics.at(i)
      let x-start = left-pad + x-centers.at(i - 1) + prev.diameter / 2
      let x-end = left-pad + x-centers.at(i) - curr.diameter / 2
      place(top + left, dy: y-center,
        line(start: (x-start, 0pt), end: (x-end - head-size, 0pt),
             stroke: stroke))
      place-head-right(x-end, y-center)
      let lbl = curr.state.edge-label
      if lbl != none {
        place-centered-label((x-start + x-end) / 2, y-center - 10pt, lbl)
      }
    }

    // Self-loops: small arc from one side of the state top (or bottom) back
    // to the other side. Arrow head enters along the curve's tangent.
    for l in loops {
      let col = id-to-col.at(l.id)
      let cx = left-pad + x-centers.at(col)
      let r = metrics.at(col).diameter / 2
      let offset = 6pt
      let start-x = cx - offset
      let end-x = cx + offset
      let above = l.route == "above"
      let anchor-y = if above { y-center - r } else { y-center + r }
      let peak-y = if above { anchor-y - loop-height } else { anchor-y + loop-height }
      let dash = if l.style == "dashed" { "dashed" } else { none }
      let line-stroke = (paint: paint, thickness: 0.8pt, dash: dash)
      let c2 = (end-x + offset * 4, peak-y)
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((start-x, anchor-y)),
          curve.cubic(
            (start-x - offset * 4, peak-y),
            c2,
            (end-x, anchor-y),
          )))
      // Tangent at curve end = end - c2
      place-head-along(end-x, anchor-y,
        end-x - c2.at(0), anchor-y - c2.at(1))
      if l.label != none {
        let label-y = if above { peak-y - 4pt } else { peak-y + 4pt }
        place-centered-label(cx, label-y, l.label)
      }
    }

    // Jumps: cubic bezier over (or under) the chain connecting two states'
    // top (or bottom) apexes.
    for j in jumps {
      let from-col = id-to-col.at(j.from)
      let to-col = id-to-col.at(j.to)
      let from-cx = left-pad + x-centers.at(from-col)
      let to-cx = left-pad + x-centers.at(to-col)
      let from-r = metrics.at(from-col).diameter / 2
      let to-r = metrics.at(to-col).diameter / 2
      let above = j.route == "above"
      let start-y = if above { y-center - from-r } else { y-center + from-r }
      let end-y = if above { y-center - to-r } else { y-center + to-r }
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
      place(top + left,
        curve(stroke: line-stroke, fill: none,
          curve.move((from-cx, start-y)),
          curve.cubic((cp1-x, peak-y), c2, (to-cx, end-y)),
        ))
      place-head-along(to-cx, end-y,
        to-cx - c2.at(0), end-y - c2.at(1))
      if j.label != none {
        let label-y = if above { peak-y - 4pt } else { peak-y + 4pt }
        place-centered-label((from-cx + to-cx) / 2, label-y, j.label)
      }
    }
  })
}
