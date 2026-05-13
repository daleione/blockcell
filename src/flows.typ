// ============================================================================
// Flow-chart composites
// ============================================================================
//
// branch        - Diamond decision: Yes continues down, No branches right
// branch-merge  - Diamond with Yes / No columns that rejoin below
// switch        - N-way branch (diamond fans out to cases, rejoining below)
// n-way         - Generic N-way branch: choose diamond / bar / no header
// flow-loop     - Wraps a body with a back-edge on the left ("repeat")
// start-marker  - UML solid black start dot
// stop-marker   - UML solid dot inside ring (process end)
// end-marker    - UML "⊗" termination glyph
// detach-marker - "⊥" tee on a detached branch
// ============================================================================

#import "atoms.typ": *
#import "containers.typ": group as _group
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
/// - `diamond-width`: Horizontal diagonal of the diamond (default `12em`).
#let branch(
  cond,
  yes: none,
  no: none,
  yes-label: [Yes],
  no-label: [No],
  diamond-width: 12em,
) = context {
  let diamond-node = decision(cond, width: diamond-width)
  let no-cell = if no == none { box() } else {
    box({
      edge(direction: "right", label: no-label)
      h(0.2em)
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

/// Shared n-way branch layout used by `branch-merge`, `switch`, and the
/// fork / split painters. Renders a *header* node above N parallel
/// column-bodies joined by a top junction line (for the condition → case
/// arrows) and, when `merge: true`, a bottom merge line + continuation
/// down-arrow.
///
/// `header` chooses the visual at the top:
/// - `"diamond"` (default): a decision diamond carrying `cond` text. Used
///   by `switch` and `branch-merge`.
/// - `"bar"`: a thick horizontal bar (UML fork / join synchronisation
///   bar). `cond` is rendered as muted label text underneath when set.
/// - `"none"`: no header at all — just N parallel columns. Reserved for
///   `split` if a caller wants a bare branch.
///
/// Layout is computed from measured body sizes so lines hit the right
/// anchors without manual coordinates. The block's horizontal center
/// coincides with the header's center, letting it drop into `flow-col`
/// without misalignment.
#let n-way(
  cond,
  cases,
  header: "diamond",
  merge: true,
  merge-header: auto,
  diamond-width: 12em,
  col-gap: 4em,
) = context {
  let col-gap = col-gap.to-absolute()
  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let bar-h = 0.45em.to-absolute()

  // The diamond head is a measured node; the bar head's geometry depends on
  // the final case-span width (computed below), so we keep its actual
  // rendering inline. `head-m` is the bounding box of the head node.
  let head-node = if header == "diamond" {
    decision(cond, width: diamond-width)
  } else if header == "bar" or header == "none" {
    box()
  } else {
    panic("n-way: header must be \"diamond\", \"bar\", or \"none\"")
  }
  let head-m = if header == "diamond" { measure(head-node) }
                else if header == "bar" { (width: 0pt, height: bar-h) }
                else { (width: 0pt, height: 0pt) }
  if cases.len() == 0 { return head-node }

  // `merge-header` chooses what to draw at the bottom merge line: `"bar"`
  // matches `fork`/`split` (paired open + close bars); anything else just
  // renders the thin merge line. Default matches the top header so a fork
  // pair is symmetric out of the box.
  let merge-header = if merge-header == auto { header } else { merge-header }

  // Partition cases into *body* cases (each gets a real column) and
  // *bypass* cases (rendered as an overlay path that goes around the
  // body columns). Splitting them out is what keeps the body / diamond
  // on the block's vertical axis when `if (c) then (label) body endif`
  // is rendered — the bypass should not consume a column.
  let body-cases = ()
  let bypass-meta = ()    // (label, side, body?, detach?) entries
  let n-total = cases.len()
  for (i, c) in cases.enumerate() {
    if c.at("bypass", default: false) {
      // Side heuristic: for a 2-case input (the branch-merge case),
      // index 0 is the yes-arm (left) and index 1 is the no-arm
      // (right). For larger inputs, first half of the cases gets a
      // left bypass; second half gets a right bypass.
      let side = if n-total == 2 {
        if i == 0 { "left" } else { "right" }
      } else if i * 2 < n-total {
        "left"
      } else { "right" }
      bypass-meta.push((label: c.label, side: side, body: none, detach: false))
    } else {
      body-cases.push(c)
    }
  }

  // Swap mode: when the only body case terminates (e.g.
  // `if (c) then (label) stop endif`) the bypass is the path that
  // actually continues to the next statement, so it deserves the
  // centerline. Move the terminating body off-axis into the side
  // margin where the bypass used to live; the bypass itself collapses
  // to the centerline (a straight vertical line through the diamond).
  let swap-mode = (
    body-cases.len() == 1
      and body-cases.at(0).at("detach", default: false)
      and bypass-meta.len() > 0
  )
  if swap-mode {
    let bc = body-cases.at(0)
    let bp = bypass-meta.at(0)
    bypass-meta.at(0) = (
      label: bc.label,
      side: bp.side,
      body: bc.body,
      detach: true,
    )
    body-cases = ()
  }
  let n-body = body-cases.len()

  let body-ms = body-cases.map(c => measure(c.body))
  let col-w = body-ms.fold(0pt, (a, m) => calc.max(a, m.width))
  let col-heights = body-ms.map(m => m.height)

  let body-area-w = if n-body == 0 { 0pt } else {
    n-body * col-w + col-gap * (n-body - 1)
  }
  // Side body measurements (swap-mode and future cases where a bypass
  // case carries a body in the margin).
  let side-ms = bypass-meta.map(bp => {
    let b = bp.at("body", default: none)
    if b == none { (width: 0pt, height: 0pt) } else { measure(b) }
  })
  let max-side-w = side-ms.fold(0pt, (a, m) => calc.max(a, m.width))
  let max-side-h = side-ms.fold(0pt, (a, m) => calc.max(a, m.height))
  // The "core" is whatever sits on the centerline — body columns when
  // present, otherwise just the head. Bypass arms have to land OUTSIDE
  // the core, so the half-width here drives how far out the bypass-x
  // sits. Taking the diamond's half-width into account is critical for
  // swap-mode (no body columns), where without it the bypass-x would
  // land inside the diamond's bbox and the horizontal arm would bend
  // back into the diamond's interior.
  let core-half = calc.max(body-area-w / 2, head-m.width / 2)
  // Reserved margin on each side for bypass paths. Always allocate
  // symmetrically so the body / diamond stay on the block's geometric
  // centre — important so the enclosing flow-col's auto-arrow lines up.
  let bypass-margin = if bypass-meta.len() > 0 {
    calc.max(3.2em.to-absolute(), max-side-w + 1.4em.to-absolute())
  } else { 0pt }
  let total-w = 2 * core-half + 2 * bypass-margin
  let body-area-left = (total-w - body-area-w) / 2

  let col-centers = range(n-body).map(i =>
    body-area-left + col-w / 2 + i * (col-w + col-gap))
  let center-x = total-w / 2

  let head-size = 0.6em.to-absolute()
  let junction-gap = 1em.to-absolute()
  let arrow-len = 2.4em.to-absolute()
  // sub-h is the descent height shared by body columns and any
  // side-margin bodies, so the merge line clears all of them.
  let sub-h = calc.max(
    col-heights.fold(0pt, (a, b) => calc.max(a, b)),
    max-side-h,
  )
  let merge-gap = 1em.to-absolute()

  let y-head-bot = head-m.height
  let y-junction = y-head-bot + junction-gap
  let y-sub-top = y-junction + arrow-len
  let y-sub-bot = y-sub-top + sub-h
  let y-merge-line = y-sub-bot + merge-gap

  let total-h = if merge { y-merge-line + 0.1em.to-absolute() } else { y-sub-bot }
  let label-gap = 0.3em.to-absolute()

  let head-down = polygon(fill: paint, stroke: none,
    (0pt, 0pt), (head-size, 0pt), (head-size / 2, head-size))

  // Bar geometry: spans the body columns (with overhang). When there
  // are no body columns at all (rare: pure-bypass switch), fall back
  // to a small centred bar so the bypass still has a head to exit from.
  let bar-overhang = 0.6em.to-absolute()
  let bar-left = if n-body > 1 { col-centers.first() - bar-overhang }
    else if n-body == 1 { col-centers.first() - 3em.to-absolute() }
    else { center-x - 3em.to-absolute() }
  let bar-right = if n-body > 1 { col-centers.last() + bar-overhang }
    else if n-body == 1 { col-centers.first() + 3em.to-absolute() }
    else { center-x + 3em.to-absolute() }

  block(width: total-w, height: total-h, {
    if header == "diamond" {
      place(top + left, dx: center-x - head-m.width / 2, head-node)
    } else if header == "bar" {
      place(top + left, dx: bar-left,
        rect(width: bar-right - bar-left, height: bar-h, fill: black, stroke: none))
      if cond != none and cond != [] {
        place(top + left, dx: bar-right + 0.4em.to-absolute(), dy: -0.1em.to-absolute(),
          text(size: 0.6em, fill: palettes.base.text-muted, cond))
      }
    }

    // Trunk + junction row from head bottom — only when there's at
    // least one body column to descend into.
    if n-body > 0 {
      place(top + left, dx: center-x,
        line(start: (0pt, y-head-bot), end: (0pt, y-junction), stroke: stroke))

      if n-body > 1 {
        place(top + left,
          line(start: (col-centers.first(), y-junction),
               end: (col-centers.last(), y-junction), stroke: stroke))
      }

      for (i, c) in body-cases.enumerate() {
        let cx = col-centers.at(i)
        let body-w = body-ms.at(i).width

        place(top + left, dx: cx,
          line(start: (0pt, y-junction),
               end: (0pt, y-sub-top - head-size), stroke: stroke))
        place(top + left, dx: cx - head-size / 2, dy: y-sub-top - head-size,
          head-down)

        place(top + left,
          dx: cx + head-size / 2 + label-gap,
          dy: y-junction + (arrow-len - head-size) / 2 - label-gap,
          text(size: 0.6em, fill: palettes.base.text-muted, c.label))

        place(top + left, dx: cx - body-w / 2, dy: y-sub-top, c.body)

        let case-detach = c.at("detach", default: false)
        if merge and not case-detach {
          let body-bot = y-sub-top + col-heights.at(i)
          place(top + left, dx: cx,
            line(start: (0pt, body-bot), end: (0pt, y-merge-line), stroke: stroke))
        }
      }
    }

    // When there's no centerline body column (e.g. swap mode for an
    // `if (c) then (label) stop endif` — the main flow continues
    // through the diamond's bottom because the terminating body has
    // been moved to the side), draw a straight trunk from the head
    // bottom all the way to the merge line.
    if n-body == 0 and merge {
      place(top + left, dx: center-x,
        line(start: (0pt, y-head-bot), end: (0pt, y-merge-line), stroke: stroke))
    }

    // Bypass overlay paths. The exit is the diamond's side vertex (for
    // header == "diamond") or the bar end (for header == "bar"); the
    // path runs into the side margin, optionally renders a body there
    // (swap mode), descends past it, and bends back to centre-x at the
    // merge line. This keeps the diamond / body / merge column on the
    // single vertical axis the enclosing flow-col expects.
    let head-mid-y = head-m.height / 2
    let head-right-x = center-x + head-m.width / 2
    let head-left-x = center-x - head-m.width / 2
    let bar-mid-y = bar-h / 2
    for (k, bp) in bypass-meta.enumerate() {
      let bp-body = bp.at("body", default: none)
      let bp-detach = bp.at("detach", default: false)
      let side-m = side-ms.at(k)
      let exit-y = if header == "diamond" { head-mid-y } else { bar-mid-y }
      let exit-x = if bp.side == "right" {
        if header == "diamond" { head-right-x } else { bar-right }
      } else {
        if header == "diamond" { head-left-x } else { bar-left }
      }
      // Bypass column lies in the side margin — beyond `core-half` from
      // centre so it sits outside the body columns AND outside the
      // diamond's bbox.
      let bypass-x = if bp.side == "right" {
        center-x + core-half + bypass-margin / 2
      } else {
        center-x - core-half - bypass-margin / 2
      }
      // Horizontal arm away from the head.
      place(top + left,
        line(start: (calc.min(exit-x, bypass-x), exit-y),
             end: (calc.max(exit-x, bypass-x), exit-y), stroke: stroke))

      if bp-body == none {
        // Pure bypass — vertical descent through the side margin and
        // (when merging) horizontal back to centre.
        place(top + left, dx: bypass-x, dy: exit-y,
          line(start: (0pt, 0pt), end: (0pt, y-merge-line - exit-y), stroke: stroke))
        if merge {
          place(top + left, dy: y-merge-line,
            line(start: (calc.min(bypass-x, center-x), 0pt),
                 end: (calc.max(bypass-x, center-x), 0pt), stroke: stroke))
        }
      } else {
        // Side branch with a body. Descend from the head row to the
        // body's top, render the body inline, then either stop (detach)
        // or continue down + back to centre at the merge line.
        let body-top = y-sub-top
        place(top + left, dx: bypass-x, dy: exit-y,
          line(start: (0pt, 0pt), end: (0pt, body-top - exit-y - head-size), stroke: stroke))
        place(top + left, dx: bypass-x - head-size / 2, dy: body-top - head-size,
          head-down)
        place(top + left, dx: bypass-x - side-m.width / 2, dy: body-top, bp-body)
        let body-bot = body-top + side-m.height
        if not bp-detach and merge {
          place(top + left, dx: bypass-x, dy: body-bot,
            line(start: (0pt, 0pt), end: (0pt, y-merge-line - body-bot), stroke: stroke))
          place(top + left, dy: y-merge-line,
            line(start: (calc.min(bypass-x, center-x), 0pt),
                 end: (calc.max(bypass-x, center-x), 0pt), stroke: stroke))
        }
      }

      // Label adjacent to the head exit.
      let lbl-dx = if bp.side == "right" {
        exit-x + 0.3em.to-absolute()
      } else {
        exit-x - 2.2em.to-absolute()
      }
      place(top + left, dx: lbl-dx, dy: exit-y - 0.95em.to-absolute(),
        text(size: 0.6em, fill: palettes.base.text-muted, bp.label))
    }

    // Bottom merge line — joins the live body columns. Bypass arms
    // already join at centre-x, so when there's exactly one live body
    // case at centre-x and no other body columns, no horizontal line
    // is needed.
    let live-body = body-cases.filter(c => not c.at("detach", default: false))
    if merge and live-body.len() > 0 {
      if merge-header == "bar" {
        place(top + left, dx: bar-left, dy: y-merge-line - bar-h / 2,
          rect(width: bar-right - bar-left, height: bar-h, fill: black, stroke: none))
      } else if live-body.len() > 1 {
        let live-centers = ()
        for (i, c) in body-cases.enumerate() {
          if not c.at("detach", default: false) {
            live-centers.push(col-centers.at(i))
          }
        }
        let l = calc.min(live-centers.first(), center-x)
        let r = calc.max(live-centers.last(), center-x)
        if l != r {
          place(top + left,
            line(start: (l, y-merge-line), end: (r, y-merge-line), stroke: stroke))
        }
      }
    }
  })
}

/// Backwards-compatible alias. Retained so external callers that imported
/// `_n-way-branch` still resolve; new code should call `n-way` directly.
#let _n-way-branch = n-way

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
  yes-detach: false,
  no-detach: false,
  yes-bypass: false,
  no-bypass: false,
  merge: true,
  diamond-width: 120pt,
  col-gap: 40pt,
) = {
  let cases = ()
  if yes != none {
    cases.push((label: yes-label, body: yes, detach: yes-detach, bypass: yes-bypass))
  }
  if no != none {
    cases.push((label: no-label, body: no, detach: no-detach, bypass: no-bypass))
  }
  n-way(cond, cases,
    header: "diamond", merge-header: "none",
    merge: merge, diamond-width: diamond-width, col-gap: col-gap)
}

/// A `switch` case entry. Pairs an arrow label (shown on the line coming
/// down from the junction) with the body rendered below it.
///
/// - `detach`: when `true`, the case body terminates (e.g. it ends with a
///   `stop-marker()` / `end-marker()` / `detach-marker()`) and the painter
///   should NOT draw the rejoin connector from this column to the bottom
///   merge line. Matches PlantUML's behaviour where an `if` branch ending
///   in `stop` doesn't loop back to the outer flow.
/// - `bypass`: when `true`, this case has no body — it's a "skip" arm on
///   the diamond / bar. The column allocates only a narrow width (just
///   the connector + label); the merge connector still runs from
///   junction to merge-line. Used for `if (c) then (label) body endif`
///   without an else: the opposite side renders as a bypass.
#let case(label, body, detach: false, bypass: false) = (
  label: label, body: body, detach: detach, bypass: bypass,
)

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
  diamond-width: 14em,
  col-gap: 2.4em,
) = n-way(cond, cases.pos(),
  header: "diamond", merge-header: "none",
  merge: merge, diamond-width: diamond-width, col-gap: col-gap)

