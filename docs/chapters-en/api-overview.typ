#import "../../lib.typ": *
#import "../style.typ": *

= Pick an API by task <api-overview>

This chapter is a navigation map, not a complete reference.
If this is your first time using *blockcell*, decide here "what do I want to draw", then jump into the matching chapter.

*blockcell* is best for *clearly-structured diagrams made of blocks and containers*. You usually don't need to understand the whole API up front — you just need to pick the right entry point.

== Start with these three layers <api-overview-layers>

#align(center)[
  #grid(
    columns: 3,
    column-gutter: 12pt,

    region(fill: rgb("#E3F2FD"), width: 155pt)[
      #text(weight: "bold")[Layer 1 — Atoms]
      #v(3pt)
      #text(size: 0.9em)[
        Start from a single visual element.\
        For: blocks, tags, notes, arrows.
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `cell` `tag` `badge` `note`\
        `label` `sub-label` `span-label`\
        `wrap` `brace` `edge`
      ]
    ],

    region(fill: rgb("#E8F5E9"), width: 155pt)[
      #text(weight: "bold")[Layer 2 — Containers]
      #v(3pt)
      #text(size: 0.9em)[
        Organize multiple elements into one whole.\
        For: groups, wraps, connections, captions.
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `region` `target` `connector`\
        `group` `stack` `divider`\
        `detail` `entry-list`
      ]
    ],

    region(fill: rgb("#FFF3E0"), width: 155pt)[
      #text(weight: "bold")[Layer 3 — Composites]
      #v(3pt)
      #text(size: 0.9em)[
        Generate full diagram structures directly.\
        For: titled blocks, bit fields, legends, row layouts.
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `schema` `linked-schema`\
        `grid-row` `lane` `section`\
        `legend` `bit-row` `flex-row`\
        `seq-lane`
      ]
    ],
  )
]

#v(8pt)

If you just want to get going quickly, the recommended order is:

#align(center)[
  #region(fill: rgb("#F5F5F5"), width: 100%)[
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Step 1], [Learn #doc-link("layer1-cell")[`cell`] first — the foundational block.],
      text(weight: "bold")[Step 2], [Then #doc-link("layer2-region")[`region`] — wrap multiple blocks into one structure.],
      text(weight: "bold")[Step 3], [Then #doc-link("layer3-schema")[`schema`] — give a diagram a title and caption.],
      text(weight: "bold")[Step 4], [Finally, jump to the topical chapter you need: #doc-link("flows")[flowcharts], #doc-link("states")[state diagrams], #doc-link("tree")[trees], or #doc-link("seq")[sequence diagrams].],
    )
  ]
]

== Pick an entry by what you want to draw <api-overview-by-task>

=== Memory layouts, data structures, field blocks

This is *blockcell*'s most natural use case.
Start from these components:

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("layer1-cell", "cell") #api-ref("layer2-region", "region") #api-ref("layer3-schema", "schema")],
      text(weight: "bold")[Often paired with], [#api-ref("layer1-sub-label", "sub-label") #api-ref("layer1-tag", "tag") #api-ref("layer2-target", "target") #api-ref("layer2-connector", "connector") #api-ref("layer1-wrap", "wrap")],
      text(weight: "bold")[Typical uses], [Field layouts, pointer-and-target regions, enum variants, container internals],
    )
  ]
]

#section-label[Minimal combination]

#example-pair(
  ```typ
  #schema(title: raw("Vec<T>"))[
    #region[
      #cell[ptr]
      #cell[len]
      #cell[cap]
    ]
  ]
  ```,
  [
    #schema(title: raw("Vec<T>"))[
      #region[
        #cell[`ptr`]
        #cell[`len`]
        #cell[`cap`]
      ]
    ]
  ],
)

=== Protocol headers, registers, bit fields

Start from #api-ref("layer3-bit-row", "bit-row").
If you also need a title, caption, or multi-row composition, combine it with #api-ref("layer3-section", "section"), #api-ref("layer3-schema", "schema"), and #api-ref("layer3-legend", "legend").

#align(center)[
  #region(fill: rgb("#FFF3E0"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("layer3-bit-row", "bit-row")],
      text(weight: "bold")[Often paired with], [#api-ref("layer3-section", "section") #api-ref("layer3-legend", "legend") #api-ref("layer1-cell", "cell") #api-ref("layer2-region", "region")],
      text(weight: "bold")[Typical uses], [IPv4 / TCP headers, register bitmaps, fixed-width field layouts],
    )
  ]
]

