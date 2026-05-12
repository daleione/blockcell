// ============================================================================
// Records: bordered key-value blocks linked by reference arrows
// ============================================================================
//
// record       A single bordered key-value block — two-column rows
//              (bold key | value) with internal row / column separators.
//              Use standalone for struct-field / DB-row / register layouts,
//              or as the unit cell of `record-graph`.
// record-graph A 2D layout of multiple records linked by dashed reference
//              arrows. Records auto-place by depth column (root in column 0,
//              its children in column 1, …) with vertical stacking inside
//              each column. Each row of a parent record may point to a child
//              record. Useful for object diagrams, JSON visualizations,
//              ER-style link diagrams, and box-and-pointer / heap diagrams.
// ============================================================================

#import "palettes.typ": palettes
#import "internal/metrics.typ": metrics

// Lay out a single record. Returns a dict
//   (content: ..., width: ..., height: ..., row-centers: (... y ...))
// where `row-centers.at(i)` is the vertical center y of row i within the
// record's local frame — used by `record-graph` for arrow landing points.
//
// Factored out of `record` so `record-graph` can reuse the geometry without
// re-measuring downstream of the public API.
#let _layout-record(
  rows,
  fill,
  stroke,
  inner-stroke,
  radius,
  inset,
  value-min: 0pt,
) = {
  let pad-x = inset.at("x").to-absolute()
  let pad-y = inset.at("y").to-absolute()
  let n = rows.len()
  if n == 0 {
    return (content: [], width: 0pt, height: 0pt, row-centers: ())
  }

  let key-bodies = rows.map(r =>
    if r.at("key", default: none) == none { [] }
    else { strong(r.key) }
  )
  let val-bodies = rows.map(r => r.at("value", default: []))

  let key-ms = key-bodies.map(measure)
  let val-ms = val-bodies.map(measure)

  let col-key-w = key-ms.fold(0pt, (a, m) => calc.max(a, m.width)) + 2 * pad-x
  // `value-min` ensures the value column is at least wide enough to hold a
  // marker (e.g. record-graph's outgoing-reference dot) when no row has
  // wider scalar content; otherwise an all-compound record would collapse
  // the column and the dot would land on the column separator.
  let col-val-w = calc.max(
    val-ms.fold(0pt, (a, m) => calc.max(a, m.width)),
    value-min,
  ) + 2 * pad-x
  let row-hs = range(n).map(i =>
    calc.max(key-ms.at(i).height, val-ms.at(i).height) + 2 * pad-y
  )

  let total-w = col-key-w + col-val-w
  let total-h = row-hs.sum()

  let row-tops = ()
  let row-centers = ()
  let cy = 0pt
  for h in row-hs {
    row-tops.push(cy)
    row-centers.push(cy + h / 2)
    cy = cy + h
  }

  let body = box(
    width: total-w, height: total-h,
    fill: fill, stroke: stroke, radius: radius,
    {
      // Internal vertical separator between key and value columns. Drawn
      // before content so cell text sits on top of the line at the column
      // boundary, matching PlantUML's record-style record blocks.
      place(top + left, dx: col-key-w, dy: 0pt,
        line(start: (0pt, 0pt), end: (0pt, total-h), stroke: inner-stroke))
      // Internal horizontal separators between consecutive rows.
      for i in range(1, n) {
        place(top + left, dx: 0pt, dy: row-tops.at(i),
          line(start: (0pt, 0pt), end: (total-w, 0pt), stroke: inner-stroke))
      }
      // Per-cell content.
      for i in range(n) {
        place(top + left, dx: pad-x, dy: row-tops.at(i) + pad-y,
          key-bodies.at(i))
        place(top + left, dx: col-key-w + pad-x, dy: row-tops.at(i) + pad-y,
          val-bodies.at(i))
      }
    },
  )

  (
    content: body,
    width: total-w,
    height: total-h,
    row-centers: row-centers,
  )
}

