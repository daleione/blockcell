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
  // Use a square cap so the perpendicular segments that compose every
  // L-corner in this layout (top junction, bottom merge, bypass arms)
  // overlap by half a stroke width and don't leave a notch at the join.
  let stroke = std.stroke(thickness: 0.8pt, paint: palettes.base.border, cap: "square")
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
  // Label that should travel with the centerline trunk after swap —
  // the original bypass label (e.g. the "no" arm of an `if (c) then
  // (yes) break endif`) would otherwise be lost when bypass-meta is
  // overwritten with the body-case data below.
  let trunk-label = none
  if swap-mode {
    let bc = body-cases.at(0)
    let bp = bypass-meta.at(0)
    trunk-label = bp.label
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
  // Swap mode has no body column on the centerline — just a small side stop
  // in the margin. The full junction descent / merge gap (sized for body
  // columns) would pad the centerline trunk out to ~2x a normal edge, so the
  // next node ends up far below the diamond. Use tight gaps there: the trunk
  // stays close to one edge length and the side stop tucks beside the diamond,
  // matching PlantUML's `if (c) then (label) stop endif` spacing.
  let junction-gap = if swap-mode { 0.4em.to-absolute() } else { 1em.to-absolute() }
  let arrow-len = if swap-mode { 0.6em.to-absolute() } else { 2.4em.to-absolute() }
  // sub-h is the descent height shared by body columns and any
  // side-margin bodies, so the merge line clears all of them.
  let sub-h = calc.max(
    col-heights.fold(0pt, (a, b) => calc.max(a, b)),
    max-side-h,
  )
  // For a bar merge-header (fork/split), match the bottom gap to the
  // top descent (junction-gap + arrow-len) so the body sits visually
  // centred between the two sync bars. The diamond case keeps the
  // tighter 1em gap because there is no bar to balance against.
  let merge-gap = if merge-header == "bar" {
    junction-gap + arrow-len
  } else if swap-mode {
    0.4em.to-absolute()
  } else {
    1em.to-absolute()
  }

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
    //
    // For "bar" headers (fork/split sync-bar), each branch arrow drops
    // straight off the bar — the bar itself already spans horizontally,
    // so there's no central trunk and no junction line. For "diamond"
    // (and "none") headers, a short trunk drops to a junction line
    // which fans out to per-column verticals.
    if n-body > 0 {
      let drop-start-y = if header == "bar" { y-head-bot } else { y-junction }

      if header != "bar" {
        place(top + left, dx: center-x,
          line(start: (0pt, y-head-bot), end: (0pt, y-junction), stroke: stroke))

        if n-body > 1 {
          place(top + left,
            line(start: (col-centers.first(), y-junction),
                 end: (col-centers.last(), y-junction), stroke: stroke))
        }
      }

      for (i, c) in body-cases.enumerate() {
        let cx = col-centers.at(i)
        let body-w = body-ms.at(i).width
        let body-h = col-heights.at(i)
        // A body slot whose measured size is essentially zero (e.g.
        // `flow-col([])` from a no-op branch like `if (c) then (yes)
        // break endif`) would otherwise show the column-entry arrow
        // immediately above the body-bottom continuation arrow into
        // the next sibling, producing two stacked arrowheads. Collapse
        // the column into a single straight trunk in that case.
        let case-detach = c.at("detach", default: false)
        let is-empty = body-w <= 0.1pt and body-h <= 0.1pt

        if is-empty and merge and not case-detach {
          place(top + left, dx: cx,
            line(start: (0pt, drop-start-y),
                 end: (0pt, y-merge-line), stroke: stroke))
          place(top + left,
            dx: cx + head-size / 2 + label-gap,
            dy: y-junction + (arrow-len - head-size) / 2 - label-gap,
            text(size: 0.6em, fill: palettes.base.text-muted, c.label))
          continue
        }

        place(top + left, dx: cx,
          line(start: (0pt, drop-start-y),
               end: (0pt, y-sub-top - head-size), stroke: stroke))
        place(top + left, dx: cx - head-size / 2, dy: y-sub-top - head-size,
          head-down)

        place(top + left,
          dx: cx + head-size / 2 + label-gap,
          dy: y-junction + (arrow-len - head-size) / 2 - label-gap,
          text(size: 0.6em, fill: palettes.base.text-muted, c.label))

        place(top + left, dx: cx - body-w / 2, dy: y-sub-top, c.body)

        if merge and not case-detach {
          let body-bot = y-sub-top + body-h
          if merge-header == "bar" {
            // Each branch arrow lands on the top edge of the merge bar
            // with an arrowhead, mirroring the down-arrows from the top
            // bar into each body.
            let bar-top = y-merge-line - bar-h / 2
            place(top + left, dx: cx,
              line(start: (0pt, body-bot), end: (0pt, bar-top - head-size), stroke: stroke))
            place(top + left, dx: cx - head-size / 2, dy: bar-top - head-size,
              head-down)
          } else {
            place(top + left, dx: cx,
              line(start: (0pt, body-bot), end: (0pt, y-merge-line), stroke: stroke))
          }
        }
      }
    }

    // When there's no centerline body column (e.g. swap mode for an
    // `if (c) then (label) stop endif` — the main flow continues
    // through the diamond's bottom because the terminating body has
    // been moved to the side), draw a straight trunk from the head
    // bottom down through the merge line and carry the trunk's label
    // adjacent to it. Like a normal merge trunk this is headless: the
    // enclosing `flow-col` inserts the directional arrow into the next
    // node, so adding one here too would stack a second arrowhead
    // mid-trunk and visually break the line.
    //
    // The trunk runs a touch past the merge line (≈0.9em) so it overlaps
    // the head of the `flow-col` edge that follows: the block's laid-out
    // height ends at the merge line, but that auto-edge starts a few
    // points lower, and without the overlap the centerline shows a gap
    // between the diamond's trunk and the arrow into the next node.
    if n-body == 0 and merge {
      place(top + left, dx: center-x,
        line(start: (0pt, y-head-bot), end: (0pt, y-merge-line + 0.9em.to-absolute()), stroke: stroke))
      if trunk-label != none {
        let trunk-mid-y = (y-head-bot + y-merge-line) / 2
        place(top + left,
          dx: center-x + head-size / 2 + label-gap,
          dy: trunk-mid-y - head-size / 2 - label-gap,
          text(size: 0.6em, fill: palettes.base.text-muted, trunk-label))
      }
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
        // (when merging) horizontal back to centre. Place an
        // arrowhead at the vertical midpoint of the descent so the
        // bypass shows direction (otherwise the No arm of a typical
        // `if (c) then body endif` rendered with bypass: true looks
        // undirected).
        place(top + left, dx: bypass-x, dy: exit-y,
          line(start: (0pt, 0pt), end: (0pt, y-merge-line - exit-y), stroke: stroke))
        if merge {
          place(top + left, dy: y-merge-line,
            line(start: (calc.min(bypass-x, center-x), 0pt),
                 end: (calc.max(bypass-x, center-x), 0pt), stroke: stroke))
          let bypass-mid-y = (exit-y + y-merge-line) / 2
          place(top + left, dx: bypass-x - head-size / 2,
            dy: bypass-mid-y - head-size / 2,
            head-down)
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
      } else {
        // Gather live-body column centers and bridge them across to
        // centre-x at the merge line. With a single surviving body case
        // (the other side detached via `stop`), its column-centre is
        // typically off-axis from the block's centre-x, so without this
        // bridge the enclosing `flow-col`'s auto-arrow to the next node
        // would dangle in space.
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
        // Exit trunk from the merge line down to the block's bottom edge,
        // so the enclosing flow-col's next down-arrow abuts it cleanly
        // instead of leaving a visible vertical gap across the 0.1em pad.
        place(top + left, dx: center-x,
          line(start: (0pt, y-merge-line), end: (0pt, total-h), stroke: stroke))
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
) = (
  // Wrap as a flow-col sentinel so the enclosing `flow-col` draws its
  // gap edge as a *headless* line above this block — the entry
  // arrowhead is supplied internally below at the body's top border,
  // so the loop-back arm and the external entry visually converge into
  // a single arrowhead instead of stacking two.
  flow-node-wrapped: true,
  supplies-entry: true,
  edge-label: none,
  body: context {
    let body-m = measure(body)
    let bw = body-m.width
    let bh = body-m.height
    let arm = arm.to-absolute()

    let stroke = 0.8pt + palettes.base.border
    let paint = std.stroke(stroke).paint
    let head-size = 0.6em.to-absolute()

    // Vertical segments between the horizontal turns and the body:
    // long enough to read as approach/descent rather than just an
    // arrow head.
    let approach-len = 1.4em.to-absolute()
    let descent-len = 1.4em.to-absolute()

    // Keep body-cx at the block's horizontal center so the block drops
    // into an outer `flow-col` without misalignment. When the body is
    // wider than `2*arm`, the back-edge lands inside the body's bbox
    // (typically over empty phantom area on the left of an inner
    // `branch`). When narrower, phantom padding extends the block to
    // contain both sides.
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
    let head-up = polygon(fill: paint, stroke: none,
      (0pt, head-size), (head-size, head-size), (head-size / 2, 0pt))

    block(width: total-w, height: total-h, {
      place(top + left, dx: body-x, dy: y-body-top, body)

      // Bottom: body-cx ↓ descent ↓ turn left → back-x
      place(top + left, dx: body-cx, dy: y-body-bot,
        line(start: (0pt, 0pt), end: (0pt, descent-len), stroke: stroke))
      place(top + left, dy: y-bot-arm,
        line(start: (body-cx, 0pt), end: (back-x, 0pt), stroke: stroke))

      // Back-edge vertical. Midpoint gets an upward arrowhead so the
      // back-edge's direction is visible without relying solely on
      // the re-entry arrow at the top.
      place(top + left, dx: back-x, dy: y-top-arm,
        line(start: (0pt, 0pt), end: (0pt, y-bot-arm - y-top-arm), stroke: stroke))
      let back-mid-y = (y-top-arm + y-bot-arm) / 2
      place(top + left, dx: back-x - head-size / 2,
        dy: back-mid-y - head-size / 2,
        head-up)

      // Top: back-x → turn right → body-cx ↓ approach into body top
      // with a single arrowhead at the body's top border. Because the
      // enclosing flow-col drops a headless line above this block, the
      // external entry and the loop-back arm both converge into this
      // one arrowhead.
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
  },
)

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

/// Measure protocol probe for swimlane nodes — mirrors `record-probe` /
/// `cuca-probe`. Codegen emits one of these per activity action in a
/// pass-1 doc; Rust queries the `<typstuml_measure>` metadata to learn
/// each node's natural width / height before solving lane widths and
/// per-node placement.
/// Unwrap the `flow-node-wrapped` sentinel dict (produced by `flow-loop`
/// and similar) into plain content. Pass-through for anything that's
/// already content. Used by the swimlane probe and painter so a
/// compound node containing a `flow-loop` can still be measured /
/// placed.
#let _swimlane-unwrap(node) = if type(node) == dictionary and node.at("flow-node-wrapped", default: false) {
  node.body
} else {
  node
}

#let swimlane-probe(id: none, body) = context {
  let m = measure(_swimlane-unwrap(body))
  [#metadata((
    id: id,
    w: m.width.pt(),
    h: m.height.pt(),
  )) <typstuml_measure>]
}

