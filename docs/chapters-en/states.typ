#import "../../lib.typ": *
#import "../style.typ": *

= State transition diagrams <states>

*blockcell* ships a layer of state-machine primitives — `state-chain`. Two modes share the same
renderer:

- *Linear mode*: states without `pos:` lay out automatically left-to-right in declaration order,
  with arrows drawn between adjacent states. Suitable for chained flows (file I/O, connection
  handshakes, order stages, …).
- *2D mode*: as soon as any state carries `pos: (col, row)`, the chain switches to a coordinate
  grid — every edge must be declared explicitly with `jump`, the `bend:` parameter controls
  curvature, and any topology becomes possible (subscription state machines, complex protocol
  state machines, …).

In both modes, `loop` / `jump` reference states by id, so order in source can be anything.

#v(6pt)

#align(center)[
  #region(fill: rgb("#FCE4EC"), width: 100%)[
    #text(weight: "bold")[Components in this chapter]
    #v(2pt)
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[State node],
      text(size: 0.85em)[`state(id)` — auto-sizing circle; `initial` / `accept`
        add color and double border; optional `pos: (col, row)` switches to 2D],
      text(size: 0.85em, weight: "bold")[Chain transitions],
      text(size: 0.85em)[In linear mode, the target node's `edge-label:` annotates
        the auto-drawn adjacent arrow],
      text(size: 0.85em, weight: "bold")[Self-loop],
      text(size: 0.85em)[`loop(id)[label]` — pick any of four directions:
        `above` / `below` / `left` / `right`],
      text(size: 0.85em, weight: "bold")[One-way transition],
      text(size: 0.85em)[`jump(from, to)[label]` — linear mode uses `route:`,
        2D mode uses `bend:` for curvature],
      text(size: 0.85em, weight: "bold")[Bidirectional],
      text(size: 0.85em)[`bi-jump(from, to, forward:, back:)` — one line, arrows
        on both ends, one label per end (2D only)],
      text(size: 0.85em, weight: "bold")[Container],
      text(size: 0.85em)[`state-chain(..items)` accepts all nodes and overlays
        in any order],
    )
  ]
]

== Quick start <states-quick-start>

The classic file-I/O state machine: `reading → eof → closed`. `reading` can self-loop reading
the next chunk, or jump straight to `closed` via `close()`:

#wide-example(
  ```typ
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof",    edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],
    loop("reading")[`read()`],
    jump("reading", "closed", route: "below")[`close()`],
  )
  ```,
  [
    #state-chain(
      state("reading", initial: true)[reading],
      state("eof", edge-label: [`read()`])[eof],
      state("closed", edge-label: [`close()`], accept: true)[closed],
      loop("reading")[`read()`],
      jump("reading", "closed", route: "below")[`close()`],
    )
  ],
)

#v(4pt)

How to read it: states on the chain lay out left-to-right in source order; an automatic
forward arrow is drawn between each adjacent pair, with its label coming from *the next state's*
`edge-label:`. `loop` / `jump` reference states by id, so their position in the `state-chain`
source list doesn't matter.

== Core constructors <states-core>

=== `state` <states-state>

A circular state node. Auto-grows with the body (lower bound 44pt). `initial` / `accept` are
boolean flags corresponding to UML's "initial" and "accepting" states, each with a default
color and visual decoration.

#section-label[Example]