/// A single bordered key-value record block with internal row / column
/// separators. Standalone for struct-field / DB-row / register layouts; also
/// the unit cell of `record-graph`.
///
/// ```typst
/// #record(rows: (
///   (key: [name], value: [Alice]),
///   (key: [age],  value: [30]),
/// ))
/// ```
///
/// - `rows`: array of `(key: content, value: content)` dicts. `key` is
///   rendered bold; pass `key: none` for an unlabeled value-only row.
/// - `fill` / `stroke` / `radius`: outer box visuals.
/// - `inner-stroke`: stroke of the internal row / column separators.
/// - `inset`: padding inside each cell as `(x:, y:)`.
#let record(
  rows,
  fill: rgb("#F1F1F1"),
  stroke: 1.5pt + black,
  inner-stroke: 0.6pt + black,
  radius: 5pt,
  inset: (x: 0.5em, y: 0.25em),
) = context {
  _layout-record(rows, fill, stroke, inner-stroke, radius, inset).content
}

// Recursively flatten a record-graph tree into a depth-first pre-order list.
// Returns `(nodes, next-id)` where each node is
//   (id:, depth:, parent:, parent-row:, rows:).
// Pre-order guarantees a parent is positioned before its children in a
// single forward pass, so children can land relative to the parent's row.
#let _flatten-rec(node, depth, parent, parent-row, next-id) = {
  let id = next-id
  let mine = (
    id: id,
    depth: depth,
    parent: parent,
    parent-row: parent-row,
    rows: node.at("rows", default: ()),
  )
  let nodes = (mine,)
  let cursor = id + 1
  for ch in node.at("children", default: ()) {
    let (sub-nodes, sub-cursor) = _flatten-rec(
      ch.node, depth + 1, id, ch.row, cursor,
    )
    nodes = nodes + sub-nodes
    cursor = sub-cursor
  }
  (nodes, cursor)
}

// Draw a filled origin dot at `at` (a `(x, y)` tuple).
#let _draw-arrow-dot(at, color, radius) = {
  let cx = at.at(0)
  let cy = at.at(1)
  place(top + left, dx: cx - radius, dy: cy - radius,
    box(width: 2 * radius, height: 2 * radius,
      fill: color, stroke: none, radius: 50%))
}

// Draw a dashed reference line from `start` to `end` with a filled triangle
// arrowhead at `end`. The origin dot is drawn separately by `_draw-arrow-dot`
// so a row with multiple outgoing arrows shows just one dot, matching
// PlantUML's record-graph z-order.
#let _draw-arrow-line(start, end, color, thickness, head-size) = {
  let sx = start.at(0)
  let sy = start.at(1)
  let ex = end.at(0)
  let ey = end.at(1)
  let dx = (ex - sx).to-absolute()
  let dy = (ey - sy).to-absolute()
  // Convert to unitless ratios for sqrt; Typst doesn't define length·length.
  let dxn = dx / 1pt
  let dyn = dy / 1pt
  let lenn = calc.sqrt(dxn * dxn + dyn * dyn)
  if lenn == 0 { return }
  let len = lenn * 1pt
  let ux = dx / len
  let uy = dy / len
  // Perpendicular (rotated 90° CCW in screen coords).
  let px = -uy
  let py = ux
  // Pull the dashed segment short of the tip so the head sits flush.
  let bx = ex - ux * head-size
  let by = ey - uy * head-size
  // Dashed body.
  place(top + left, line(
    start: (sx, sy), end: (bx, by),
    stroke: (paint: color, thickness: thickness, dash: "dashed"),
  ))
  // Arrowhead — a filled triangle whose tip is at `end`.
  let half = head-size * 0.4
  place(top + left, polygon(
    fill: color, stroke: none,
    (ex, ey),
    (bx + px * half, by + py * half),
    (bx - px * half, by - py * half),
  ))
}

