#import "../../lib.typ": *
#import "../style.typ": *

= Flowcharts <flows>

*blockcell* ships a complete flowchart toolkit covering linear flows, conditional branches,
N-way dispatch, and loops. This chapter walks bottom-up: *nodes → containers → branches → loops*,
each section paired with directly copyable code and the rendered result.

Scope: *top-down*, structurally-nested flowcharts (business flows, API call chains,
state-style transitions, …). For non-tree 2D topologies (diagonal arrows, cross-layer lines,
free-form DAGs) use `fletcher` / `cetz`.

#v(6pt)

#align(center)[
  #region(fill: rgb("#FFECB3"), width: 100%)[
    #text(weight: "bold")[Components in this chapter]
    #v(2pt)
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[Nodes],
      text(size: 0.85em)[#api-ref("flows-process", "process") / #api-ref("flows-decision", "decision") / #api-ref("flows-terminal", "terminal") / #api-ref("flows-junction", "junction")
        (aliases with default colors) · #api-ref("flows-flow-node", "flow-node") (low-level)],
      text(size: 0.85em, weight: "bold")[Vertical container],
      text(size: 0.85em)[#api-ref("flows-flow-col", "flow-col") auto-inserts down-arrows; on a node, `edge-label:`
        annotates the arrow that points *into it*],
      text(size: 0.85em, weight: "bold")[Branches],
      text(size: 0.85em)[#api-ref("flows-branch", "branch") (no merge) · #api-ref("flows-branch-merge", "branch-merge") (merge) ·
        #api-ref("flows-switch", "switch") + #api-ref("flows-case", "case") `(label, body)` (N-way)],
      text(size: 0.85em, weight: "bold")[Loops],
      text(size: 0.85em)[#api-ref("flows-flow-loop", "flow-loop") with a left-side back edge],
    )
  ]
]

== Nodes <flows-nodes>

=== `flow-node` <flows-flow-node>

The low-level constructor for flowchart nodes. Switch among rectangle / diamond / stadium / circle
via `shape`, or use the four semantic aliases below to skip writing `shape:` and `fill:` by hand.

#section-label[Example]

#example-pair(
  ```typ
  #flow-node(shape: "rect")[A]
  #flow-node(shape: "diamond",
             width: 70pt)[B?]
  #flow-node(shape: "stadium")[C]
  #flow-node(shape: "circle")[D]
  ```,
  [
    #flow-node(shape: "rect")[A]
    #h(4pt)
    #flow-node(shape: "diamond", width: 70pt)[B?]
    #h(4pt)
    #flow-node(shape: "stadium")[C]
    #h(4pt)
    #flow-node(shape: "circle")[D]
  ],
)

#section-label[Parameters]

#params-box("flow-node",
  ("body",       ("content",)),
  ("shape",      ("str",)),
  ("fill",       ("color",)),
  ("stroke",     ("stroke",)),
  ("width",      ("auto", "length")),
  ("height",     ("auto", "length")),
  ("inset",      ("length", "dictionary")),
  ("status",     ("none", "str")),
  ("edge-label", ("none", "content")),
  returns: "content",
)

#param-detail("shape", ("str",), default: raw("\"rect\"", lang: none))[
  `"rect"` / `"diamond"` / `"stadium"` / `"circle"`. A `diamond` widens automatically to fit text;
  pass `width:` explicitly to keep it from getting too wide.
]

#param-detail("status", ("none", "str"), default: raw("none", lang: none))[
  One of the five `palettes.status` keys. Switches to a semantic status color in one shot
  (overrides both `fill` and `stroke`). Typical use: `terminal(status: "danger")` for an error exit.
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  Inside `flow-col`, an `edge-label:` on this node is used by the surrounding container as the label
  on *the arrow that points into it*. It doesn't depend on indices, so inserting/moving nodes won't desync.
]

=== `process` <flows-process>

Rectangular execution step; alias for `flow-node(shape: "rect", fill: palettes.pastel.blue)`.

#section-label[Example]

#example-pair(
  ```typ
  #process[Load config]
  ```,
  [#process[Load config]],
)

#section-label[Parameters]

#params-box("process",
  ("body",    ("content",)),
  ("fill",    ("color",)),
  ("..args",  ("any",)),
  returns: "content",
)

=== `decision` <flows-decision>

Diamond conditional; alias for `flow-node(shape: "diamond", fill: palettes.pastel.yellow)`.
Width adapts to text, but pass `width:` explicitly to avoid an oversize diamond.

#section-label[Example]

#example-pair(
  ```typ
  #decision(width: 90pt)[Config ok?]
  ```,
  [#decision(width: 90pt)[Config ok?]],
)

=== `terminal` <flows-terminal>

