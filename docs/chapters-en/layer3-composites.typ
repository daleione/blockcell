#import "../../lib.typ": *
#import "../style.typ": *

== Layer 3 — Composites <layer3>

This chapter covers composite components that produce common diagram structures directly.

If the previous two chapters were about "single elements" and "how to organize elements", this chapter is about:

- Building a complete diagram block in one shot
- Expressing common structures with less code
- Wrapping recurring layout patterns into stable, reusable components

If this is your first time, focus on these first:

1. #api-ref("layer3-schema", "schema")
2. #api-ref("layer3-linked-schema", "linked-schema")
3. #api-ref("layer3-grid-row", "grid-row")
4. #api-ref("layer3-section", "section")
5. #api-ref("layer3-legend", "legend")
6. #api-ref("layer3-bit-row", "bit-row")

=== `schema` <layer3-schema>

Displays a standalone diagram block, typically with a title and an optional description.

Good for:

- Showing one structure on its own
- Comparing multiple structures side by side
- Adding a title and short caption to a diagram
- Wrapping a stretch of structural content as a reusable display unit

#section-label[Most basic usage]

#example-pair(
  ```typst
  #schema(title: [User])[
    #region[
      #cell[id]
      #cell[name]
      #cell[email]
    ]
  ]
  ```
,
  [
    #schema(title: [User])[
      #region[
        #cell[id]
        #cell[name]
        #cell[email]
      ]
    ]
  ],
)

#section-label[Common parameters]

#params-box("schema",
  ("body",  ("content",)),
  ("title", ("none", "content")),
  ("desc",  ("none", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("title", ("none", "content"),
  default: raw("none", lang: none))[
  Block title. Good for type names, module names, structure names.
]

#param-detail("desc", ("none", "content"),
  default: raw("none", lang: none))[
  Short caption below the title. A one-liner about purpose — not a place for long prose.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Block width. Set explicitly when you need to align several blocks side by side, or to bound a longer caption.
]

#section-label[Side-by-side]

#wide-example(
  ```typst
  #schema(title: [A])[
    #region[#cell[x]]
  ]#schema(title: [B])[
    #region[#cell[y]]
  ]#schema(title: [C])[
    #region[#cell[z]]
  ]
  ```
,
  [
    #schema(title: [A])[
      #region[#cell[x]]
    ]#schema(title: [B])[
      #region[#cell[y]]
    ]#schema(title: [C])[
      #region[#cell[z]]
    ]
  ],
)

#section-label[When to use it]

- You want to present a structure as a standalone block
- You need a title and a short caption
- You want side-by-side comparisons
- You want the block to be reusable across the document

#section-label[Often paired with]

- `region` to display the structural body
- `cell` to display individual fields
- `divider` for mutually exclusive layouts
- `target` and `connector` for top-bottom layered structures

=== `linked-schema` <layer3-linked-schema>

Expresses the common "field region on top + target region below" structure.

Good for:

- A pointer and its target object
- Reference relationships
- Heap objects
- An upper structure pointing to lower-layer storage
- Anything that needs both a "field region" and a "target region" together

If your diagram fits this pattern, prefer `linked-schema` — it's usually cleaner than assembling `schema + region + connector + target` by hand.

#section-label[Most basic usage]

#example-pair(
  ```typst
  #linked-schema(
    title: [Box<T>],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
    ),
    target-label: "(heap)",
    cell(fill: palettes.rust.any)[T],
  )
  ```
,
  [
    #linked-schema(
      title: [Box<T>],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
      ),
      target-label: "(heap)",
      cell(fill: palettes.rust.any)[T],
    )
  ],
)

#section-label[Common parameters]

#params-box("linked-schema",
  ("body",          ("content",)),
  ("title",         ("none", "content")),
  ("desc",          ("none", "content")),
  ("width",         ("auto", "length")),
  ("fields",        ("array",)),
  ("target-fill",   ("color",)),
  ("target-label",  ("none", "str")),
  ("target-width",  ("auto", "length")),
  ("danger",        ("bool",)),
  returns: "content",
)

#param-detail("title", ("none", "content"),
  default: raw("none", lang: none))[
  Block title.
]

#param-detail("desc", ("none", "content"),
  default: raw("none", lang: none))[
  Caption text.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Total block width. Set explicitly when the caption is long or you need to align multiple blocks.
]

#param-detail("fields", ("array",))[
  Array of items in the upper field region. Array order = visual order.
]

#param-detail("target-fill", ("color",),
  default: raw("rgb(\"#FDECDC\")", lang: none))[
  Target-region background color.
]

#param-detail("target-label", ("none", "str"),
  default: raw("none", lang: none))[
  Target-region label, e.g. `(heap)`, `(static)`.
]