#section-label[Minimal combination]

#wide-example(
  ```typ
  #bit-row(total: 16, width: 220pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [Flags], fill: palettes.network.flag),
  ))
  ```,
  [
    #bit-row(total: 16, width: 220pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [Flags], fill: palettes.network.flag),
    ))
  ],
)

=== Flowcharts

If your flow is *top-down with structured branching*, jump to the #doc-link("flows")["Flowcharts" chapter].
These diagrams don't need manual coordinate placement — just describe them step by step.

#align(center)[
  #region(fill: rgb("#FFECB3"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("flows-flow-col", "flow-col")],
      text(weight: "bold")[Often paired with], [#api-ref("flows-process", "process") #api-ref("flows-decision", "decision") #api-ref("flows-terminal", "terminal") #api-ref("flows-branch", "branch") #api-ref("flows-branch-merge", "branch-merge") #api-ref("flows-switch", "switch") #api-ref("flows-flow-loop", "flow-loop")],
      text(weight: "bold")[Typical uses], [Business flows, request handling, conditional branches, retry loops],
    )
  ]
]

#section-label[Minimal combination]

#wide-example(
  ```typ
  #flow-col(
    terminal[Start],
    process[Load config],
    decision[Valid?],
    terminal[Done],
  )
  ```,
  [
    #flow-col(
      terminal[Start],
      process[Load config],
      decision[Valid?],
      terminal[Done],
    )
  ],
)

#section-label[When this isn't the right fit]

If you need freeform routing, cross-region connections, or complex 2D topologies, this set of APIs isn't the best entry point.

=== State machines

If you want to express *transitions between states*, jump to the #doc-link("states")["State transition diagrams" chapter].
The most common entry point is #api-ref("states-state-chain", "state-chain").

#align(center)[
  #region(fill: rgb("#FCE4EC"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("states-state-chain", "state-chain") #api-ref("states-state", "state")],
      text(weight: "bold")[Often paired with], [#api-ref("states-loop", "loop") #api-ref("states-jump", "jump")],
      text(weight: "bold")[Typical uses], [Lifecycles, protocol states, resource state transitions, finite state machines],
    )
  ]
]

#section-label[Minimal combination]

#wide-example(
  ```typ
  #state-chain(
    state("idle", initial: true)[idle],
    state("running", edge-label: [start])[running],
    state("done", edge-label: [finish], accept: true)[done],
  )
  ```,
  [
    #state-chain(
      state("idle", initial: true)[idle],
      state("running", edge-label: [start])[running],
      state("done", edge-label: [finish], accept: true)[done],
    )
  ],
)

=== Hierarchies, directory trees, org charts

If your diagram is a *parent-child hierarchy*, jump to the #doc-link("tree")["Hierarchical tree diagrams" chapter].
The entry point is simple: #api-ref("tree-tree", "tree") `(...)`.

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("tree-tree", "tree") #api-ref("tree-node", "node")],
      text(weight: "bold")[Often paired with], [#api-ref("layer1-cell", "cell") #api-ref("flows-process", "process") #api-ref("layer1-flow-node", "flow-node") as node content],
      text(weight: "bold")[Typical uses], [Directory trees, JSON hierarchies, BSTs, org charts, taxonomies],
    )
  ]
]

#section-label[Minimal combination]

#wide-example(
  ```typ
  #tree(
    node[root],
    tree(node[left], node[left.left], node[left.right]),
    tree(node[right], node[right.left], node[right.right]),
  )
  ```,
  [
    #tree(
      node[root],
      tree(node[left], node[left.left], node[left.right]),
      tree(node[right], node[right.left], node[right.right]),
    )
  ],
)

=== Sequence diagrams, call chains, participant interactions

If your diagram is about *who calls whom and how messages flow back*, jump to the #doc-link("seq")["Sequence diagrams" chapter].
The entry point is #api-ref("layer3-seq-lane", "seq-lane").

#align(center)[
  #region(fill: rgb("#E0F2F1"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Start here], [#api-ref("layer3-seq-lane", "seq-lane")],
      text(weight: "bold")[Often paired with], [#api-ref("seq-seq-call", "seq-call") #api-ref("seq-seq-ret", "seq-ret") #api-ref("seq-seq-note", "seq-note") #api-ref("seq-fragments", "seq-alt") #api-ref("seq-fragments", "seq-loop")],
      text(weight: "bold")[Typical uses], [Service call chains, protocol handshakes, login flows, system interactions],
    )
  ]
]