Stadium-shaped start/end marker; alias for
`flow-node(shape: "stadium", fill: palettes.pastel.green)`.

#section-label[Example]

#example-pair(
  ```typ
  #terminal[Start]
  #terminal(status: "danger")[Exit]
  ```,
  [
    #terminal[Start]
    #h(4pt)
    #terminal(status: "danger")[Exit]
  ],
)

=== `junction` <flows-junction>

Circular cross-page anchor; alias for
`flow-node(shape: "circle", fill: palettes.pastel.cyan)`. `size:` controls the diameter.

#section-label[Example]

#example-pair(
  ```typ
  #junction[1]   #junction[A]
  ```,
  [
    #junction[1]
    #h(4pt)
    #junction[A]
  ],
)

== Linear container <flows-linear>

=== `flow-col` <flows-flow-col>

Stacks nodes vertically as one pipeline, auto-inserting a down-arrow between adjacent nodes.
To label an arrow, put `edge-label:` on the *target node* — i.e., "annotate the arrow pointing
into me". This style doesn't depend on indices, so inserting/moving nodes won't desync.

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    terminal[Start],
    process[Load config],
    decision[Config valid?],
    process(edge-label: [Yes])[Start server],
    terminal(status: "danger")[Exit],
  )
  ```,
  [
    #flow-col(
      terminal[Start],
      process[Load config],
      decision[Config valid?],
      process(edge-label: [Yes])[Start server],
      terminal(status: "danger")[Exit],
    )
  ],
)

#section-label[Parameters]

#params-box("flow-col",
  ("..nodes",    ("content",)),
  ("edge-style", ("str",)),
  ("gap",        ("length",)),
  returns: "content",
)

#section-label[Notes]

`flow-col` is the *vertical backbone* of a flowchart — all the branch and loop primitives below
(`branch` / `branch-merge` / `switch` / `flow-loop`) are designed to drop straight into a
`flow-col` as "fattened-up segments".

== Conditional branches <flows-branches>

Two if-else shapes, distinguished by whether the No-path returns to the trunk:

#grid(
  columns: (140pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[`branch`], [
    Yes continues down the main path; No splits off to the right — *the two paths don't merge*.
    Suitable for "main flow + exception/early return".
  ],
  text(weight: "bold")[`branch-merge`], [
    Yes / No expand into two parallel columns, then rejoin at a horizontal merge line into
    a single exit — *the two paths reunite*. Suitable for if-else where both arms continue
    in the main flow.
  ],
)

=== `branch` <flows-branch>

Yes continues down, No splits to the right. The two paths don't merge — fits "main flow +
exception / quick return", i.e. "once it leaves, it's gone".

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Load config],
    branch([Config valid?],
      yes: process[Start server],
      no:  process(status: "danger")[Log error + exit],
    ),
    terminal[Ready],
  )
  ```,
  [
    #flow-col(
      process[Load config],
      branch([Config valid?],
        yes: process[Start server],
        no:  process(status: "danger")[Log + exit],
      ),
      terminal[Ready],
    )
  ],
)

#section-label[Parameters]

#params-box("branch",
  ("cond",          ("content",)),
  ("yes",           ("none", "content")),
  ("no",            ("none", "content")),
  ("yes-label",     ("content",)),
  ("no-label",      ("content",)),
  ("diamond-width", ("length",)),
  returns: "content",
)

#param-detail("cond", ("content",))[
  The text inside the diamond (positional argument).
]

#param-detail("yes", ("none", "content"), default: raw("none", lang: none))[
  Yes branch (continues down). With `none`, it stops at the diamond and the surrounding `flow-col`
  picks up afterward.
]

#param-detail("no", ("none", "content"), default: raw("none", lang: none))[
  No branch (splits to the right). With `none`, no alternative branch is rendered.
]

#section-label[Nesting]

`yes` / `no` accept any content. You can nest a `flow-col` or another `branch` to express sub-flows.

=== `branch-merge` <flows-branch-merge>