/// A 2D layout of records linked by dashed reference arrows. Each row of
/// each record may point to another record; records auto-place by depth
/// column (root → column 0, its children → column 1, …) with vertical
/// stacking inside each column. A child's preferred y is the parent row's
/// vertical center, bumped down to avoid overlap with already-placed
/// siblings — so first children sit next to their referencing row.
///
/// `root` is a recursive dict:
///
/// ```typst
/// #record-graph(title: [Order], root: (
///   rows: (
///     (key: [id],    value: [42]),
///     (key: [items], value: []),    // outgoing reference
///   ),
///   children: (
///     (row: 1, node: (rows: ((key: [sku], value: [A]),))),
///     (row: 1, node: (rows: ((key: [sku], value: [B]),))),
///   ),
/// ))
/// ```
///
/// - `title`: bold title above the diagram.
/// - `root`: recursive node — `(rows: ..., children: ((row: int, node: ...)))`.
///   `row` is the 0-based index of the parent row the reference originates
///   from. Multiple children may share the same `row` (one parent row → many
///   targets, e.g. an array of records).
/// - `fill` / `stroke` / `inner-stroke` / `radius` / `inset`: forwarded to
///   each underlying `record(...)` for consistent block styling.
/// - `x-gap` / `y-gap`: spacing between depth columns and stacked siblings.
/// - `arrow-color` / `arrow-thickness` / `arrow-head` / `arrow-dot`: arrow
///   styling knobs.
#let record-graph(
  title: none,
  root,
  fill: rgb("#F1F1F1"),
  stroke: 1.5pt + black,
  inner-stroke: 0.6pt + black,
  radius: 5pt,
  inset: (x: 0.5em, y: 0.25em),
  x-gap: 2.4em,
  y-gap: 0.6em,
  arrow-color: black,
  arrow-thickness: 1pt,
  arrow-head: 6pt,
  arrow-dot: 3pt,
) = context {
  let x-gap = x-gap.to-absolute()
  let y-gap = y-gap.to-absolute()
  let arrow-head = arrow-head.to-absolute()
  let arrow-dot = arrow-dot.to-absolute()

  let (nodes, _) = _flatten-rec(root, 0, none, none, 0)

  // Per-parent set of row indices that have at least one outgoing
  // reference. Used both to reserve value-column width (so the dot doesn't
  // land on the column separator when all rows are compound) and to draw
  // exactly one origin dot per anchor row.
  let anchor-rows = range(nodes.len()).map(_ => ())
  for c in nodes {
    if c.parent == none { continue }
    let cur = anchor-rows.at(c.parent)
    if cur.find(r => r == c.parent-row) == none {
      cur.push(c.parent-row)
      anchor-rows.at(c.parent) = cur
    }
  }

  let metas = range(nodes.len()).map(i => {
    let v-min = if anchor-rows.at(i).len() > 0 { 4 * arrow-dot } else { 0pt }
    _layout-record(
      nodes.at(i).rows, fill, stroke, inner-stroke, radius, inset,
      value-min: v-min,
    )
  })

  let pad-x = inset.at("x").to-absolute()

  // Column = depth. Width per column = max record width in that column.
  let max-depth = nodes.fold(0, (a, n) => calc.max(a, n.depth))
  let n-cols = max-depth + 1
  let col-w = range(n-cols).map(_ => 0pt)
  for i in range(nodes.len()) {
    let d = nodes.at(i).depth
    col-w.at(d) = calc.max(col-w.at(d), metas.at(i).width)
  }
  let col-x = ()
  let cx = 0pt
  for w in col-w {
    col-x.push(cx)
    cx = cx + w + x-gap
  }

  // Place each node. Preferred y = parent's row-center y minus half the
  // child height (centers the row line on the child's middle). The column's
  // running cursor floors that to avoid overlap with already-placed siblings,
  // so reference arrows rarely cross.
  let col-cursor = range(n-cols).map(_ => 0pt)
  let pos = ()
  for i in range(nodes.len()) {
    let n = nodes.at(i)
    let m = metas.at(i)
    let x = col-x.at(n.depth)
    let preferred-y = if n.parent == none {
      0pt
    } else {
      let p-pos = pos.at(n.parent)
      let p-meta = metas.at(n.parent)
      let row-y = p-pos.y + p-meta.row-centers.at(n.parent-row)
      row-y - m.height / 2
    }
    let y = calc.max(preferred-y, col-cursor.at(n.depth))
    pos.push((x: x, y: y))
    col-cursor.at(n.depth) = y + m.height + y-gap
  }

  let canvas-w = if n-cols == 0 { 0pt } else {
    col-x.at(n-cols - 1) + col-w.at(n-cols - 1)
  }
  let canvas-h = col-cursor.fold(0pt, (a, c) => calc.max(a, c)) - y-gap
  if canvas-h < 0pt { canvas-h = 0pt }

  // Origin dot lands inside the value cell, just left of the cell's inner
  // padding edge (PlantUML's record-graph style). The dashed line and
  // arrowhead start from the same point.
  let anchor-x(parent-id) = (
    pos.at(parent-id).x + metas.at(parent-id).width - pad-x - arrow-dot
  )

  let body = block(width: canvas-w, height: canvas-h, breakable: false, {
    // Records first, then dots, then arrows. Drawing dots before lines
    // keeps the dashed segment cleanly against the dot's edge, and putting
    // both above the records ensures nothing gets clipped by cell fills.
    for i in range(nodes.len()) {
      place(top + left, dx: pos.at(i).x, dy: pos.at(i).y, metas.at(i).content)
    }
    for i in range(nodes.len()) {
      for r in anchor-rows.at(i) {
        let row-y = pos.at(i).y + metas.at(i).row-centers.at(r)
        _draw-arrow-dot((anchor-x(i), row-y), arrow-color, arrow-dot)
      }
    }
    for i in range(nodes.len()) {
      let n = nodes.at(i)
      if n.parent == none { continue }
      let row-y = (
        pos.at(n.parent).y + metas.at(n.parent).row-centers.at(n.parent-row)
      )
      let start = (anchor-x(n.parent), row-y)
      let c-pos = pos.at(i)
      let c-meta = metas.at(i)
      let end = (c-pos.x, c-pos.y + c-meta.height / 2)
      _draw-arrow-line(start, end, arrow-color, arrow-thickness, arrow-head)
    }
  })

  if title != none {
    align(center)[#strong(title)]
    v(0.5em, weak: true)
  }
  body
}

// ---------------------------------------------------------------------------
// record-layout
// ---------------------------------------------------------------------------
//
// Painter for diagrams whose layout was computed externally — currently used
// by TypstUML's JSON / YAML codegen, which runs a Sugiyama-style layout
// pipeline (Brandes-Kopf x-coords, mincross, edge straighten) on the Rust
// side and emits absolute record positions plus per-edge cubic bezier
// control points. This function does no layout work; it just paints what
// it's given.
//
// The companion `record-graph` above stays for callers that want to hand
// over a topology and let blockcell place things.

// Draw a multi-segment cubic Bezier path through `segments`, from `start`
// to `end`. Each segment is `(c1: ..., c2: ..., end: ...)`; the first
// segment's start is the resolved source anchor, every subsequent segment
// starts where the previous segment ended, and the last segment's end is
// snapped to the resolved target anchor (overriding the value Rust
// emitted, which is approximate).
//
// Boundary control handles are adjusted against the resolved anchors.
// The first c1 keeps the historical horizontal launch from the origin
// dot; the last c2 is translated by the difference between Rust's
// approximate target endpoint and Typst's measured target endpoint. That
// preserves the final path tangent after endpoint snapping, so the
// arrowhead follows the incoming dashed curve instead of being forced
// horizontal.
//
// Arrowhead is a filled triangle whose tip sits at `end`, oriented along
// the tangent at the end (= end - adjusted last_segment.c2).
#let _draw-bezier-path(
  start, segments, end,
  color, thickness, dashed, head-size,
) = {
  let n = segments.len()
  if n == 0 { return }

  // Build the curve as a single multi-segment path so the stroke is
  // continuous across waypoints.
  let cmds = (curve.move(start),)
  for i in range(n) {
    let seg = segments.at(i)
    let seg-end = if i == n - 1 { end } else { seg.end }
    let seg-c1 = if i == 0 { (seg.c1.at(0), start.at(1)) } else { seg.c1 }
    let seg-c2 = if i == n - 1 {
      (
        seg.c2.at(0) + end.at(0) - seg.end.at(0),
        seg.c2.at(1) + end.at(1) - seg.end.at(1),
      )
    } else { seg.c2 }
    cmds.push(curve.cubic(seg-c1, seg-c2, seg-end))
  }
  place(top + left, curve(
    ..cmds,
    stroke: (
      paint: color,
      thickness: thickness,
      dash: if dashed { "dashed" } else { none },
    ),
  ))

  // Arrowhead at `end`. Tangent direction = end - adjusted last c2.
  let last = segments.at(n - 1)
  let last-c2 = (
    last.c2.at(0) + end.at(0) - last.end.at(0),
    last.c2.at(1) + end.at(1) - last.end.at(1),
  )
  let tx = (end.at(0) - last-c2.at(0)).to-absolute()
  let ty = (end.at(1) - last-c2.at(1)).to-absolute()
  let txn = tx / 1pt
  let tyn = ty / 1pt
  let lenn = calc.sqrt(txn * txn + tyn * tyn)
  if lenn == 0 { return }
  let len = lenn * 1pt
  let ux = tx / len
  let uy = ty / len
  let px = -uy
  let py = ux
  let bx = end.at(0) - ux * head-size
  let by = end.at(1) - uy * head-size
  let half = head-size * 0.4
  place(top + left, polygon(
    fill: color, stroke: none,
    end,
    (bx + px * half, by + py * half),
    (bx - px * half, by - py * half),
  ))
}

