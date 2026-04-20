// ============================================================================
// Flow-chart composites
// ============================================================================
//
// branch        - Diamond decision: Yes continues down, No branches right
// branch-merge  - Diamond with Yes / No columns that rejoin below
// switch        - N-way branch (diamond fans out to cases, rejoining below)
// flow-loop     - Wraps a body with a back-edge on the left ("repeat")
// ============================================================================

#import "atoms.typ": *
#import "palettes.typ": palettes

/// A decision branch composite: diamond on top, the "yes" subtree continuing
/// downward (main path), the "no" subtree extending to the right (alternative).
/// Designed to drop into `flow-col` — the grid is symmetrically padded on the
/// left so the diamond and yes-branch stay on the column's horizontal axis,
/// allowing flow-col's auto-inserted down-arrow to line up with the visual
/// continuation.
///
/// ```typst
/// #flow-col(
///   terminal[Start],
///   process[Load config],
///   branch([Config valid?],
///     yes: process[Start server],
///     no:  process[Log error + exit],
///   ),
///   terminal[Ready],
/// )
/// ```
///
/// - `cond`: Body rendered inside the diamond.
/// - `yes`: Content drawn below (connected by a down-arrow). When `none`, the
///   branch block ends at the diamond and the enclosing `flow-col` supplies
///   the implicit "yes → next step" arrow.
/// - `no`: Content drawn to the right (connected by a right-arrow). `none`
///   omits the no branch entirely.
/// - `yes-label` / `no-label`: Labels on the connector arrows.
/// - `diamond-width`: Horizontal diagonal of the diamond (default 120pt).
#let branch(
  cond,
  yes: none,
  no: none,
  yes-label: [Yes],
  no-label: [No],
  diamond-width: 120pt,
) = context {
  let diamond-node = decision(cond, width: diamond-width)
  let no-cell = if no == none { box() } else {
    box({
      edge(direction: "right", label: no-label)
      h(2pt)
      no
    })
  }
  // Mirror the no-branch width as a phantom left column so the diamond
  // (and the yes-branch beneath it) sit at the grid's horizontal center.
  let pad-w = if no == none { 0pt } else { measure(no-cell).width }

  let cells = ([], diamond-node, no-cell)
  if yes != none {
    cells = cells + ([], align(center, edge(direction: "down", label: yes-label)), [])
    cells = cells + ([], align(center, yes), [])
  }

  grid(
    columns: (pad-w, auto, pad-w),
    column-gutter: 0pt,
    row-gutter: 0pt,
    align: (left + horizon, center + horizon, left + horizon),
    ..cells,
  )
}

