// ============================================================================
// Tree / hierarchy diagrams
// ============================================================================
//
// node   A tree-flavored node: rect/circle/stadium with pastel blue default,
//        natural-height box (no flow-chart fixed-height uniformity), and a
//        2.8em diameter floor on auto-sized circles so BST / heap siblings
//        come out uniform. Rendered inline rather than via `flow-node`
//        because flow-node's defaults (fixed height, 2pt radius) serve
//        flow-col's visual alignment needs, not tree's per-label fit.
// tree   Renders a hierarchical tree. First positional = root, remaining
//        positionals = children. Every slot is plain content — `node(...)`,
//        a nested `tree(...)`, a `cell`, a `flow-node`, a `process`, even
//        `[raw text]`. Every rendered tree places its root horizontally
//        centered at the top of its own bounding box, so a parent treats
//        nested subtrees as opaque blobs and still connects correctly.
//
// Typical uses: binary search trees, heaps, tries, directory trees, JSON
// hierarchies, organisation charts.
// ============================================================================

#import "palettes.typ": palettes

// Edge style propagation: an outer `tree(...)` with an explicit `edge-style:`
// updates this state before rendering children, so nested `tree(...)` calls
// with `edge-style: auto` inherit it. Defaults to "elbow" — the convention for
// directory / org-chart / JSON-hierarchy diagrams, which is what most users
// reach for. BST / heap diagrams (where straight diagonals read cleaner)
// pass `edge-style: "line"` at the outermost call and inherit from there.
#let _tree-edge-style = state("bc-tree-edge-style", "elbow")

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
/// #node(fill: palettes.pastel.yellow)[dir/]
/// ```
///
/// - `shape`: `"rect"` (default), `"circle"`, or `"stadium"`.
/// - `fill`: defaults to `palettes.pastel.blue`.
/// - `size`: for circle, the diameter; for rect/stadium, the width.
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

/// Render a hierarchical tree with `root` above its `children`.
///
/// ```typst
/// // Canonical form — tree's own `node(...)` constructor
/// #tree(
///   node[root],
///   tree(node[L], node[LL], node[LR]),
///   tree(node[R], node[RL], node[RR]),
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
/// measured bounding box and the "top / bottom center" of that box.
///
/// - `x-gap` / `y-gap`: horizontal spacing between sibling subtrees and the
///   vertical gap between a parent and its children.
/// - `edge-style`: `auto` (default — inherit from an enclosing `tree(...)` if
///   any, otherwise `"elbow"`), `"line"` (straight diagonals — conventional
///   for BST / heap), or `"elbow"` (down / across / down — conventional for
///   directory / org-chart / JSON hierarchy). Setting this on the outermost
///   `tree(...)` propagates to every nested `tree(...)` whose own argument is
///   still `auto`, so one top-level flag gives a consistent whole-diagram
///   style.
/// - `edge-stroke`: stroke spec for the connectors.
#let tree(
  root,
  ..children,
  x-gap: 1.6em,
  y-gap: 2.2em,
  edge-style: auto,
  edge-stroke: 0.8pt + palettes.base.border,
) = context {
  let x-gap = x-gap.to-absolute()
  let y-gap = y-gap.to-absolute()
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
  // can inline `tree(node[x])` as a one-node placeholder.
  if kids.len() == 0 {
    block(width: root-m.width, height: root-m.height, root)
    _tree-edge-style.update(prev-style)
    return
  }

  let kid-metrics = kids.map(measure)

  let total-kid-w = (
    kid-metrics.fold(0pt, (a, m) => a + m.width) + x-gap * (kids.len() - 1)
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

  // Align the root with the "trunk" child: the middle child when odd, or the
  // midpoint of the two middle children when even. This guarantees a perfectly
  // straight vertical line from the root to the trunk, independent of the
  // outer children's widths — a stricter version of the tidy-tree convention
  // that also keeps asymmetric rows (9-char vs 12-char leaves) trunk-aligned.
  let n = kids.len()
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

  let line-stroke = edge-stroke
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
    for i in range(kids.len()) {
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
    for i in range(kids.len()) {
      place(top + left, dx: kid-xs.at(i), dy: kid-y, kids.at(i))
    }
  })

  // Restore so the state doesn't leak into a subsequent unrelated tree. State
  // updates in Typst have document-position semantics, so the restore needs
  // to come AFTER the block expression in the context's code flow.
  rendered
  _tree-edge-style.update(prev-style)
}
