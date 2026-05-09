// ============================================================================
// Tree / hierarchy diagrams
// ============================================================================
//
// node          A tree-flavored node: rect/circle/stadium/underline. Pastel
//               blue default fill, natural-height box, and a 2.8em diameter
//               floor on auto-sized circles so BST / heap siblings line up.
//               Rendered inline rather than via `flow-node` because flow-node
//               defaults (fixed height, 2pt radius) serve flow-col's visual
//               alignment, not tree's per-label fit.
// tree          Renders a hierarchical tree. First positional = root,
//               remaining positionals = children. Every slot is plain content
//               — `node(...)`, a nested `tree(...)`, a `cell`, a `flow-node`,
//               a `process`, even `[raw text]`. Every rendered tree places
//               its root at the cross-axis center of its own bounding box,
//               so a parent treats nested subtrees as opaque blobs and still
//               connects correctly. `direction:` picks the main axis; pass
//               `"right"` or `"left"` for horizontally-growing branches
//               (mind maps), and the default `"down"` for top-down org
//               charts / WBS / BST.
// mindmap       Composes a central root with two arrays of branch subtrees,
//               one stacked vertically on each side. Each branch is itself
//               a `tree(direction: "left"|"right", …)`. Use this when you
//               want the canonical mind-map fan-out instead of a single
//               directional tree.
//
// Typical uses: binary search trees, heaps, tries, directory trees, JSON
// hierarchies, organisation charts, work-breakdown structures, mind maps.
// ============================================================================

#import "palettes.typ": palettes

// Edge style propagation: an outer `tree(...)` with an explicit `edge-style:`
// updates this state before rendering children, so nested `tree(...)` calls
// with `edge-style: auto` inherit it. Defaults to "elbow" — the convention for
// directory / org-chart / JSON-hierarchy diagrams, which is what most users
// reach for. BST / heap diagrams (where straight diagonals read cleaner)
// pass `edge-style: "line"` at the outermost call and inherit from there.
#let _tree-edge-style = state("bc-tree-edge-style", "elbow")

// Direction propagation. Same scheme as edge-style: the outermost explicit
// `direction:` cascades to nested `tree(...)` calls whose own arg is `auto`.
// This is what makes mind-map branches "all grow rightward" without having
// to repeat `direction: "right"` at every nesting level. Default `"down"`
// preserves backward-compatible layout for callers that don't pass it.
#let _tree-direction = state("bc-tree-direction", "down")

/// A tree-flavored node. Returns content, usable standalone (`#node[x]`) or
/// inside a `tree(...)`. Rendered inline rather than via `flow-node` because
/// flow-chart nodes carry flow-specific visual conventions (28pt uniform
/// height, 2pt radius) that hurt tree diagrams — in a tree each node just
/// hugs its own label.
///
/// ```typst
/// #node[root]                              // default rect
/// #node(shape: "circle")[7]                // circle, auto-sized (≥ 28pt)
/// #node(shape: "circle", size: 36pt)[14]   // pin a diameter
/// #node(shape: "stadium")[start]           // pill
/// #node(shape: "underline")[bare]          // text + bottom rule, no fill
/// #node(fill: palettes.pastel.yellow)[dir/]
/// ```
///
/// - `shape`: `"rect"` (default), `"circle"`, `"stadium"`, or `"underline"`.
///   The `"underline"` variant draws only a bottom rule and skips fill —
///   PlantUML's `_` modifier on mind-map / WBS nodes maps here.
/// - `fill`: defaults to `palettes.pastel.blue`. Ignored by `"underline"`.
/// - `size`: for circle, the diameter; for rect/stadium/underline, the width.
///   `auto` fits the body; circles additionally floor at `2.8em` so BST /
///   heap siblings line up without manual sizing.
/// - `stroke` / `radius` / `inset`: standard box knobs, tree-friendly
///   defaults (natural-height box, 3pt radius, compact 0.8em×0.4em inset).
#let node(
  body,
  shape: "rect",
  fill: palettes.pastel.blue,
  stroke: 0.8pt + palettes.base.border,
  radius: 3pt,
  inset: (x: 0.8em, y: 0.4em),
  size: auto,
) = {
  if shape == "circle" {
    let render(d) = box(
      width: d, height: d, fill: fill, stroke: stroke,
      radius: 50%, inset: 0.6em, baseline: 40%,
      align(center + horizon, body),
    )
    if size == auto {
      context {
        let em = 1em.to-absolute()
        let m = measure(body)
        // 2.8em floor so single-/double-digit BST labels come out uniform.
        render(calc.max(calc.max(m.width, m.height) + 1.4 * em, 2.8 * em))
      }
    } else {
      render(size)
    }
  } else if shape == "underline" {
    let w = if size == auto { auto } else { size }
    box(
      width: w, fill: none, stroke: (bottom: stroke), radius: 0pt,
      inset: inset, baseline: 40%,
      align(center + horizon, body),
    )
  } else {
    let r = if shape == "stadium" { 999pt } else { radius }
    let w = if size == auto { auto } else { size }
    box(
      width: w, fill: fill, stroke: stroke,
      radius: r, inset: inset, baseline: 40%,
      align(center + horizon, body),
    )
  }
}