/// Shared n-way branch layout used by `branch-merge` and `switch`. Renders
/// a diamond above N parallel column-bodies joined by a top junction line
/// (for the condition → case arrows) and, when `merge: true`, a bottom
/// merge line + continuation down-arrow.
///
/// Layout is computed from measured body sizes so lines hit the right
/// anchors without manual coordinates. The block's horizontal center
/// coincides with the diamond's center, letting it drop into `flow-col`
/// without misalignment.
#let _n-way-branch(
  cond,
  cases,
  merge: true,
  diamond-width: 120pt,
  col-gap: 40pt,
) = context {
  let diamond-node = decision(cond, width: diamond-width)
  let diamond-m = measure(diamond-node)
  if cases.len() == 0 { return diamond-node }

  // Equal-width columns (= max body width) keep the layout symmetric:
  // for odd `cases.len()`, the middle column's vertical axis lands exactly
  // on the diamond's spine, and the top/bottom horizontal bars stay
  // symmetric about center-x regardless of per-body width variation.
  let body-ms = cases.map(c => measure(c.body))
  let col-w = body-ms.fold(0pt, (a, m) => calc.max(a, m.width))
  let col-heights = body-ms.map(m => m.height)

  let n = cases.len()
  let total-body-w = n * col-w + col-gap * (n - 1)
  let total-w = calc.max(total-body-w, diamond-m.width)
  let left-pad = (total-w - total-body-w) / 2

  let col-centers = range(n).map(i => left-pad + col-w / 2 + i * (col-w + col-gap))
  let center-x = total-w / 2

  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let head-size = 6pt
  let junction-gap = 10pt
  let arrow-len = 24pt
  let sub-h = col-heights.fold(0pt, (a, b) => calc.max(a, b))
  let merge-gap = 10pt

  let y-diamond-bot = diamond-m.height
  let y-junction = y-diamond-bot + junction-gap
  let y-sub-top = y-junction + arrow-len
  let y-sub-bot = y-sub-top + sub-h
  let y-merge-line = y-sub-bot + merge-gap

  // Block exits at the merge line; the enclosing `flow-col` draws the
  // continuation arrow down to the next node (same convention as `branch`).
  let total-h = if merge { y-merge-line + 1pt } else { y-sub-bot }

  let head-down = polygon(fill: paint, stroke: none,
    (0pt, 0pt), (head-size, 0pt), (head-size / 2, head-size))

  block(width: total-w, height: total-h, {
    place(top + left, dx: center-x - diamond-m.width / 2, diamond-node)

    place(top + left, dx: center-x,
      line(start: (0pt, y-diamond-bot), end: (0pt, y-junction), stroke: stroke))

    if cases.len() > 1 {
      place(top + left,
        line(start: (col-centers.first(), y-junction),
             end: (col-centers.last(), y-junction), stroke: stroke))
    }

    for (i, c) in cases.enumerate() {
      let cx = col-centers.at(i)
      let body-w = body-ms.at(i).width

      place(top + left, dx: cx,
        line(start: (0pt, y-junction),
             end: (0pt, y-sub-top - head-size), stroke: stroke))
      place(top + left, dx: cx - head-size / 2, dy: y-sub-top - head-size,
        head-down)

      place(top + left,
        dx: cx + head-size / 2 + 3pt,
        dy: y-junction + (arrow-len - head-size) / 2 - 3pt,
        text(size: 0.6em, fill: palettes.base.text-muted, c.label))

      place(top + left, dx: cx - body-w / 2, dy: y-sub-top, c.body)

      if merge {
        // Connector starts at THIS case's own body bottom, not at the max
        // across cases — otherwise short cases render with a visible gap
        // between their box and the downgoing line (taller sibling cases
        // like a nested switch inflate the shared y-sub-bot).
        let body-bot = y-sub-top + col-heights.at(i)
        place(top + left, dx: cx,
          line(start: (0pt, body-bot), end: (0pt, y-merge-line), stroke: stroke))
      }
    }

    if merge and cases.len() > 1 {
      place(top + left,
        line(start: (col-centers.first(), y-merge-line),
             end: (col-centers.last(), y-merge-line), stroke: stroke))
    }
  })
}

/// Decision with Yes / No branches that rejoin below into a shared exit.
/// Use when both arms belong to the main flow and must visibly reconverge
/// (e.g. an if-else that both return back to the outer pipeline).
///
/// ```typst
/// #flow-col(
///   process[Parse request],
///   branch-merge([Cached?],
///     yes: process[Return cached],
///     no:  process[Compute + cache],
///   ),
///   process[Respond],
/// )
/// ```
///
/// - `cond`: Diamond body.
/// - `yes` / `no`: Branch bodies (drop either to omit that side).
/// - `yes-label` / `no-label`: Arrow labels.
/// - `merge`: `true` (default) draws the bottom merge line + continuation
///   arrow; `false` stops at the sub-node bottoms.
/// - `diamond-width`: Horizontal diagonal of the diamond.
/// - `col-gap`: Horizontal spacing between the Yes and No columns.
#let branch-merge(
  cond,
  yes: none,
  no: none,
  yes-label: [Yes],
  no-label: [No],
  merge: true,
  diamond-width: 120pt,
  col-gap: 40pt,
) = {
  let cases = ()
  if yes != none { cases.push((label: yes-label, body: yes)) }
  if no != none { cases.push((label: no-label, body: no)) }
  _n-way-branch(cond, cases,
    merge: merge, diamond-width: diamond-width, col-gap: col-gap)
}

/// A `switch` case entry. Pairs an arrow label (shown on the line coming
/// down from the junction) with the body rendered below it.
#let case(label, body) = (label: label, body: body)