/// UML fork / split: N parallel branches with solid sync-bars at the top
/// and (when `merge: true`) at the bottom. Visually identical for
/// `fork`/`split`; semantically callers can distinguish them at the codegen
/// layer (PlantUML's `fork` = concurrent, `split` = alternative paths that
/// rejoin).
///
/// ```typst
/// #flow-col(
///   process[receive order],
///   fork-bar(
///     case([], flow-col(process[email confirmation])),
///     case([], flow-col(process[notify warehouse])),
///   ),
///   process[archive],
/// )
/// ```
#let fork-bar(
  ..cases,
  merge: true,
  col-gap: 3em,
  label: none,
) = n-way(label, cases.pos(),
  header: "bar", merge-header: "bar",
  merge: merge, col-gap: col-gap)

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
  arm: 8em,
) = context {
  let body-m = measure(body)
  let bw = body-m.width
  let bh = body-m.height
  let arm = arm.to-absolute()

  let stroke = 0.8pt + palettes.base.border
  let paint = std.stroke(stroke).paint
  let head-size = 0.6em.to-absolute()

  // Vertical segments between the horizontal turns and the body: long enough
  // to visually read as an approach/descent, not just an arrow head.
  let approach-len = 1.4em.to-absolute()
  let descent-len = 1.4em.to-absolute()

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
  let total-h = y-bot-arm + 0.2em.to-absolute()
  let label-offset = 0.4em.to-absolute()

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
      place(top + left, dx: back-x + label-offset, dy: (y-top-arm + y-bot-arm) / 2 - label-offset,
        text(size: 0.6em, fill: palettes.base.text-muted, back-label))
    }
  })
}