#param-detail("target-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Target-region width.
]

#param-detail("danger", ("bool",),
  default: raw("false", lang: none))[
  Apply a stronger danger style to the upper field region.
]

#section-label[A slightly fuller example]

#example-pair(
  ```typst
  #linked-schema(
    width: 160pt,
    title: raw("Vec<T>"),
    desc: [Pointer, length, and capacity.],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
      cell(fill: palettes.rust.sized)[len],
      cell(fill: palettes.rust.sized)[cap],
    ),
    target-fill: palettes.rust.heap,
    target-label: "(heap)",
  )[
    #cell(fill: palettes.rust.any)[T]
    #cell(fill: palettes.rust.any)[T]
    #note[… len]
  ]
  ```
,
  [
    #linked-schema(
      width: 160pt,
      title: raw("Vec<T>"),
      desc: [Pointer, length, and capacity.],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
        cell(fill: palettes.rust.sized)[len],
        cell(fill: palettes.rust.sized)[cap],
      ),
      target-fill: palettes.rust.heap,
      target-label: "(heap)",
    )[
      #cell(fill: palettes.rust.any)[T]
      #cell(fill: palettes.rust.any)[T]
      #note[… len]
    ]
  ],
)

#section-label[When to use it]

- You want to express "field region pointing at a target region"
- You're drawing heap objects, references, layered structures
- You don't want to assemble several primitives by hand
- Your diagram fits this common pattern

=== `grid-row` <layer3-grid-row>

Displays a "left-side label + one row of content on the right".

Good for:

- Multi-row aligned structure diagrams
- Cache / memory rows
- Register or table-shaped layouts
- Diagrams where each row carries one topic

#section-label[Most basic usage]

#example-pair(
  ```typst
  #grid-row(label: [Memory])[
    #cell(width: 28pt, height: 20pt)[03]
    #cell(width: 28pt, height: 20pt)[21]
    #cell(width: 28pt, height: 20pt)[7F]
  ]
  ```
,
  [
    #grid-row(label: [Memory])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[03]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[21]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[7F]
    ]
  ],
)

#section-label[Common parameters]

#params-box("grid-row",
  ("body",        ("content",)),
  ("label",       ("none", "content")),
  ("label-width", ("auto", "length")),
  ("label-align", ("alignment",)),
  returns: "content",
)

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  Left-side label.
]

#param-detail("label-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Label-column width. When stacking multiple rows, use the same width on all of them so labels line up.
]

#param-detail("label-align", ("alignment",),
  default: raw("right", lang: none))[
  Alignment of the label inside the label column. Defaults to right-aligned, which keeps multiple rows tidy.
]

#section-label[Multiple rows together]

#example-pair(
  ```typst
  #let row = grid-row.with(label-width: 52pt)
  #row(label: [Memory])[#cell[03] #cell[21]]
  #row(label: [CPU 0])[#cell[S] #cell[S]]
  #row(label: [CPU 1])[#cell[S] #cell[S]]
  ```
,
  [
    #let row = grid-row.with(label-width: 52pt)
    #row(label: [Memory])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[03]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[21]
    ]
    #row(label: [CPU 0])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
    ]
    #row(label: [CPU 1])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
    ]
  ],
)

#section-label[When to use it]

- You need multi-row alignment
- Each row has a clear label
- You're drawing caches, memory, registers, or table-shaped structures
- You don't want to align label columns by hand

=== `lane` <layer3-lane>

Displays a horizontal track of multiple stages or status blocks.

Good for:

- Thread or pipeline stages
- Horizontal status changes
- A timeline split into segmented states
- Simple "name + several colored segments" displays

#section-label[Most basic usage]

#example-pair(
  ```typst
  #lane(
    name: [Thread 1],
    items: (
      (label: [Parse], fill: palettes.pastel.blue),
      (label: [Run], fill: palettes.pastel.green),
      (label: [Wait], fill: palettes.pastel.yellow),
    ),
  )
  ```
,
  [
    #box(width: 100%)[
      #lane(
        name: [Thread 1],
        items: (
          (label: [Parse], fill: palettes.pastel.blue),
          (label: [Run], fill: palettes.pastel.green),
          (label: [Wait], fill: palettes.pastel.yellow),
        ),
      )
    ]
  ],
)

#section-label[Common parameters]

#params-box("lane",
  ("name",  ("none", "content")),
  ("items", ("array",)),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("name", ("none", "content"),
  default: raw("none", lang: none))[
  Track name, usually shown on the left.
]

#param-detail("items", ("array",))[
  Track segments. Each item typically has `label` and `fill`.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Total track width.
]