Yes / No expand into parallel columns, then rejoin via a horizontal merge line into a single
exit — fits if-else where both arms return to the main flow.

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Parse request],
    branch-merge([Cached?],
      yes: process(fill: palettes.pastel.green)[Return cached],
      no:  process(fill: palettes.pastel.orange)[Compute + cache],
    ),
    process[Respond],
  )
  ```,
  [
    #flow-col(
      process[Parse request],
      branch-merge([Cached?],
        yes: process(fill: palettes.pastel.green)[Return cached],
        no:  process(fill: palettes.pastel.orange)[Compute + cache],
      ),
      process[Respond],
    )
  ],
)

#section-label[Parameters]

#params-box("branch-merge",
  ("cond",          ("content",)),
  ("yes",           ("none", "content")),
  ("no",            ("none", "content")),
  ("yes-label",     ("content",)),
  ("no-label",      ("content",)),
  ("merge",         ("bool",)),
  ("diamond-width", ("length",)),
  ("col-gap",       ("length",)),
  returns: "content",
)

#param-detail("merge", ("bool",), default: raw("true", lang: none))[
  `false` removes the bottom merge line, degenerating to two parallel columns
  (semantically equivalent to N=2 `switch(merge: false)`).
]

#param-detail("col-gap", ("length",), default: raw("40pt", lang: none))[
  Horizontal gap between the two columns.
]

== N-way branching <flows-switch-section>

=== `switch` <flows-switch>

The generalization of `branch-merge` — any number of branches dispatch from the diamond and
rejoin at the bottom. Cases are declared via the `case(label, body)` constructor (positional);
`label` annotates the arrow descending from the diamond.

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Receive event],
    switch([event.kind],
      case([order],  process(fill: palettes.pastel.green)[Place order]),
      case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
      case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
    ),
    process[Emit audit log],
  )
  ```,
  [
    #flow-col(
      process[Receive event],
      switch([event.kind],
        case([order],  process(fill: palettes.pastel.green)[Place order]),
        case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
        case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
      ),
      process[Emit audit log],
    )
  ],
)

#section-label[Parameters]

#params-box("switch",
  ("cond",          ("content",)),
  ("..cases",       ("array",)),
  ("merge",         ("bool",)),
  ("diamond-width", ("length",)),
  ("col-gap",       ("length",)),
  returns: "content",
)

#param-detail("..cases", ("array",))[
  Each case is built with `case(label, body)`. Column widths take the maximum of all case bodies
  for symmetry; with an odd number of cases, the middle column lands on the diamond's main axis.
]

#section-label[Defaults]

`diamond-width: 140pt`, `col-gap: 24pt` — tighter than `branch-merge` to accommodate more branches.

=== `case` <flows-case>

Constructor for a `switch` case. Returns an internal dictionary; doesn't render directly —
it must be used inside a `switch`.

#section-label[Example]

```typ
case([order], process[Place order])
// equivalent to (label: [order], body: process[Place order])
```

== Loops <flows-loop>

=== `flow-loop` <flows-flow-loop>

Wraps a stretch of flow as a "loop body", auto-drawing a back edge on the left:
*body bottom center → leftward → upward → rightward, returning with a down-arrow into the
body's top center*.

Typical pairing: the body holds a `flow-col` whose last node is a `branch` — one arm exits
the loop, the other gets pulled back to the top by the back edge.

#section-label[Example]

#wide-example(
  ```typ
  #flow-loop(
    flow-col(
      process[Poll queue],
      process[Handle job],
      branch([More work?],
        yes: process[Continue],
        no:  terminal(status: "danger")[Shutdown],
      ),
    ),
    back-label: [continue],
  )
  ```,
  [
    #flow-loop(
      flow-col(
        process[Poll queue],
        process[Handle job],
        branch([More work?],
          yes: process[Continue],
          no:  terminal(status: "danger")[Shutdown],
        ),
      ),
      back-label: [continue],
    )
  ],
)

#section-label[Parameters]

#params-box("flow-loop",
  ("body",       ("content",)),
  ("back-label", ("none", "content")),
  ("arm",        ("length",)),
  returns: "content",
)

#param-detail("back-label", ("none", "content"),
  default: raw("[retry]", lang: none))[
  Back-edge label. `none` hides the label.
]

#param-detail("arm", ("length",), default: raw("80pt", lang: none))[
  Horizontal distance from the back edge to the body's main column (center). Measured against
  the main column — even if the body has side branches that make it wide, the back edge stays
  close to the main column.
]

== Quick-pick guide <flows-quick-guide>

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (130pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[`flow-col`],
        [Pure linear: Start → A → B → End],
      text(weight: "bold")[`branch`],
        [Main line + one side exit that doesn't return (exception / quick return / abort)],
      text(weight: "bold")[`branch-merge`],
        [Yes/No are both part of the main flow; both rejoin at one exit],
      text(weight: "bold")[`switch`],
        [3+ branches (`event.kind`, `status` enums, etc.)],
      text(weight: "bold")[`flow-loop`],
        [Loop / retry; usually wraps a `flow-col` containing an exit `branch`],
    )
  ]
]

#v(6pt)

These primitives are all block-level and can be *freely nested*: putting a `switch` inside one
arm of a `branch-merge`, or wrapping a `branch-merge` inside a `flow-loop`, are all legal.
Complex flows can be described purely by tree-shaped nesting — no manual coordinate placement required.