#wide-example(
  ```typ
  #state-chain(
    state("a", initial: true)[a],
    state("b")[b],
    state("c", accept: true)[c],
  )
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      state("c", accept: true)[c],
    )
  ],
)

#section-label[Parameters]

#params-box("state",
  ("id",         ("str",)),
  ("body",       ("content",)),
  ("pos",        ("none", "array")),
  ("initial",    ("bool",)),
  ("accept",     ("bool",)),
  ("edge-label", ("none", "content")),
  ("fill",       ("none", "color")),
  ("size",       ("auto", "length")),
  returns: "content",
)

#param-detail("id", ("str",))[
  String id; used by `loop` / `jump` for cross-referencing (*positional argument*).
]

#param-detail("pos", ("none", "array"), default: raw("none", lang: none))[
  A `(col, row)` 2-tuple (floats supported). As soon as any state carries `pos:`,
  `state-chain` switches to 2D mode.
]

#param-detail("initial", ("bool",), default: raw("false", lang: none))[
  `true` → default green fill + auto-drawn gray entry dot + arrow into this state.
]

#param-detail("accept", ("bool",), default: raw("false", lang: none))[
  `true` → default yellow fill + double border (UML "accepting state"). Can be combined with
  `initial` (initial-and-also-final): the fill takes the green from `initial`, the double border
  comes from `accept`.
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  In linear mode, the label on the auto-drawn arrow *into* this state. Ignored in 2D mode
  (where every edge must be explicit `jump` / `bi-jump`).
]

#section-label[Color convention]

#align(center)[
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.green, stroke: 0.8pt + black)
    #h(4pt) `initial` green
  ]
  #h(10pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.yellow, stroke: 0.8pt + black)
    #h(4pt) `accept` yellow + double border
  ]
  #h(10pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.blue, stroke: 0.8pt + black)
    #h(4pt) regular blue
  ]
]

=== `loop` <states-loop>

Draws a small arc on the named state that returns to itself. All four directions are useful in
2D mode; in linear mode, prefer up / down to avoid colliding with the main-chain arrows.

#section-label[Example]

#wide-example(
  ```typ
  // default: above the state
  #loop("a")[retry]
  #loop("a", route: "below")[retry]
  #loop("a", route: "left", style: "dashed")[retry]
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      loop("a")[retry],
    )
  ],
)

#section-label[Parameters]

#params-box("loop",
  ("id",    ("str",)),
  ("body",  ("content",)),
  ("route", ("str",)),
  ("style", ("str",)),
  returns: "content",
)

#param-detail("route", ("str",), default: raw("\"above\"", lang: none))[
  Arc direction: `"above"` / `"below"` / `"left"` / `"right"`.
]

#param-detail("style", ("str",), default: raw("\"solid\"", lang: none))[
  `"dashed"` draws a dashed arc (for optional / conditional transitions).
]

=== `jump` <states-jump>

Draws a *one-way* edge from `from` to `to`. In linear mode, `route:` selects a large arc above
or below the chain; in 2D mode, `bend:` controls curvature.

#section-label[Example]