/// Render a hierarchical tree with `root` connected to its `children`.
///
/// ```typst
/// // Canonical top-down form (default)
/// #tree(
///   node[root],
///   tree(node[L], node[LL], node[LR]),
///   tree(node[R], node[RL], node[RR]),
/// )
///
/// // Right-growing branch (one half of a mind map)
/// #tree(direction: "right",
///   node[A],
///   node[A1],
///   tree(node[A2], node[A2a]),   // inherits "right"
/// )
///
/// // Reuse atoms — `cell`, `process`, `flow-node`, etc. drop in directly
/// #tree(
///   process[支付回调],
///   cell[业务处理],
///   cell(fill: palettes.pastel.red)[退款],
/// )
/// ```
///
/// Every slot (root and each child) is plain content. Mix freely: a BST
/// `node(shape: "circle")` next to a `process` next to a nested `tree(...)`
/// all compose correctly because `tree` only cares about each slot's
/// measured bounding box and the cross-axis center of that box.
///
/// - `direction`: `auto` (default — inherit from the enclosing `tree(...)`,
///   `"down"` at the outermost level), `"down"`, `"right"`, `"left"`.
///   Pick the main axis; the cross axis is the perpendicular one. The
///   resolved direction propagates to nested `tree(...)` calls whose own
///   `direction:` is still `auto`.
/// - `x-gap` / `y-gap`: physical horizontal / vertical gap between adjacent
///   placed elements. Their roles swap with `direction`: in `"down"`,
///   `x-gap` separates siblings (cross axis) and `y-gap` separates the root
///   from its children (main axis); in `"right"` / `"left"`, `y-gap`
///   separates siblings and `x-gap` separates the root from its children.
/// - `edge-style`: `auto` (default — inherit from an enclosing `tree(...)` if
///   any, otherwise `"elbow"`), `"line"` (straight diagonals), or `"elbow"`
///   (down / across / down — conventional for directory / org-chart / JSON
///   hierarchy). Setting this on the outermost `tree(...)` propagates to
///   every nested `tree(...)` whose own argument is still `auto`.
/// - `edge-stroke`: stroke spec for the connectors.
#let tree(
  root,
  ..children,
  x-gap: 1.6em,
  y-gap: 2.2em,
  direction: auto,
  edge-style: auto,
  edge-stroke: 0.8pt + palettes.base.border,
) = context {
  let x-gap = x-gap.to-absolute()
  let y-gap = y-gap.to-absolute()

  // Resolve direction first; nested children read this state.
  let prev-direction = _tree-direction.get()
  let direction = if direction != auto { direction } else { prev-direction }
  _tree-direction.update(direction)

  // Resolve edge style: explicit arg wins; otherwise inherit from an enclosing
  // tree (or the initial "elbow" default at the top level). Push the resolved
  // value into state before we render nested tree content so descendants pick
  // it up via their own `auto`.
  let prev-style = _tree-edge-style.get()
  let edge-style = if edge-style != auto { edge-style } else { prev-style }
  _tree-edge-style.update(edge-style)
  let kids = children.pos()

  let root-m = measure(root)

  // No children → render the root alone. Still wrap in a block so callers
  // can inline `tree(node[x])` as a one-node placeholder. Direction does
  // not affect a single-node render.
  if kids.len() == 0 {
    block(width: root-m.width, height: root-m.height, root)
    _tree-edge-style.update(prev-style)
    _tree-direction.update(prev-direction)
    return
  }

  let kid-metrics = kids.map(measure)
  let n = kids.len()
  let line-stroke = edge-stroke

  if direction == "down" {
    // -------------------------------------------------------------------
    // Default top-down layout. Kept structurally untouched from the
    // pre-direction implementation so existing diagrams stay bit-exact.
    // -------------------------------------------------------------------
    let total-kid-w = (
      kid-metrics.fold(0pt, (a, m) => a + m.width) + x-gap * (n - 1)
    )

    // Each child occupies [x-cursor, x-cursor + width]; record the x-cursor so
    // we can later pick the child that the root's trunk should align with.
    let provisional-xs = ()
    let px = 0pt
    for m in kid-metrics {
      provisional-xs.push(px)
      px = px + m.width + x-gap
    }
    let kid-cx-at(i) = provisional-xs.at(i) + kid-metrics.at(i).width / 2

    // Align the root with the "trunk" child: middle child when odd, midpoint
    // of the two middle children when even. Guarantees a perfectly straight
    // vertical line from the root to the trunk regardless of outer-child
    // width asymmetry — a stricter version of the tidy-tree convention.
    let desired-root-cx = if calc.rem(n, 2) == 1 {
      kid-cx-at(calc.quo(n - 1, 2))
    } else {
      let right = calc.quo(n, 2)
      (kid-cx-at(right - 1) + kid-cx-at(right)) / 2
    }
    let desired-root-x = desired-root-cx - root-m.width / 2

    // Pad the blob symmetrically around the root's center. Guarantees that
    // every rendered (sub)tree has its root at the horizontal center of its
    // bounding box — so when this blob becomes a child of a larger tree, the
    // parent's connector landing at the blob's top-center automatically lands
    // on this subtree's root as well, even if the subtree itself is lopsided.
    let bbox-left = calc.min(0pt, desired-root-x)
    let bbox-right = calc.max(total-kid-w, desired-root-x + root-m.width)
    let half-w = calc.max(desired-root-cx - bbox-left, bbox-right - desired-root-cx)
    let shift = half-w - desired-root-cx
    let canvas-w = 2 * half-w
    let root-x = desired-root-x + shift
    let kids-start-x = shift

    let kid-y = root-m.height + y-gap
    let max-kid-h = kid-metrics.fold(0pt, (a, m) => calc.max(a, m.height))
    let canvas-h = kid-y + max-kid-h

    let root-cx = root-x + root-m.width / 2
    let root-by = root-m.height
    let mid-y = root-by + y-gap / 2

    // Precompute each child's left-x; avoids joining lengths with content when
    // a mutable cursor is threaded through a Typst content block.
    let kid-xs = ()
    let acc = kids-start-x
    for m in kid-metrics {
      kid-xs.push(acc)
      acc = acc + m.width + x-gap
    }

    let rendered = block(width: canvas-w, height: canvas-h, breakable: false, {
      // Connectors first so node fills mask the endpoints cleanly.
      for i in range(n) {
        let m = kid-metrics.at(i)
        let child-cx = kid-xs.at(i) + m.width / 2
        if edge-style == "elbow" {
          // Canonical orthogonal route: down from the root, across to the
          // child's column on the shared bus, down to the child top. A child
          // whose column coincides with the root collapses the bus to zero
          // width and renders as a single clean vertical line.
          let bus-l = if root-cx < child-cx { root-cx } else { child-cx }
          let bus-r = if root-cx < child-cx { child-cx } else { root-cx }
          place(top + left, line(
            start: (root-cx, root-by), end: (root-cx, mid-y),
            stroke: line-stroke))
          place(top + left, line(
            start: (bus-l, mid-y), end: (bus-r, mid-y),
            stroke: line-stroke))
          place(top + left, line(
            start: (child-cx, mid-y), end: (child-cx, kid-y),
            stroke: line-stroke))
        } else {
          place(top + left, line(
            start: (root-cx, root-by), end: (child-cx, kid-y),
            stroke: line-stroke))
        }
      }

      // Root on top of the connectors it emits.
      place(top + left, dx: root-x, dy: 0pt, root)

      // Children — nested trees are opaque blobs whose top-center is their own
      // root's top-center, so connectors land there correctly.
      for i in range(n) {
        place(top + left, dx: kid-xs.at(i), dy: kid-y, kids.at(i))
      }
    })

    rendered
  } else {
    // -------------------------------------------------------------------
    // Horizontal layout for "right" / "left". Mirrors the down path with
    // axes swapped: cross axis is now y (siblings stack vertically), main
    // axis is x (root-to-child progression). `mirror` flips the main axis
    // for "left" so the root sits on the right and children grow leftward.
    // -------------------------------------------------------------------
    let mirror = direction == "left"

    let total-kid-h = (
      kid-metrics.fold(0pt, (a, m) => a + m.height) + y-gap * (n - 1)
    )

    let provisional-ys = ()
    let py = 0pt
    for m in kid-metrics {
      provisional-ys.push(py)
      py = py + m.height + y-gap
    }
    let kid-cy-at(i) = provisional-ys.at(i) + kid-metrics.at(i).height / 2

    let desired-root-cy = if calc.rem(n, 2) == 1 {
      kid-cy-at(calc.quo(n - 1, 2))
    } else {
      let right = calc.quo(n, 2)
      (kid-cy-at(right - 1) + kid-cy-at(right)) / 2
    }
    let desired-root-y = desired-root-cy - root-m.height / 2

    let bbox-top = calc.min(0pt, desired-root-y)
    let bbox-bottom = calc.max(total-kid-h, desired-root-y + root-m.height)
    let half-h = calc.max(desired-root-cy - bbox-top, bbox-bottom - desired-root-cy)
    let shift = half-h - desired-root-cy
    let canvas-h = 2 * half-h
    let root-y = desired-root-y + shift
    let kids-start-y = shift

    let max-kid-w = kid-metrics.fold(0pt, (a, m) => calc.max(a, m.width))
    let canvas-w = root-m.width + x-gap + max-kid-w

    // Place root and the kid column. For "left" the root hugs the right
    // edge and kids the left; for "right" it's the inverse.
    let root-x = if mirror { canvas-w - root-m.width } else { 0pt }
    let kid-x = if mirror { 0pt } else { root-m.width + x-gap }

    let root-cy = root-y + root-m.height / 2
    // The "out" edge of root and the "in" edge of each child face the
    // perpendicular bus. mid-x is exactly halfway between them.
    let root-out-x = if mirror { root-x } else { root-x + root-m.width }
    let mid-x = if mirror { root-out-x - x-gap / 2 } else { root-out-x + x-gap / 2 }

    let kid-ys = ()
    let acc = kids-start-y
    for m in kid-metrics {
      kid-ys.push(acc)
      acc = acc + m.height + y-gap
    }

    let rendered = block(width: canvas-w, height: canvas-h, breakable: false, {
      for i in range(n) {
        let m = kid-metrics.at(i)
        let child-cy = kid-ys.at(i) + m.height / 2
        let child-in-x = if mirror { kid-x + m.width } else { kid-x }
        if edge-style == "elbow" {
          let bus-top = if root-cy < child-cy { root-cy } else { child-cy }
          let bus-bot = if root-cy < child-cy { child-cy } else { root-cy }
          place(top + left, line(
            start: (root-out-x, root-cy), end: (mid-x, root-cy),
            stroke: line-stroke))
          place(top + left, line(
            start: (mid-x, bus-top), end: (mid-x, bus-bot),
            stroke: line-stroke))
          place(top + left, line(
            start: (mid-x, child-cy), end: (child-in-x, child-cy),
            stroke: line-stroke))
        } else {
          place(top + left, line(
            start: (root-out-x, root-cy), end: (child-in-x, child-cy),
            stroke: line-stroke))
        }
      }

      place(top + left, dx: root-x, dy: root-y, root)

      for i in range(n) {
        place(top + left, dx: kid-x, dy: kid-ys.at(i), kids.at(i))
      }
    })

    rendered
  }

  // Restore so state doesn't leak into a subsequent unrelated tree. State
  // updates in Typst have document-position semantics, so the restore needs
  // to come AFTER the rendered block in the context's code flow.
  _tree-edge-style.update(prev-style)
  _tree-direction.update(prev-direction)
}