// ----------------------------------------------------------------------------
// Activity start / stop / end / detach markers
// ----------------------------------------------------------------------------

/// UML activity start: a solid filled circle. Drops into `flow-col` like
/// any other node — `flow-col` connects it to the next node with a
/// down-arrow automatically.
#let start-marker(size: 0.9em, fill: black) = context {
  let s = size.to-absolute()
  box(width: s, height: s, baseline: 30%,
    place(top + left,
      circle(radius: s / 2, fill: fill, stroke: none)))
}

/// UML activity stop: a solid filled circle inside a thin ring. Visually
/// distinct from `start-marker` to read as a process termination.
#let stop-marker(size: 1em, fill: black) = context {
  let s = size.to-absolute()
  let inner = s * 0.55
  box(width: s, height: s, baseline: 30%, {
    place(top + left,
      circle(radius: s / 2, fill: none, stroke: 1pt + fill))
    place(center + horizon,
      circle(radius: inner / 2, fill: fill, stroke: none))
  })
}

/// UML activity end / abort: a circle with an X crossing through it ("⊗").
/// Used after exceptional / aborted termination — visually different from
/// the normal `stop` exit.
#let end-marker(size: 1em, fill: black) = context {
  let s = size.to-absolute()
  let stroke = 1pt + fill
  // The diagonal lines sit on a 45° axis through the centre. We inset a
  // little so the cross sits *inside* the circle.
  let inset = s * 0.18
  box(width: s, height: s, baseline: 30%, {
    place(top + left,
      circle(radius: s / 2, fill: none, stroke: stroke))
    place(top + left,
      line(start: (inset, inset), end: (s - inset, s - inset), stroke: stroke))
    place(top + left,
      line(start: (s - inset, inset), end: (inset, s - inset), stroke: stroke))
  })
}