/// Painter for record-graph diagrams whose record positions and edge
/// bezier paths are already computed (e.g. by TypstUML's record-graph
/// codegen). Companion to `record-graph`, which does its own layout.
///
/// ```typst
/// #record-layout(
///   title: [Order],
///   records: (
///     (x: 0pt, y: 100pt, rows: ((key: [id], value: [42]),)),
///     (x: 200pt, y: 0pt, rows: ((key: [sku], value: [A]),)),
///   ),
///   edges: (
///     (from: 0, from-row: 0, to: 1, c1: (140pt, 110pt), c2: (160pt, 30pt)),
///   ),
/// )
/// ```
///
/// - `title`: bold title above the diagram.
/// - `records`: array of `(x, y, rows)`. `(x, y)` is the top-left of the
///   record's bounding box; `rows` is the same shape as `record(...)`'s
///   `rows` parameter.
/// - `edges`: array of `(from, from-row, to, path)` where `path` is a
///   non-empty sequence of `(c1, c2, end)` cubic-bezier segments. The
///   first segment's start is snapped to the row's right-edge dot anchor
///   in the parent's actual rendered geometry; each subsequent segment
///   starts where the previous one ended; the last segment's end is
///   snapped to the child's left-edge center — Rust's `end` value for
///   the last segment is therefore approximate and overridden here. A
///   single-segment `path` (the common case) gives a plain cubic; multi-
///   segment paths come from obstacle-aware routing.
/// - `fill` / `stroke` / `inner-stroke` / `radius` / `inset`: forwarded
///   to each underlying `record(...)`.
/// - `arrow-color` / `arrow-thickness` / `arrow-head` / `arrow-dot`:
///   styling knobs for edges.
// Measure protocol: report the natural width / height / row centers of
// a single record as `_layout-record` would compute them, without
// drawing anything. The `row_centers` array drops out into the metadata
// dict so TypstUML's Rust codegen can anchor edges at exact row centres
// instead of inferring them from a heuristic estimator. `value_min`
// matches the `value-min` knob `record-layout` passes — keep them in
// sync so the probe and the layout see the same column-width floor.
#let record-probe(
  id: none,
  rows: (),
  fill: rgb("#F1F1F1"),
  stroke: 1.5pt + black,
  inner-stroke: 0.6pt + black,
  radius: 5pt,
  inset: (x: 0.5em, y: 0.25em),
  value-min: 12pt,
) = context {
  let g = _layout-record(rows, fill, stroke, inner-stroke, radius, inset,
                         value-min: value-min)
  let centers = g.row-centers.map(c => c.pt())
  [#metadata((
    id: id,
    w: g.width.pt(),
    h: g.height.pt(),
    row_centers: centers,
  )) <typstuml_measure>]
}