/// Compose a central root with two arrays of branch subtrees, one stacked
/// vertically on each side. This is the canonical mind-map shape: pass
/// arrays of left- and right-growing `tree(...)` blobs (or bare `node[…]`
/// leaves) and the root sits in the middle, vertically centered against
/// the taller column.
///
/// ```typst
/// #mindmap(
///   node[OS],
///   lefts: (
///     tree(direction: "left", node[Long term],
///       node[Vision], node[Roadmap]),
///   ),
///   rights: (
///     node[Marketing],
///     tree(direction: "right", node[Engineering],
///       node[Backend], node[Frontend]),
///   ),
/// )
/// ```
///
/// - `lefts` / `rights`: arrays of branch content. Each element should be
///   either a leaf `node[…]` or a `tree(direction: "left"|"right", …)` so
///   its anchor lands on the side facing the central root. (Named in the
///   plural to keep them out of the way of Typst's `left`/`right`
///   alignment values, which the function body uses for `place()`.)
/// - `v-gap`: vertical gap between branches stacked on the same side.
/// - `side-gap`: horizontal gap between the central root and either column.
/// - `edge-style` / `edge-stroke`: forwarded to the central-root → branch
///   connectors. Each branch's own connectors are governed by the
///   `tree(...)` that produced it.
#let mindmap(
  root,
  lefts: (),
  rights: (),
  v-gap: 0.8em,
  side-gap: 1.2em,
  edge-style: auto,
  edge-stroke: 0.8pt + palettes.base.border,
) = context {
  let v-gap = v-gap.to-absolute()
  let side-gap = side-gap.to-absolute()
  let prev-style = _tree-edge-style.get()
  let edge-style = if edge-style != auto { edge-style } else { prev-style }

  let root-m = measure(root)
  let left-metrics = lefts.map(measure)
  let right-metrics = rights.map(measure)

  // A side with no branches gets zero width so the root just sits hard
  // against the side-gap on the opposite column.
  let side-stack-h(metrics) = {
    if metrics.len() == 0 { 0pt } else {
      metrics.fold(0pt, (a, m) => a + m.height) + v-gap * (metrics.len() - 1)
    }
  }
  let left-stack-h = side-stack-h(left-metrics)
  let right-stack-h = side-stack-h(right-metrics)
  let left-max-w = if left-metrics.len() == 0 { 0pt } else {
    left-metrics.fold(0pt, (a, m) => calc.max(a, m.width))
  }
  let right-max-w = if right-metrics.len() == 0 { 0pt } else {
    right-metrics.fold(0pt, (a, m) => calc.max(a, m.width))
  }

  let canvas-h = calc.max(calc.max(left-stack-h, right-stack-h), root-m.height)

  // Each side gets its column stacked + a side-gap of clearance from the
  // root. Empty sides contribute zero so the canvas hugs the populated
  // half.
  let left-col-w = if left-metrics.len() == 0 { 0pt } else { left-max-w + side-gap }
  let right-col-w = if right-metrics.len() == 0 { 0pt } else { right-max-w + side-gap }
  let canvas-w = left-col-w + root-m.width + right-col-w

  let root-x = left-col-w
  let root-y = (canvas-h - root-m.height) / 2
  let root-cy = root-y + root-m.height / 2

  // Anchors on the root's left / right edges.
  let root-left-anchor-x = root-x
  let root-right-anchor-x = root-x + root-m.width

  // Stack starting y's so the column is vertically centered against the
  // canvas (hence against the root's center, since we sized canvas-h to fit).
  let stack-start-y(stack-h) = (canvas-h - stack-h) / 2

  let left-start = stack-start-y(left-stack-h)
  let right-start = stack-start-y(right-stack-h)

  let left-ys = ()
  let acc = left-start
  for m in left-metrics {
    left-ys.push(acc)
    acc = acc + m.height + v-gap
  }
  let right-ys = ()
  let acc-r = right-start
  for m in right-metrics {
    right-ys.push(acc-r)
    acc-r = acc-r + m.height + v-gap
  }

  // Each branch blob built by tree(direction: "left"/"right") puts its
  // root at the cross-axis (vertical) center of the blob. So the branch
  // anchor for the central-root → branch connector is the inner edge of
  // the blob at its vertical center.
  let left-anchor-x = left-max-w
  let right-anchor-x = canvas-w - right-max-w

  block(width: canvas-w, height: canvas-h, breakable: false, {
    // Connectors first so node fills mask the endpoints cleanly.
    let mid-x-left = root-left-anchor-x - side-gap / 2
    let mid-x-right = root-right-anchor-x + side-gap / 2

    for i in range(lefts.len()) {
      let m = left-metrics.at(i)
      let anchor-y = left-ys.at(i) + m.height / 2
      if edge-style == "elbow" {
        let bus-top = if root-cy < anchor-y { root-cy } else { anchor-y }
        let bus-bot = if root-cy < anchor-y { anchor-y } else { root-cy }
        place(top + left, line(
          start: (root-left-anchor-x, root-cy), end: (mid-x-left, root-cy),
          stroke: edge-stroke))
        place(top + left, line(
          start: (mid-x-left, bus-top), end: (mid-x-left, bus-bot),
          stroke: edge-stroke))
        place(top + left, line(
          start: (mid-x-left, anchor-y), end: (left-anchor-x, anchor-y),
          stroke: edge-stroke))
      } else {
        place(top + left, line(
          start: (root-left-anchor-x, root-cy), end: (left-anchor-x, anchor-y),
          stroke: edge-stroke))
      }
    }
    for i in range(rights.len()) {
      let m = right-metrics.at(i)
      let anchor-y = right-ys.at(i) + m.height / 2
      if edge-style == "elbow" {
        let bus-top = if root-cy < anchor-y { root-cy } else { anchor-y }
        let bus-bot = if root-cy < anchor-y { anchor-y } else { root-cy }
        place(top + left, line(
          start: (root-right-anchor-x, root-cy), end: (mid-x-right, root-cy),
          stroke: edge-stroke))
        place(top + left, line(
          start: (mid-x-right, bus-top), end: (mid-x-right, bus-bot),
          stroke: edge-stroke))
        place(top + left, line(
          start: (mid-x-right, anchor-y), end: (right-anchor-x, anchor-y),
          stroke: edge-stroke))
      } else {
        place(top + left, line(
          start: (root-right-anchor-x, root-cy), end: (right-anchor-x, anchor-y),
          stroke: edge-stroke))
      }
    }

    // Root on top of its emitted connectors.
    place(top + left, dx: root-x, dy: root-y, root)

    // Branches. Left blobs (direction "left") put their root at the blob's
    // right edge, so right-align them within the left column to keep every
    // left-branch root on the same x. Right blobs (direction "right") put
    // their root at the left edge, so left-align them within the right
    // column. Mixing branch widths therefore still yields a clean trunk
    // line on each side.
    for i in range(lefts.len()) {
      let m = left-metrics.at(i)
      place(top + left, dx: left-max-w - m.width, dy: left-ys.at(i), lefts.at(i))
    }
    for i in range(rights.len()) {
      place(top + left, dx: canvas-w - right-max-w, dy: right-ys.at(i), rights.at(i))
    }
  })
}