/// N-way switch/case: a single condition fans out to any number of
/// parallel branches that rejoin below. Cases are positional `case(label,
/// body)` entries; the label annotates the arrow from the junction down
/// to each body.
///
/// ```typst
/// #flow-col(
///   process[Receive event],
///   switch([kind],
///     case([order],  process[Place order]),
///     case([refund], process[Issue refund]),
///     case([cancel], process[Cancel order]),
///   ),
///   process[Emit audit log],
/// )
/// ```
///
/// - Positional args after `cond`: `case(label, body)` entries.
/// - Other params as in `branch-merge`.
#let switch(
  cond,
  ..cases,
  merge: true,
  diamond-width: 140pt,
  col-gap: 24pt,
) = _n-way-branch(cond, cases.pos(),
  merge: merge, diamond-width: diamond-width, col-gap: col-gap)

/// A loop visual: wraps a body (usually a `flow-col`) and draws a back-edge
/// along the left side that exits at the body's bottom-center, runs up, and
/// re-enters at the body's top-center with a downward arrowhead. The body
/// is centered in the block (phantom right-pad) so the whole thing drops
/// into an outer `flow-col` without horizontal misalignment.
///
/// Pair with an inner `branch` whose one arm is the loop exit — the
/// back-edge represents the "continue" path.
///
/// ```typst
/// #flow-loop(
///   flow-col(
///     process[Poll queue],
///     process[Handle job],
///     branch([More work?],
///       yes: process[Continue],
///       no:  terminal[Shutdown],
///     ),
///   ),
///   back-label: [continue],
/// )
/// ```
///
/// - `body`: Any content; typically a `flow-col`.
/// - `back-label`: Label on the vertical segment of the back-edge.
/// - `arm`: Horizontal distance from the body's main column (center) to the
///   back-edge's vertical segment. Measured from body-center (not bbox edge)
///   so the back-edge stays visually close to the column regardless of how
///   far the body extends sideways (e.g. when an inner `branch` exits right).
#let flow-loop(
  body,
  back-label: [retry],
  arm: 80pt,
) = context {
  let body-m = measure(body)
  let bw = body-m.width
  let bh = body-m.height

  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let head-size = 6pt

  // Vertical segments between the horizontal turns and the body: long enough
  // to visually read as an approach/descent, not just an arrow head.
  let approach-len = 14pt
  let descent-len = 14pt

  // Keep body-cx at the block's horizontal center so the block drops into an
  // outer `flow-col` without misalignment. When the body is wider than
  // `2*arm`, the back-edge lands inside the body's bbox (typically over
  // empty phantom area on the left of an inner `branch`). When narrower,
  // phantom padding extends the block to contain both sides.
  let half-w = calc.max(bw / 2, arm)
  let total-w = 2 * half-w
  let body-cx = half-w
  let body-x = body-cx - bw / 2
  let back-x = body-cx - arm

  let y-top-arm = 0pt
  let y-body-top = y-top-arm + approach-len + head-size
  let y-body-bot = y-body-top + bh
  let y-bot-arm = y-body-bot + descent-len
  let total-h = y-bot-arm + 2pt

  let head-down = polygon(fill: paint, stroke: none,
    (0pt, 0pt), (head-size, 0pt), (head-size / 2, head-size))

  block(width: total-w, height: total-h, {
    place(top + left, dx: body-x, dy: y-body-top, body)

    // Bottom: body-cx ↓ descent ↓ turn left → back-x
    place(top + left, dx: body-cx, dy: y-body-bot,
      line(start: (0pt, 0pt), end: (0pt, descent-len), stroke: stroke))
    place(top + left, dy: y-bot-arm,
      line(start: (body-cx, 0pt), end: (back-x, 0pt), stroke: stroke))

    // Back-edge vertical
    place(top + left, dx: back-x, dy: y-top-arm,
      line(start: (0pt, 0pt), end: (0pt, y-bot-arm - y-top-arm), stroke: stroke))

    // Top: back-x → turn right → body-cx ↓ approach ↓ arrow into body top
    place(top + left, dy: y-top-arm,
      line(start: (back-x, 0pt), end: (body-cx, 0pt), stroke: stroke))
    place(top + left, dx: body-cx, dy: y-top-arm,
      line(start: (0pt, 0pt), end: (0pt, approach-len), stroke: stroke))
    place(top + left, dx: body-cx - head-size / 2, dy: y-body-top - head-size,
      head-down)

    if back-label != none {
      place(top + left, dx: back-x + 4pt, dy: (y-top-arm + y-bot-arm) / 2 - 4pt,
        text(size: 0.6em, fill: palettes.base.text-muted, back-label))
    }
  })
}