#wide-example(
  ```typ
  #jump("a", "c", route: "below")[skip]
  #jump("a", "c", bend: 0.15)[skip]
  #jump("a", "c")   // straight line, no label
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      state("c")[c],
      jump("a", "c", route: "below")[skip],
    )
  ],
)

#section-label[Parameters]

#params-box("jump",
  ("from",       ("str",)),
  ("to",         ("str",)),
  ("body",       ("none", "content")),
  ("route",      ("str",)),
  ("height",     ("auto", "length")),
  ("bend",       ("float",)),
  ("label-pos",  ("ratio", "float")),
  ("label-side", ("int",)),
  ("style",      ("str",)),
  returns: "content",
)

#param-detail("route", ("str",), default: raw("\"above\"", lang: none))[
  *Linear mode only.* `"above"` / `"below"` decide which side the arc takes; the algorithm is
  symmetric for forward (from on the left) and backward (from on the right) writings.
]

#param-detail("height", ("auto", "length"), default: raw("auto", lang: none))[
  *Linear mode only.* Arc peak depth. Defaults to `state-chain.jump-height`; when several jumps
  on the same side nest, give the shorter ones smaller `height:` so they tuck inside the longer arcs.
]

#param-detail("bend", ("float",), default: raw("0.0", lang: none))[
  *2D mode only.* Signed curvature ratio (typical range `0.1`–`0.3`). Positive values bend the
  curve toward the "visual left of the line direction", useful for routing around an intermediate
  state or separating overlapping parallel edges.
]

#param-detail("label-pos", ("ratio", "float"),
  default: raw("0.5", lang: none))[
  Label position along the line (0 = start, 1 = end). Useful for avoidance.
]

#param-detail("label-side", ("int",), default: raw("1", lang: none))[
  `±1`: flip to the other side. The default `+perp` points to the "visual left of the line direction";
  if that happens to point at a neighboring state, set `-1` so the label moves to the opposite side.
]

#section-label[Notes]

For a bidirectional transition (A ↔ B) use *`bi-jump`* rather than two opposite `jump`s — the
latter renders as two parallel arrows, while the former draws a single line with an arrow on
each end, which matches state-diagram convention.

=== `bi-jump` <states-bi-jump>

Draws a single line with arrows on both ends and one label at each end. *2D mode only*.

#section-label[Example]

#wide-example(
  ```typ
  #state-chain(
    col-gap: 90pt,
    row-gap: 90pt,
    state("a", pos: (0, 0))[A],
    state("b", pos: (2, 0))[B],
    bi-jump("a", "b",
      forward: [a→b label],
      back:    [b→a label],
      bend: 0,
    ),
  )
  ```
,
  [
    #state-chain(
      col-gap: 90pt,
      row-gap: 90pt,
      state("a", pos: (0, 0))[A],
      state("b", pos: (2, 0))[B],
      bi-jump("a", "b",
        forward: [a→b label],
        back:    [b→a label],
        bend: 0,
      ),
    )
  ],
)

#v(4pt)

If the two labels and nearby edges are too close, push both labels onto the same side:

#wide-example(
  ```typ
  #state-chain(
    col-gap: 95pt,
    row-gap: 95pt,
    state("active", pos: (0, 0))[active],
    state("grace",  pos: (2, 0.8))[grace],
    bi-jump("active", "grace",
      forward: [enter grace],
      back:    [resume],
      back-side: 1,
    ),
  )
  ```
,
  [
    #state-chain(
      col-gap: 95pt,
      row-gap: 95pt,
      state("active", pos: (0, 0))[active],
      state("grace",  pos: (2, 0.8))[grace],
      bi-jump("active", "grace",
        forward: [enter grace],
        back:    [resume],
        back-side: 1,
      ),
    )
  ],
)

#section-label[Parameters]

#params-box("bi-jump",
  ("from",         ("str",)),
  ("to",           ("str",)),
  ("forward",      ("none", "content")),
  ("back",         ("none", "content")),
  ("bend",         ("float",)),
  ("forward-side", ("int",)),
  ("back-side",    ("int",)),
  ("style",        ("str",)),
  returns: "content",
)

#param-detail("forward", ("none", "content"),
  default: raw("none", lang: none))[
  Annotates the `from → to` direction; placed near `to`, on the default `+perp` side.
]

#param-detail("back", ("none", "content"), default: raw("none", lang: none))[
  Annotates the `to → from` direction; placed near `from`, on the default `-perp` side.
]

#param-detail("forward-side", ("int",), default: raw("1", lang: none))[
  `±1`. Same sign as `back-side` ⇒ both labels on the same side; opposite signs ⇒ mirrored
  (the default).
]

== Container <states-container>

=== `state-chain` <states-state-chain>

The top-level container that holds all state nodes and transition overlays. Pass any
combination of `state` / `loop` / `jump` / `bi-jump` in any order; internally they're sorted
into rendering layers (edges → states → labels).

#section-label[Parameters]

#params-box("state-chain",
  ("..items",     ("content",)),
  ("gap",         ("length",)),
  ("col-gap",     ("length",)),
  ("row-gap",     ("length",)),
  ("loop-height", ("length",)),
  ("jump-height", ("length",)),
  ("min-size",    ("length",)),
  returns: "content",
)

#param-detail("gap", ("length",), default: raw("60pt", lang: none))[
  *Linear mode* horizontal spacing between adjacent state circles.
]

#param-detail("col-gap", ("length",), default: raw("90pt", lang: none))[
  *2D mode* pixels per unit of `pos.x`.
]

#param-detail("row-gap", ("length",), default: raw("100pt", lang: none))[
  *2D mode* pixels per unit of `pos.y`.
]

#param-detail("loop-height", ("length",), default: raw("28pt", lang: none))[
  Distance from the self-loop's peak to the state's edge.
]

#param-detail("jump-height", ("length",), default: raw("48pt", lang: none))[
  Distance from a linear-mode skip arc's peak to the chain's top/bottom edge.
]

#param-detail("min-size", ("length",), default: raw("44pt", lang: none))[
  Minimum state diameter (lower bound). Actual diameter adapts to the body but won't go below this.
]

== Worked example: TCP connection lifecycle <states-tcp-example>

Combine `state` / `edge-label` / `loop` / `jump` on a single chain. TCP starts at `CLOSED`,
goes through `LISTEN` / `SYN_RECVD` / `ESTABLISHED`, with two `close()` paths returning to
`CLOSED` from LISTEN (early cancellation) and ESTABLISHED (normal close).

#wide-example(
  ```typ
  #state-chain(
    state("closed", size: 56pt, initial: true, accept: true)[CLOSED],
    state("listen", size: 56pt, edge-label: [listen()])[LISTEN],
    state("syn-recvd", size: 56pt, edge-label: [SYN recv])[SYN_RECVD],
    state("established", size: 56pt, edge-label: [ACK])[ESTABLISHED],
    loop("listen")[SYN recv],
    jump("listen", "closed", route: "above", style: "dashed")[close()],
    jump("established", "closed", route: "below", style: "dashed")[close()],
  )
  ```
,
  [
    #state-chain(
      state("closed", size: 56pt, initial: true, accept: true)[CLOSED],
      state("listen", size: 56pt, edge-label: [listen()])[LISTEN],
      state("syn-recvd", size: 56pt, edge-label: [SYN recv])[SYN_RECVD],
      state("established", size: 56pt, edge-label: [ACK])[ESTABLISHED],
      loop("listen")[SYN recv],
      jump("listen", "closed", route: "above", style: "dashed")[close()],
      jump("established", "closed", route: "below", style: "dashed")[close()],
    )
  ],
)

#v(4pt)

Notes:

- `CLOSED` carries both `initial` and `accept` — the initial-state semantics win for the fill
  (green), but the double border (from `accept`) is still drawn.
- The two `close()` edges use `style: "dashed"` to mark "soft close", visually distinct from
  the solid main-chain arrows.
- All states pass `size: 56pt` for a uniform small circle. When `ESTABLISHED` doesn't fit at
  the default font size, `state-chain` shrinks the label proportionally to fit the circle —
  no manual `#text(size: …)` needed. Without `size:`, the chain falls back to "the largest
  natural diameter in the pool", which also yields uniform sizing.