/// Absolute-position swimlane painter — the "principled" replacement for
/// the grid-based `swimlane` above. Rust pre-solves lane columns + per-node
/// (x, y) bboxes + cross-lane polyline edges; this painter composes
/// everything on one `block` canvas so cross-lane connectors are plain
/// `line()` calls in the same coordinate frame as the nodes.
///
/// Args:
/// - `title`: optional bold title above the canvas.
/// - `lanes`: `((label, color, x, width), ...)` — `x` and `width` define
///   each lane column in canvas coordinates.
/// - `nodes`: `((content, x, y), ...)` — top-left placement of each node
///   inside the body area (the header band is added internally).
/// - `edges`: `((points: ((x, y), ...), arrow: bool), ...)` — polylines.
///   Intra-lane edges are typically 2 points (straight down); cross-lane
///   edges follow the PlantUML 4-point "down → across → down" snake.
/// - `header-height`: thickness of the lane title band.
/// - `body-height`: height of the lane body area (canvas total = header
///   + body). Rust computes from the lowest node + slack.
#let swimlane-layout(
  title: none,
  lanes: (),
  nodes: (),
  edges: (),
  header-height: 2em,
  body-height: 0pt,
) = context {
  let header-h = header-height.to-absolute()
  let body-h = body-height.to-absolute()
  let canvas-w = lanes.fold(0pt, (a, l) => calc.max(a, l.x + l.width))
  let canvas-h = header-h + body-h

  let title-stroke = 0.8pt + palettes.base.border
  let sep-stroke = (paint: palettes.base.border-soft, thickness: 0.6pt, dash: "dashed")
  // Square cap so multi-segment polylines (the cross-lane snake) join
  // cleanly at their L-corners without a butt-cap notch.
  let edge-stroke = std.stroke(
    thickness: 0.8pt, paint: palettes.base.border, cap: "square",
  )
  let arrow-color = palettes.base.border
  let head-size = 0.6em.to-absolute()

  // Direction-aware arrowhead at the end of a polyline.
  let head-poly(dx-sign, dy-sign, vertical) = if vertical {
    if dy-sign >= 0 {
      polygon(fill: arrow-color, stroke: none,
        (0pt, 0pt), (head-size, 0pt), (head-size / 2, head-size))
    } else {
      polygon(fill: arrow-color, stroke: none,
        (0pt, head-size), (head-size, head-size), (head-size / 2, 0pt))
    }
  } else {
    if dx-sign >= 0 {
      polygon(fill: arrow-color, stroke: none,
        (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size))
    } else {
      polygon(fill: arrow-color, stroke: none,
        (head-size, 0pt), (0pt, head-size / 2), (head-size, head-size))
    }
  }

  let body = block(width: canvas-w, height: canvas-h, breakable: false, {
    // Header band: per-lane background + label.
    for l in lanes {
      let fill = if l.color == none { palettes.base.surface-alt } else { l.color }
      place(top + left, dx: l.x, dy: 0pt,
        block(width: l.width, height: header-h, fill: fill, stroke: title-stroke,
          align(center + horizon, text(weight: "bold", size: 0.9em, l.label))))
    }

    // Body-area dashed separators between lane columns and at the outer
    // edges.
    for l in lanes {
      place(top + left, dx: l.x, dy: header-h,
        line(start: (0pt, 0pt), end: (0pt, body-h), stroke: sep-stroke))
    }
    let last = lanes.last()
    place(top + left, dx: last.x + last.width, dy: header-h,
      line(start: (0pt, 0pt), end: (0pt, body-h), stroke: sep-stroke))

    // Nodes — placed at their pre-computed (x, y) inside the body area.
    for n in nodes {
      place(top + left, dx: n.x, dy: header-h + n.y, _swimlane-unwrap(n.content))
    }

    // Polyline edges. Each segment is a separate `line()`; the shared
    // square cap makes L-corners join without notches. Optional arrowhead
    // anchored to the final segment's direction.
    for e in edges {
      let pts = e.points.map(p => (p.at(0), header-h + p.at(1)))
      if pts.len() < 2 { continue }
      for i in range(pts.len() - 1) {
        let a = pts.at(i)
        let b = pts.at(i + 1)
        place(top + left,
          line(start: a, end: b, stroke: edge-stroke))
      }
      if e.at("arrow", default: true) {
        let end-pt = pts.last()
        let prev-pt = pts.at(pts.len() - 2)
        let dx = end-pt.at(0) - prev-pt.at(0)
        let dy = end-pt.at(1) - prev-pt.at(1)
        let vertical = calc.abs(dy.pt()) >= calc.abs(dx.pt())
        let dx-sign = if dx >= 0pt { 1 } else { -1 }
        let dy-sign = if dy >= 0pt { 1 } else { -1 }
        let anchor = if vertical {
          if dy-sign >= 0 {
            (end-pt.at(0) - head-size / 2, end-pt.at(1) - head-size)
          } else {
            (end-pt.at(0) - head-size / 2, end-pt.at(1))
          }
        } else {
          if dx-sign >= 0 {
            (end-pt.at(0) - head-size, end-pt.at(1) - head-size / 2)
          } else {
            (end-pt.at(0), end-pt.at(1) - head-size / 2)
          }
        }
        place(top + left, dx: anchor.at(0), dy: anchor.at(1),
          head-poly(dx-sign, dy-sign, vertical))
      }
    }
  })

  if title != none {
    align(center)[#strong(title)]
    v(0.5em, weak: true)
  }
  body
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