#section-label[Minimal combination]

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "server")[GET /users],
    seq-ret("server", "client")[200 OK],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET /users],
      seq-ret("server", "client")[200 OK],
    )
  ],
)

== Most-used components at a glance <api-overview-quick-picks>

If you'd rather not read full chapters, just remember these high-frequency entry points:

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[#api-ref("layer1-cell", "cell")], [A single block. Almost every structure diagram starts here.],
      text(weight: "bold")[#api-ref("layer2-region", "region")], [Wrap multiple blocks into one whole.],
      text(weight: "bold")[#api-ref("layer3-schema", "schema")], [Add a title and caption to a diagram.],
      text(weight: "bold")[#api-ref("layer3-linked-schema", "linked-schema")], [Express the common "field region pointing at a target region" structure.],
      text(weight: "bold")[#api-ref("layer3-bit-row", "bit-row")], [Draw protocol headers and bit fields.],
      text(weight: "bold")[#api-ref("flows-flow-col", "flow-col")], [Draw a top-down flowchart.],
      text(weight: "bold")[#api-ref("states-state-chain", "state-chain")], [Draw a state machine.],
      text(weight: "bold")[#api-ref("tree-tree", "tree")], [Draw a hierarchical tree.],
      text(weight: "bold")[#api-ref("layer3-seq-lane", "seq-lane")], [Draw a sequence diagram.],
    )
  ]
]

== How to pick a palette <api-overview-palettes>

You don't need to customize colors up front.
In most cases, the built-in palettes are enough.

#align(center)[
  #region(fill: rgb("#F3E5F5"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[#api-ref("palettes-status", "palettes.status")], [Semantic status colors: success, warning, danger, info, neutral.],
      text(weight: "bold")[#api-ref("palettes-pastel", "palettes.pastel")], [General-purpose soft colors, suitable for most structure diagrams.],
      text(weight: "bold")[#api-ref("palettes-categorical", "palettes.categorical")], [A set of distinct categorical colors, suitable for legends and groups.],
      text(weight: "bold")[#api-ref("palettes-sequential", "palettes.sequential")], [Same-hue intensity ramps, suitable for ranks and intensities.],
      text(weight: "bold")[Domain palettes], [#api-ref("palettes-domain", "palettes.rust") #api-ref("palettes-domain", "palettes.network") #api-ref("palettes-domain", "palettes.cache") match example styles directly.],
    )
  ]
]

#section-label[Smallest example]

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #cell(fill: palettes.pastel.blue)[Users]
  #cell(fill: palettes.categorical.at(1))[Worker]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #cell(fill: palettes.pastel.blue)[Users]
    #h(6pt)
    #cell(fill: palettes.categorical.at(1))[Worker]
  ],
)

== Recommended reading order <api-overview-reading-order>

If you'd like to learn the library systematically, we suggest reading in this order:

#align(center)[
  #region(fill: rgb("#F5F5F5"), width: 100%)[
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[Ch. 1], [#doc-link("intro")[Introduction]: what this library is good (and not good) for.],
      text(weight: "bold")[Ch. 2], [This chapter: pick an entry point by task.],
      text(weight: "bold")[Ch. 3], [#doc-link("patterns")[Common patterns]: palettes, helpers, and useful idioms.],
      text(weight: "bold")[Ch. 4], [#doc-link("examples")[Worked examples]: copy the example closest to your scenario first.],
      text(weight: "bold")[Ch. 5], [#doc-link("layer1")[Layer 1] / #doc-link("layer2")[Layer 2] / #doc-link("layer3")[Layer 3]: full reference, by need.],
      text(weight: "bold")[Ch. 6], [Topical chapters: #doc-link("flows")[flowcharts], #doc-link("states")[state diagrams], #doc-link("tree")[trees], #doc-link("seq")[sequence diagrams].],
    )
  ]
]

== Where to go next <api-overview-next>

- Want to draw your first structure diagram fast: see #doc-link("patterns")["Common patterns"] and #doc-link("layer1")["Layer 1 — Atoms"]
- Want to copy a real-world case: see #doc-link("examples")["Worked examples"]
- Want to draw a flowchart: see #doc-link("flows")["Flowcharts"]
- Want to draw a state machine: see #doc-link("states")["State transition diagrams"]
- Want to draw a tree: see #doc-link("tree")["Hierarchical tree diagrams"]
- Want to draw a sequence diagram: see #doc-link("seq")["Sequence diagrams"]