/// UML activity `detach` / `kill`: a "⊥" tee that marks a branch which
/// does not rejoin the rest of the flow.
#let detach-marker(size: 0.9em, color: black) = context {
  let s = size.to-absolute()
  let stroke = 1pt + color
  box(width: s, height: s, baseline: 30%, {
    // Horizontal bar across the top of the tee.
    place(top + left, dy: s * 0.15,
      line(start: (0pt, 0pt), end: (s, 0pt), stroke: stroke))
    // Vertical stem from the bar down to the bottom.
    place(top + left, dx: s / 2, dy: s * 0.15,
      line(start: (0pt, 0pt), end: (0pt, s * 0.85), stroke: stroke))
  })
}

// ----------------------------------------------------------------------------
// Partition / package / rectangle / card / group container
// ----------------------------------------------------------------------------

/// PlantUML `partition Name { … }` (and `package` / `rectangle` / `card` /
/// `group` synonyms — see CommandPartition3.java). Renders the body inside
/// a labelled rounded frame; `kind` selects the stroke style so the five
/// PlantUML keywords visually differ.
///
/// - `partition` / `package` — dashed rounded frame with a tinted label
///   chip in the top-left.
/// - `rectangle` — solid stroke, square corners.
/// - `card` — solid stroke, more rounded.
/// - `group` — bare bordered frame, no chip.
///
/// Body is expected to be a `flow-col(...)` produced by the activity
/// codegen.
#let partition(
  body,
  label: none,
  color: none,
  kind: "partition",
) = {
  let fill = if color == none {
    palettes.base.surface-alt
  } else { color }
  let stroke-paint = palettes.base.border
  let (dash, radius, stroke-weight) = if kind == "partition" or kind == "package" {
    ("dashed", 6pt, 1pt)
  } else if kind == "card" {
    (none, 8pt, 0.9pt)
  } else if kind == "rectangle" {
    (none, 0pt, 0.9pt)
  } else if kind == "group" {
    (none, 4pt, 0.7pt)
  } else {
    ("dashed", 6pt, 1pt)
  }
  _group(
    body,
    label: if kind == "group" { none } else { label },
    fill: fill,
    stroke: stroke-weight + stroke-paint,
    dash: dash,
    radius: radius,
    inset: 1em,
    content-align: center,
  )
}