#let record-layout(
  title: none,
  records: (),
  edges: (),
  fill: rgb("#F1F1F1"),
  stroke: 1.5pt + black,
  inner-stroke: 0.6pt + black,
  radius: 5pt,
  inset: (x: 0.5em, y: 0.25em),
  arrow-color: black,
  arrow-thickness: 1pt,
  arrow-head: 6pt,
  arrow-dot: 3pt,
) = context {
  let arrow-head = arrow-head.to-absolute()
  let arrow-dot = arrow-dot.to-absolute()
  let pad-x = inset.at("x").to-absolute()

  // Lay out each record up front: gives us its actual rendered width,
  // height, and per-row vertical centers — used to snap edge endpoints
  // to the real record geometry (layout-rs's char-width estimate
  // diverges from Typst's text shaping).
  let metas = records.map(r =>
    _layout-record(
      r.rows, fill, stroke, inner-stroke, radius, inset,
      value-min: 4 * arrow-dot,
    )
  )

  // Resolve an edge's start point: just inside the right edge of the
  // source row's value cell, at that row's vertical center — same place
  // a dot would sit.
  let resolve-start(edge) = {
    let r = records.at(edge.from)
    let m = metas.at(edge.from)
    let y = r.y + m.row-centers.at(edge.from-row)
    let x = r.x + m.width - pad-x - arrow-dot
    (x, y)
  }

  // Resolve an edge's end point: left edge of the target record at its
  // vertical center.
  let resolve-end(edge) = {
    let r = records.at(edge.to)
    let m = metas.at(edge.to)
    (r.x, r.y + m.height / 2)
  }

  // Canvas size = farthest right / bottom across records and bezier
  // control points (which may extend beyond their endpoints).
  let canvas-w = 0pt
  let canvas-h = 0pt
  for i in range(records.len()) {
    let r = records.at(i)
    let m = metas.at(i)
    canvas-w = calc.max(canvas-w, r.x + m.width)
    canvas-h = calc.max(canvas-h, r.y + m.height)
  }
  for e in edges {
    let s = resolve-start(e)
    let t = resolve-end(e)
    canvas-w = calc.max(canvas-w, calc.max(s.at(0), t.at(0)))
    canvas-h = calc.max(canvas-h, calc.max(s.at(1), t.at(1)))
    for seg in e.path {
      for p in (seg.c1, seg.c2, seg.end) {
        canvas-w = calc.max(canvas-w, p.at(0))
        canvas-h = calc.max(canvas-h, p.at(1))
      }
    }
  }

  let body = block(width: canvas-w, height: canvas-h, breakable: false, {
    // Records first, then dots (one per unique source row), then bezier
    // edges with arrowheads.
    for i in range(records.len()) {
      let r = records.at(i)
      place(top + left, dx: r.x, dy: r.y, metas.at(i).content)
    }
    // Dedupe dots per (record, row) — multiple edges out of the same
    // row should share one origin marker, matching PlantUML.
    let seen = ()
    for e in edges {
      let key = (e.from, e.from-row)
      if seen.find(s => s.at(0) == key.at(0) and s.at(1) == key.at(1)) == none {
        seen.push(key)
        _draw-arrow-dot(resolve-start(e), arrow-color, arrow-dot)
      }
    }
    for e in edges {
      _draw-bezier-path(
        resolve-start(e), e.path, resolve-end(e),
        arrow-color, arrow-thickness, true, arrow-head,
      )
    }
  })

  if title != none {
    align(center)[#strong(title)]
    v(0.5em, weak: true)
  }
  body
}