#section-label[When to use it]

- You want to express multiple stages along a horizontal track
- You're drawing threads, pipelines, or stage transitions
- You need something more "horizontal-stage" oriented than `grid-row`

=== `section` <layer3-section>

Wraps a related set of items into a titled card.

Good for:

- A complete sub-figure
- A group of related diagram blocks
- A captioned region with a clear boundary
- Organizing several diagrams into clearer blocks within a document

#section-label[Most basic usage]

#example-pair(
  ```typst
  #section[Cache hierarchy][
    #region[CPU]
    #v(4pt)
    #region[Memory]
  ]
  ```
,
  [
    #section[Cache hierarchy][
      #region[CPU]
      #v(4pt)
      #region[Memory]
    ]
  ],
)

#section-label[Common parameters]

#params-box("section",
  ("title", ("content",)),
  ("body",  ("content",)),
  ("fill",  ("color",)),
  ("stroke", ("stroke",)),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("title", ("content",))[
  Card title.
]

#param-detail("body", ("content",))[
  Card content.
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Card background.
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  Card border style.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Card width.
]

#section-label[When to use it]

- You want to present a group of figures as one complete unit
- You need a more prominent titled card
- You're writing tutorials, manuals, or explanatory documentation with full examples

=== `legend` <layer3-legend>

Displays the mapping between colors and meaning.

Good for:

- Status keys
- Field-color keys
- Category-color keys
- Diagrams with several colors that need explanation

#section-label[Most basic usage]

#example-pair(
  ```typst
  #legend(
    (label: [Modified], fill: palettes.cache.modified),
    (label: [Shared], fill: palettes.cache.shared),
    (label: [Invalid], fill: palettes.cache.invalid),
  )
  ```
,
  [
    #legend(
      (label: [Modified], fill: palettes.cache.modified),
      (label: [Shared], fill: palettes.cache.shared),
      (label: [Invalid], fill: palettes.cache.invalid),
    )
  ],
)

#section-label[Common parameters]

#params-box("legend",
  ("..items", ("array",)),
  ("gap", ("length",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  Legend entries. Each item typically has `label` and `fill`.
]

#param-detail("gap", ("length",),
  default: raw("8pt", lang: none))[
  Spacing between entries.
]

#section-label[When to use it]

- Colors in your diagram already carry semantics
- You want readers to understand what the colors mean quickly
- You're drawing protocol headers, cache states, or category structures

=== `bit-row` <layer3-bit-row>

Displays bit fields proportionally.

Good for:

- Protocol headers
- Register layouts
- Fixed-width field diagrams
- Structures whose widths are determined by bit counts

This is the most-used entry point for protocol headers and register diagrams.

#section-label[Most basic usage]

#wide-example(
  ```typst
  #bit-row(total: 16, width: 220pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [Flags], fill: palettes.network.flag),
  ))
  ```
,
  [
    #bit-row(total: 16, width: 220pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [Flags], fill: palettes.network.flag),
    ))
  ],
)

#section-label[Common parameters]

#params-box("bit-row",
  ("fields",    ("array",)),
  ("total",     ("int",)),
  ("width",     ("length",)),
  ("show-bits", ("bool",)),
  returns: "content",
)

#param-detail("fields", ("array",))[
  Field array. Each item typically has `bits`, `label`, `fill`, and optionally `stroke`, `dash`.
]

#param-detail("total", ("int",))[
  Total bit width of this row, e.g. `16`, `32`, `64`.
]

#param-detail("width", ("length",))[
  Total visual width of this row.
]

#param-detail("show-bits", ("bool",),
  default: raw("true", lang: none))[
  Whether to show bit-count annotations on each field.
]

#section-label[Multiple rows together]

#wide-example(
  ```typst
  #bit-row(total: 32, width: 320pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [DSCP], fill: palettes.network.flag),
    (bits: 16, label: [Total Length], fill: palettes.network.addr),
  ))
  #bit-row(total: 32, width: 320pt, fields: (
    (bits: 16, label: [ID], fill: palettes.network.meta),
    (bits: 16, label: [Flags + Offset], fill: palettes.network.flag),
  ))
  ```
,
  [
    #bit-row(total: 32, width: 320pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [DSCP], fill: palettes.network.flag),
      (bits: 16, label: [Total Length], fill: palettes.network.addr),
    ))
    #bit-row(total: 32, width: 320pt, fields: (
      (bits: 16, label: [ID], fill: palettes.network.meta),
      (bits: 16, label: [Flags + Offset], fill: palettes.network.flag),
    ))
  ],
)

#section-label[When to use it]