// ----------------------------------------------------------------------------
// Swimlanes
// ----------------------------------------------------------------------------

/// PlantUML `|Lane|` swimlane rendering. Lays out N vertical lanes side by
/// side; each lane gets a coloured title band at the top and a flow-col
/// body underneath.
///
/// `lanes` is a positional list of `(label, body, color)` triples. Use the
/// helper `lane(label, body, color: ...)` to build one.
///
/// Cross-lane connectors (the visual jumps that PlantUML draws when a
/// statement on one lane is followed by one on a different lane) are not
/// rendered in this first cut — each lane is a self-contained column.
/// The dashed vertical lane separators make the grouping obvious.
#let lane(label, body, color: none) = (label: label, body: body, color: color)

#let swimlane(
  ..lanes,
  lane-min-width: 9em,
  gap: 0pt,
) = context {
  let entries = lanes.pos()
  if entries.len() == 0 { return [] }

  let title-stroke = 0.8pt + palettes.base.border
  let sep-stroke = (paint: palettes.base.border-soft, thickness: 0.6pt, dash: "dashed")

  // Per-lane column width: at least `lane-min-width`, at most the natural
  // body / title width — whichever is larger.
  let lane-widths = entries.map(e => {
    let lbl-w = if e.label == none or e.label == [] { 0pt } else {
      measure(text(weight: "bold", e.label)).width + 1.2em.to-absolute()
    }
    let body-w = measure(e.body).width
    calc.max(lane-min-width.to-absolute(), calc.max(lbl-w, body-w))
  })

  // Build title row + body row.
  let title-cells = entries.zip(lane-widths).map(((e, w)) => {
    let fill = if e.color == none { palettes.base.surface-alt } else { e.color }
    block(
      width: w,
      fill: fill,
      stroke: title-stroke,
      inset: (x: 0.6em, y: 0.4em),
      align(center, text(weight: "bold", size: 0.9em, e.label)),
    )
  })
  let body-cells = entries.zip(lane-widths).map(((e, w)) => {
    block(
      width: w,
      stroke: (left: sep-stroke, right: sep-stroke),
      inset: (x: 0.4em, y: 0.6em),
      align(center, e.body),
    )
  })

  let cols = lane-widths
  grid(
    columns: cols,
    column-gutter: gap,
    row-gutter: 0pt,
    ..title-cells,
    ..body-cells,
  )
}