- LISTEN carries both a `loop` (self-loop) and a `listen → closed` jump. They don't collide
  even though both default to "above": `loop` anchors directly above the state (±6pt) while
  `jump` automatically shifts to the *45°* sector facing the target — they occupy different
  arcs around the state.
- One arc is `above` and the other `below`, so the two `close()` long arcs don't stack on one
  side. When several same-side jumps nest, give the shorter ones smaller `height:` (at most
  half the longer arc).

== 2D mode: arbitrary topology <states-2d>

When states aren't in simple linear order — e.g. a subscription/order machine where active
flows around a triangle into billing-retry, grace-period, revoke, expired — give each `state`
a `pos: (col, row)`. Everything else stays the same; `state-chain` switches to 2D automatically.

#wide-example(
  ```typ
  #state-chain(
    col-gap: 95pt, row-gap: 100pt,
    state("active",  pos: (0, 0), initial: true)[active],
    state("billing", pos: (3, 0), fill: palettes.pastel.yellow)[billing retry],
    state("grace",   pos: (1, 0.8), fill: palettes.pastel.green)[grace period],
    state("revoke",  pos: (2, 0.8), fill: palettes.pastel.red)[revoke],
    state("expired", pos: (1.5, 2.3), fill: palettes.pastel.red)[expired],
    loop("active", route: "above")[regular renewal],
    bi-jump("active", "billing",
      forward: [charge fails within 60d],
      back:    [renewal succeeds within 60d]),
    bi-jump("active", "grace",
      forward: [cancel], back: [enable],
      back-side: 1),
    jump("grace", "revoke")[cancel],
    jump("billing", "revoke"),
    jump("grace", "expired")[grace not renewed],
    jump("active", "expired", label-side: -1)[cancel],
    jump("billing", "expired")[cancel or 60d charge fail],
  )
  ```