- You're drawing protocol headers or registers
- Field widths are determined by bit count
- You want field proportions to come out automatically
- You don't want to compute every field's display width by hand

=== `flex-row` <layer3-flex-row>

Distributes widths in a row proportionally.

Good for:

- Multiple blocks sharing a row by ratio
- Layouts where you don't want to assign each block a fixed width
- "1:1:2"-style allocations
- Stable horizontal allocation under bounded width

#section-label[Most basic usage]

#example-pair(
  ```typst
  #flex-row(
    (flex: 1, body: cell(fill: palettes.pastel.blue, width: 100%)[A]),
    (flex: 1, body: cell(fill: palettes.pastel.green, width: 100%)[B]),
    (flex: 2, body: cell(fill: palettes.pastel.orange, width: 100%)[C]),
  )
  ```
,
  [
    #box(width: 220pt)[
      #flex-row(
        (flex: 1, body: cell(fill: palettes.pastel.blue, width: 100%)[A]),
        (flex: 1, body: cell(fill: palettes.pastel.green, width: 100%)[B]),
        (flex: 2, body: cell(fill: palettes.pastel.orange, width: 100%)[C]),
      )
    ]
  ],
)

#section-label[Common parameters]

#params-box("flex-row",
  ("..items", ("array",)),
  ("width",   ("auto", "length")),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  Row items. Each item typically has `flex` and `body`.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Total row width.
]

#param-detail("gap", ("length",),
  default: raw("0pt", lang: none))[
  Spacing between columns.
]

#param-detail("align", ("alignment",),
  default: raw("horizon", lang: none))[
  Row alignment.
]

#section-label[When to use it]

- You want to distribute horizontal space proportionally
- You don't want to compute each column's width by hand
- You're drawing a multi-block row in a structure diagram
- You want the layout to remain stable across width changes

=== `seq-lane` <layer3-seq-lane>

Draws sequence diagrams.

Good for:

- Service call chains
- Protocol exchanges
- Login flows
- Message back-and-forth between multiple participants
- Diagrams expressing "who calls whom and when they return"

If your focus is interactions between participants — rather than a single object's state changes — start with `seq-lane`.

#section-label[Minimal example]

#wide-example(
  ```typst
  #seq-lane(
    seq-call("client", "server")[GET /users],
    seq-ret("server", "client")[200 OK],
  )
  ```
,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET /users],
      seq-ret("server", "client")[200 OK],
    )
  ],
)

#section-label[Parameters]

#params-box("seq-lane",
  ("..steps", ("content",)),
  ("participants", ("none", "array")),
  ("width", ("auto", "length")),
  ("activate", ("bool",)),
  ("autonumber", ("none", "bool", "str")),
  ("boxes", ("none", "array")),
  returns: "content",
)

#param-detail("..steps", ("content",))[
  Sequence-diagram steps, e.g. `seq-call`, `seq-ret`, `seq-note`, `seq-alt`, etc.
]

#param-detail("participants", ("none", "array"),
  default: raw("none", lang: none))[
  Participant declarations. Inferred from the order of first appearance in steps if omitted.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Total diagram width.
]

#param-detail("activate", ("bool",),
  default: raw("true", lang: none))[
  Whether to draw activation bars.
]

#param-detail("autonumber", ("none", "bool", "str"),
  default: raw("none", lang: none))[
  Whether to enable autonumbering.
]

#param-detail("boxes", ("none", "array"),
  default: raw("none", lang: none))[
  Participant grouping-box definitions.
]

#section-label[Common steps]

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[`seq-call`], [Synchronous call message],
      text(weight: "bold")[`seq-ret`], [Return message],
      text(weight: "bold")[`seq-note`], [Sticky-note caption],
      text(weight: "bold")[`seq-act`], [Single-column action block],
      text(weight: "bold")[`seq-alt`], [Conditional-branch fragment],
      text(weight: "bold")[`seq-loop`], [Loop fragment],
    )
  ]
]

#section-label[When to use it]

- You want to express interactions between participants
- You're drawing API call chains, protocol handshakes, service orchestrations
- You need messages, returns, branches, and loops as time-ordered semantics
- You don't want to place participants and message lines by hand

== Chapter summary <layer3-summary>

If you only want to remember the most-used composites, focus on these:

- `schema`: standalone diagram block
- `linked-schema`: field region + target region
- `grid-row`: left label + right content
- `section`: titled card
- `legend`: color key
- `bit-row`: bit-field row
- `seq-lane`: sequence-diagram entry point

If you'd like to learn richer diagrams by scenario next, continue with the topical chapters:

- Flowcharts
- State transition diagrams
- Hierarchical tree diagrams
- Sequence diagrams