// ----------------------------------------------------------------------------
// Activity note attachment
// ----------------------------------------------------------------------------

/// PlantUML `note left` / `note right` — a yellow sticky-note rectangle
/// rendered standalone. To attach it to a `process[...]` use
/// `with-notes(...)`, which places the note next to the host node and
/// keeps the node visually on the column axis so `flow-col`'s auto-arrows
/// still hit center.
#let flow-note(
  body,
  fill: rgb("#FFF8DC"),
  stroke: 0.6pt + rgb("#B8860B"),
) = box(
  fill: fill,
  stroke: stroke,
  radius: 2pt,
  inset: (x: 0.5em, y: 0.3em),
  baseline: 30%,
  text(size: 0.85em, body),
)

/// Wrap a flow-node with notes attached to its sides. Symmetric padding
/// keeps the node on the column's vertical axis — `flow-col`'s auto-arrow
/// continues to align with the node's center rather than the row's
/// geometric mid-point.
///
/// - `node`: the host node (e.g. `process[…]`).
/// - `left` / `right`: arrays of `flow-note(...)` instances. Each side
///   stacks its notes vertically.
/// - `edge-label`: when set, the wrapped row carries the same
///   `flow-node-wrapped` sentinel as a bare `flow-node(edge-label: …)`,
///   so `flow-col` still attaches the label to the inbound arrow.
/// - `gap`: horizontal space between the node and its notes.
#let with-notes(
  node,
  left-notes: (),
  right-notes: (),
  edge-label: none,
  gap: 1.2em,
) = {
  let wrapped = context {
    let gap = gap.to-absolute()
    let left-stack = if left-notes.len() == 0 { [] } else {
      std.stack(dir: ttb, spacing: 0.3em, ..left-notes)
    }
    let right-stack = if right-notes.len() == 0 { [] } else {
      std.stack(dir: ttb, spacing: 0.3em, ..right-notes)
    }
    let left-w = if left-notes.len() == 0 { 0pt } else { measure(left-stack).width }
    let right-w = if right-notes.len() == 0 { 0pt } else { measure(right-stack).width }
    // Symmetric padding so the node stays on the column axis — flow-col's
    // auto-arrow still hits the node center, not the row's geometric centre.
    let side-w = calc.max(left-w, right-w)
    let pad = if side-w > 0pt { side-w + gap } else { 0pt }

    grid(
      columns: (pad, auto, pad),
      align: (right + horizon, center + horizon, left + horizon),
      column-gutter: 0pt,
      if left-notes.len() == 0 { [] } else { left-stack },
      node,
      if right-notes.len() == 0 { [] } else { right-stack },
    )
  }
  if edge-label == none {
    wrapped
  } else {
    (flow-node-wrapped: true, body: wrapped, edge-label: edge-label)
  }
}