,
  [
    #state-chain(
      col-gap: 95pt, row-gap: 100pt,

      state("active",  pos: (0, 0), initial: true)[active],
      state("billing", pos: (3, 0), fill: palettes.pastel.yellow)[billing \ retry],
      state("grace",   pos: (1, 0.8), fill: palettes.pastel.green)[grace \ period],
      state("revoke",  pos: (2, 0.8), fill: palettes.pastel.red)[revoke],
      state("expired", pos: (1.5, 2.3), fill: palettes.pastel.red)[expired],

      loop("active", route: "above")[regular renewal],
      bi-jump("active", "billing",
        forward: [charge fails within 60d],
        back: [renewal succeeds within 60d],
      ),
      bi-jump("active", "grace",
        forward: [cancel],
        back: [enable],
        back-side: 1,
      ),
      jump("grace", "revoke")[cancel],
      jump("billing", "revoke"),
      jump("grace", "expired")[grace not renewed],
      jump("active", "expired", label-side: -1)[cancel],
      jump("billing", "expired")[cancel or 60d charge fail],
    )
  ],
)

#v(4pt)

A few points about 2D mode:

- `pos` is a logical grid coordinate (floats are fine); pixel positions come from `col-gap` / `row-gap`.
  The leftmost / topmost state automatically snaps to the canvas edge.
- 2D mode has *no* "auto-arrow between adjacent states" — every edge needs an explicit
  `jump` / `bi-jump`. `edge-label:` on states is ignored.
- *Use `bi-jump` for bidirectional pairs*: one line with arrows on both ends and one label per
  end, rather than two parallel one-way arrows.
- Three layers render in order: *edges → states → labels*, no manual ordering needed. Edges
  passing through unrelated states are masked by the circles; labels on top of circles still
  read on top.
- A one-way `jump`'s straight line passes through intermediate states. To genuinely route around,
  add `bend:` to push it sideways; in most cases try `label-side: -1` first (flip the label to
  the other side), which is cheaper than bending the line.
- `bi-jump` mirrors its two labels by default; if the default side happens to overlap another
  edge, set `back-side` to the same sign as `forward-side` to push both labels to the same side.
- Labels auto-shift vertically by their own width as a minimum; even a `bend = 0` straight line
  doesn't sit on top of its label.

== Limitations <states-limits>

- *No automatic routing / avoidance* — in 2D mode, a long diagonal can cross intermediate states;
  use `bend` to route around manually. Crowded labels can also overlap; same fix — adjust the
  sign / magnitude of `bend`.
- *No composite states* — UML "state with substates" must be modeled by hand using nested
  `region` + `state-chain`.
- *No automatic numbering / transition tables* — generating a documentation index would use
  Typst's `locate` plus custom metadata, which this chapter doesn't cover.

In other words: *layout is your call*. `state-chain` draws circles, bends edges, aligns arrows
to tangents, and keeps labels from overlapping lines — but the values for `pos` and `bend` are
yours to design. Dense topologies are best sketched on paper first, then transcribed.
