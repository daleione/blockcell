#import "../../lib.typ": *
#import "../style.typ": *

#metadata("layer1") <layer1>

== Layer 1 — Atoms

This chapter covers the foundational primitives. They're usually the first components you reach for:

- #api-ref("layer1-cell", "cell"): a single block
- #api-ref("layer1-tag", "tag") / #api-ref("layer1-badge", "badge"): compact markers
- #api-ref("layer1-note", "note") / #api-ref("layer1-label", "label"): supplementary captions
- #api-ref("layer1-sub-label", "sub-label") / #api-ref("layer1-span-label", "span-label"): field annotations
- #api-ref("layer1-wrap", "wrap"): an extra emphasized border
- #api-ref("layer1-edge", "edge"): a simple connection
- #api-ref("layer1-brace", "brace"): a range marker
- #api-ref("layer1-flow-node", "flow-node"): the underlying flowchart-node shape
- #api-ref("layer1-pill", "pill"): a filled mini-tag (type tag / role marker), complementing #api-ref("layer1-badge", "badge") (outline + status semantics)
- #api-ref("layer1-field-cell", "field-cell"): a four-corner annotated card for field / type entry documentation

If this is your first time, focus on these first:

1. #api-ref("layer1-cell", "cell")
2. #api-ref("layer1-badge", "badge")
3. #api-ref("layer1-sub-label", "sub-label")
4. #api-ref("layer1-edge", "edge")

#metadata("layer1-cell") <layer1-cell>
=== `cell`

The most basic block. Most structure diagrams begin with `cell`.

Typical contents:

- Fields
- Status blocks
- Small module blocks
- Single nodes
- Label blocks that need color and a border

#section-label[Most basic usage]

#example-pair(
  ```typst
  #cell[A]
  #cell(fill: palettes.pastel.blue)[B]
  #cell(fill: palettes.pastel.orange)[C]
  ```
,
  [
    #cell[A]
    #h(4pt)
    #cell(fill: palettes.pastel.blue)[B]
    #h(4pt)
    #cell(fill: palettes.pastel.orange)[C]
  ],
)

#section-label[Common parameters]

#params-box("cell",
  ("body",       ("content",)),
  ("fill",       ("color",)),
  ("width",      ("auto", "length")),
  ("height",     ("auto", "length")),
  ("stroke",     ("stroke",)),
  ("dash",       ("none", "str")),
  ("radius",     ("length",)),
  ("inset",      ("length", "dictionary")),
  ("expandable", ("bool",)),
  ("phantom",    ("bool",)),
  ("overlay",    ("none", "content")),
  ("subtitle",   ("none", "content")),
  ("baseline",   ("ratio",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface-strong", lang: none))[
  Block background color. In most cases, just changing this is enough to distinguish fields or modules.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Width. Set explicitly when you need fixed field widths — for example, byte cells, register fields, small status blocks.
]

#param-detail("height", ("auto", "length"),
  default: raw("auto", lang: none))[
  Height. When several blocks sit side by side, setting a uniform height usually looks tidier.
]

#param-detail("stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  Border style. Accepts any Typst stroke, e.g. `2pt + red`.
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  Border line style. Common values: `none`, `"dashed"`, `"dotted"`.
]

#param-detail("expandable", ("bool",),
  default: raw("false", lang: none))[
  Show "expandable" markers on either side of the content. Good for fields with variable length or count.
]

#param-detail("phantom", ("bool",),
  default: raw("false", lang: none))[
  Use a softer visual style to indicate "missing", "zero-sized", or "placeholder" content.
]

#param-detail("overlay", ("none", "content"),
  default: raw("none", lang: none))[
  Overlay a small marker in the upper right corner. Good for cache states, sidecar tags, or short status letters.
]

#param-detail("subtitle", ("none", "content"),
  default: raw("none", lang: none))[
  Add a smaller subtitle line below the main label. Good for "main name + qualifier" blocks.
]

#section-label[Common usage]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.blue)[Users]
  #cell(fill: palettes.pastel.green, width: 56pt)[Ready]
  #cell(fill: palettes.pastel.orange, expandable: true)[Payload]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[Users]
    #h(4pt)
    #cell(fill: palettes.pastel.green, width: 56pt)[Ready]
    #h(4pt)
    #cell(fill: palettes.pastel.orange, expandable: true)[Payload]
  ],
)

#section-label[With a subtitle]

#example-pair(
  ```typst
  #cell(
    fill: palettes.pastel.blue,
    width: 72pt,
    height: 36pt,
    subtitle: [(MySQL)],
  )[Orders]
  ```
,
  [
    #cell(
      fill: palettes.pastel.blue,
      width: 72pt,
      height: 36pt,
      subtitle: [(MySQL)],
    )[Orders]
  ],
)

#section-label[When to use it]

- You only need a basic block
- You're drawing fields, modules, or status blocks
- You want to sketch the structure first and add containers and captions later

#section-label[Common pairings]

- Pair with `sub-label` to annotate field sizes
- Pair with `region` to form a structure block
- Pair with `schema` to form a complete diagram block
- Pair with `wrap` for an emphasized border

#metadata("layer1-tag") <layer1-tag>
=== `tag`

For labels, discriminants, or small marker blocks.

It fits content that "looks like a field but is semantically a label", such as:

- Enum discriminants
- Type tags
- Small classification markers

#section-label[Most basic usage]

#example-pair(
  ```typst
  #tag[Tag]
  #tag(fill: palettes.pastel.yellow)[Kind]
  ```
,
  [
    #tag[Tag]
    #h(6pt)
    #tag(fill: palettes.pastel.yellow)[Kind]
  ],
)

#section-label[Common parameters]

#params-box("tag",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Tag background color. Usually you only need to change the color — no extra sizing required.
]

#section-label[When to use it]

- You want to express "label" rather than a regular field
- You're drawing enums, discriminants, or classification markers
- You want clear visual distinction from a plain `cell`

#metadata("layer1-note") <layer1-note>
=== `note`

For short inline annotations.

Typical contents:

- `…`
- `… n times`
- Brief remarks
- Small hints right after a sequence of fields

#section-label[Most basic usage]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.red)[T]
  #cell(fill: palettes.pastel.red)[T]
  #note[… n times]
  ```
,
  [
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[… n times]
  ],
)

#section-label[Common parameters]

#params-box("note",
  ("body", ("content",)),
  returns: "content",
)

#section-label[When to use it]

- You only need a short caption
- The note should sit next to a primitive, not stand alone
- You don't want the note to steal visual focus

#metadata("layer1-label") <layer1-label>
=== `label`

For weak structural caption text.

Typical contents:

- `(heap)`
- `Memory`
- `Only on eviction`
- Short positional or semantic hints

#section-label[Most basic usage]

#example-pair(
  ```typst
  #label[Memory]
  #label[(heap)]
  #label[Only on eviction]
  ```
,
  [
    #label[Memory]
    #h(10pt)
    #label[(heap)]
    #h(10pt)
    #label[Only on eviction]
  ],
)

#section-label[Common parameters]

#params-box("label",
  ("body", ("content",)),
  returns: "content",
)

#section-label[When to use it]

- You need caption text weaker than body text
- You want to add positional, layered, or semantic hints to a diagram
- You don't want the visual emphasis of a `badge`

#metadata("layer1-badge") <layer1-badge>
=== `badge`

A compact status marker.

The most common usage is to pass `status:` and let the color carry the semantics:

- Success
- Warning
- Error
- Info
- Neutral

#section-label[Most basic usage]

#example-pair(
  ```typst
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
  ],
)

#section-label[Common parameters]

#params-box("badge",
  ("body",   ("content",)),
  ("status", ("none", "str")),
  ("fill",   ("color",)),
  ("stroke", ("color",)),
  returns: "content",
)

#param-detail("status", ("none", "str"),
  default: raw("none", lang: none))[
  Semantic status. Common values: `success`, `warning`, `danger`, `info`, `neutral`.
  If a component supports `status:`, prefer it over hand-written colors.
]

#param-detail("fill", ("color",),
  default: raw("rgb(\"#FFECB3\")", lang: none))[
  Custom background color. Only set this when you're not using `status:`.
]

#param-detail("stroke", ("color",),
  default: raw("rgb
(\"#FF8F00\")", lang: none))[
  Custom border color. Usually paired with `fill`.
]

#section-label[Explicit colors]

#example-pair(
  ```typst
  #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
  #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
  ```
,
  [
    #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
    #h(6pt)
    #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
  ],
)

#section-label[When to use it]

- You need a compact status marker
- You want the color to convey meaning directly
- You don't want to use a full `cell` for a tiny status block

#metadata("layer1-sub-label") <layer1-sub-label>
=== `sub-label`

For a short annotation following a field name.

The most common use is annotating field size, e.g.:

- `2/4/8`
- `2B`
- `32b`

#section-label[Most basic usage]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.blue)[
    ptr#sub-label[2/4/8]
  ]
  #cell(fill: palettes.pastel.yellow)[
    Length#sub-label[2B]
  ]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[ptr#sub-label[2/4/8]]
    #h(6pt)
    #cell(fill: palettes.pastel.yellow)[Length#sub-label[2B]]
  ],
)

#section-label[Common parameters]

#params-box("sub-label",
  ("body", ("content",)),
  returns: "content",
)

#section-label[When to use it]

- You want a tiny size annotation right after a field name
- You don't want a separate caption line or block
- You're drawing protocol fields, memory fields, register fields

#metadata("layer1-span-label") <layer1-span-label>
=== `span-label`

Annotates a horizontal range with a caption.

Typical labels:

- `capacity`
- `padding`
- `payload`
- A shared meaning over a contiguous run of fields

#section-label[Most basic usage]

#example-pair(
  ```typst
  #box(width: 130pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[…]
    #span-label[capacity]
  ]
  ```
,
  [
    #box(width: 130pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #note[…]
      #span-label[capacity]
    ]
  ],
)

#section-label[Common parameters]

#params-box("span-label",
  ("body",  ("content",)),
  ("width", ("auto", "length", "ratio")),
  returns: "content",
)

#param-detail("width", ("auto", "length", "ratio"),
  default: raw("100%", lang: none))[
  Annotation width. Defaults to filling the parent; if you only want to mark a small range, set an explicit length.
]

#section-label[When to use it]

- You want a single caption over a contiguous run of fields
- You want to express "this stretch belongs to one concept"
- You're drawing array capacity, reserved regions, or grouped field ranges

#metadata("layer1-wrap") <layer1-wrap>
=== `wrap`

Adds an extra outer border to its content.

Typical uses:

- Emphasize a particular field or region
- Create a double-border effect
- Indicate "this block carries extra semantics"

#section-label[Most basic usage]

#example-pair(
  ```typst
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #wrap(stroke: 3pt + rgb("#FFD700"))[
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[Common parameters]

#params-box("wrap",
  ("body",   ("content",)),
  ("stroke", ("stroke",)),
  ("radius", ("length",)),
  ("inset",  ("length",)),
  returns: "content",
)

#param-detail("stroke", ("stroke",),
  default: raw("3pt + palettes.base.border", lang: none))[
  Outer border style. A thicker, more prominent stroke is the typical choice for emphasis.
]

#param-detail("radius", ("length",),
  default: raw("0pt", lang: none))[
  Outer border corner radius.
]

#param-detail("inset", ("length",),
  default: raw("2pt", lang: none))[
  Spacing between the outer border and the inner content.
]

#section-label[When to use it]

- You want to emphasize a field or block
- You need a double-border effect
- You want to add a layer of visual semantics without changing the inner content

#metadata("layer1-edge") <layer1-edge>
=== `edge`

For a simple directional connection.

Typical uses:

- A points to B
- Call relationships
- Sequential relationships
- Simple state transitions
- Connections between adjacent elements

It works best for connecting adjacent content; for complex freeform routing, use a dedicated drawing library.

#section-label[Most basic usage]

#wide-example(
  ```typst
  #cell[Controller]
  #edge(label: [HTTP])
  #cell[Service]
  #edge(label: [SQL], style: "dashed")
  #cell[DB]
  ```
,
  [
    #cell[Controller]
    #edge(label: [HTTP])
    #cell[Service]
    #edge(label: [SQL], style: "dashed")
    #cell[DB]
  ],
)

#section-label[Common parameters]

#params-box("edge",
  ("label",     ("none", "content")),
  ("direction", ("str",)),
  ("style",     ("str",)),
  ("head",      ("str",)),
  ("stroke",    ("stroke",)),
  ("length",    ("auto", "length")),
  returns: "content",
)

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  Edge label. Good for short annotations: protocol name, action name, condition name.
]

#param-detail("direction", ("str",),
  default: raw("\"right\"", lang: none))[
  Direction. Common values: `right`, `left`, `down`, `up`.
]

#param-detail("style", ("str",),
  default: raw("\"solid\"", lang: none))[
  Line style. Common values: `solid`, `dashed`, `dotted`.
]

#param-detail("head", ("str",),
  default: raw("\"arrow\"", lang: none))[
  Arrowhead style. `arrow` for an arrow tip, `none` for a plain segment.
]

#param-detail("length", ("auto", "length"),
  default: raw("auto", lang: none))[
  Edge length. Set explicitly when you need a tighter or looser layout.
]

#section-label[When to use it]

- You need a simple, direct connection
- The endpoints are adjacent
- You want to express order, calls, or pointing relationships

#section-label[When not to use it]

- Routing across multiple regions
- Complex 2D routing
- A freeform connection network

#metadata("layer1-flow-node") <layer1-flow-node>
=== `flow-node`

The underlying shape for flowchart nodes.

When drawing flowcharts, you'll usually reach for these aliases instead:

- `process`
- `decision`
- `terminal`
- `junction`

But understanding `flow-node` helps when you need to customize a node shape.

#section-label[Most basic usage]

#example-pair(
  ```typst
  #flow-node(shape: "rect")[A]
  #flow-node(shape: "diamond", width: 70pt)[B?]
  #flow-node(shape: "stadium")[C]
  #flow-node(shape: "circle")[D]
  ```
,
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

#section-label[Common parameters]

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

#param-detail("shape", ("str",),
  default: raw("\"rect\"", lang: none))[
  Node shape. Common values: `rect`, `diamond`, `stadium`, `circle`.
]

#param-detail("status", ("none", "str"),
  default: raw("none", lang: none))[
  Semantic status color. Useful for quickly coloring error exits, warning nodes, success nodes.
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  Inside a flowchart container, this labels the arrow that points *into* this node.
]

#section-label[When to use it]

- You want to customize a flowchart node's shape
- You need a slightly lower-level entry than `process` / `decision`
- You want unified control over node styling

#section-label[More common entry points]

- Regular step: `process`
- Conditional branch: `decision`
- Start / end: `terminal`
- Small junction node: `junction`

#metadata("layer1-field-cell") <layer1-field-cell>
=== `field-cell`

A card describing one "field / property / type entry" — with the four corners holding *main name*, *badge*, *description*, and a *meta chip*.
The most common use is database schemas, API field tables, and type/configuration documentation.

Layout:

```text
┌───────────────────────────────┐
│ body                  [badge] │  body  · upper-left main name
│ desc                  [chip]  │  badge · upper-right small badge (e.g. ★ / ! / ?)
└───────────────────────────────┘  desc  · lower-left description
                                   chip  · lower-right meta info (often #raw("pill"))
```

All four slots are optional — empty ones don't reserve a blank line.

#section-label[Most basic usage]

#example-pair(
  ```typst
  #let blue = palettes.categorical.at(0)

  #field-cell(raw("user_id"),
    desc:  [User ID — internal account identifier],
    chip:  pill("string", accent: blue),
    accent: blue,
  )
  ```
,
  [
    #let blue = palettes.categorical.at(0)
    #field-cell(raw("user_id"),
      desc:  [User ID — internal account identifier],
      chip:  pill("string", accent: blue),
      accent: blue,
    )
  ],
)

#section-label[With a badge + emphasized border]

To attach a field to an external reference, add a `★` badge and let `emphasized: true` thicken the border:

#example-pair(
  ```typst
  #let orange = palettes.categorical.at(5)

  #field-cell(raw("product_type"),
    desc:  [Product type],
    badge: text(fill: orange.darken(35%), weight: "bold")[★],
    chip:  pill("ProductType", accent: orange),
    accent: orange,
    emphasized: true,
  )
  ```
,
  [
    #let orange = palettes.categorical.at(5)
    #field-cell(raw("product_type"),
      desc:  [Product type],
      badge: text(fill: orange.darken(35%), weight: "bold")[★],
      chip:  pill("ProductType", accent: orange),
      accent: orange,
      emphasized: true,
    )
  ],
)

#section-label[Common parameters]

#params-box("field-cell",
  ("body",       ("content",)),
  ("desc",       ("none", "content")),
  ("badge",      ("none", "content")),
  ("chip",       ("none", "content")),
  ("accent",     ("color",)),
  ("emphasized", ("bool",)),
  ("fill",       ("auto", "color")),
  ("stroke",     ("auto", "stroke")),
  ("body-fill",  ("auto", "color")),
  ("desc-size",  ("length", "ratio")),
  ("radius",     ("length",)),
  ("inset",      ("length", "dictionary")),
  ("width",      ("auto", "length", "ratio")),
  ("height",     ("auto", "length", "ratio")),
  ("gutter",     ("length",)),
  returns: "content",
)

#param-detail("accent", ("color",),
  default: raw("palettes.base.border-soft", lang: none))[
  Accent color used to derive `fill` (`accent.lighten(78%)`), `stroke`
  (`0.5pt + accent.darken(8%)`), and body text color (`accent.darken(45%)`).
  Pass `fill:` / `stroke:` / `body-fill:` to override any single derivation.
]

#param-detail("emphasized", ("bool",),
  default: raw("false", lang: none))[
  When enabled, the border gets heavier (`0.9pt + accent.darken(25%)`). Useful
  for cards like "this field links elsewhere" that need visual emphasis.
]

#section-label[When to use it]

- Database collection / table-structure diagrams
- API fields, type members, configuration entries at a glance
- Any "main name + meta info + description" card matrix

#metadata("layer1-pill") <layer1-pill>
=== `pill`

A filled mini-tag — the other form factor next to `badge`.

- *Use `pill`*: for "type tags / role markers / inline keywords", with color derived from a single `accent`
- *Use `badge`*: for "semantic status" (success / warning / danger / info / neutral), with outline + light background and dark text

Visual difference:

- `pill`: dark fill + white text + no stroke; looks like a *tag*
- `badge`: light fill + dark text + stroke; looks like a *status indicator*

The most common pairing for both is with `field-cell`: put a semantic status indicator into the `chip:` slot via `badge`, and a type/category marker (no status semantics) into `chip:` via `pill`.

The default `size: 0.78em` is one step smaller than body text to convey "secondary meta-info" hierarchy.

#section-label[Standalone use]

#example-pair(
  ```typst
  #pill("string")
  #pill("uint64", accent: rgb("#3b82f6"))
  ```
,
  [
    #pill("string")
    #h(4pt)
    #pill("uint64", accent: rgb("#3b82f6"))
  ],
)

#section-label[With `field-cell` (typical use)]

#example-pair(
  ```typst
  #let blue = palettes.categorical.at(0)

  #field-cell(raw("price"),
    desc:  [Price × 1000],
    chip:  pill("int", accent: blue),
    accent: blue,
  )
  ```
,
  [
    #let blue = palettes.categorical.at(0)
    #field-cell(raw("price"),
      desc:  [Price × 1000],
      chip:  pill("int", accent: blue),
      accent: blue,
    )
  ],
)

#section-label[Common parameters]

#params-box("pill",
  ("body",   ("content",)),
  ("accent", ("color",)),
  ("size",   ("length", "ratio")),
  returns: "content",
)

#metadata("layer1-brace") <layer1-brace>
=== `brace`

Adds a curly-brace range marker to a stretch of content.

Typical uses:

- "These fields belong to the same part"
- "These items together form one structure"
- "This stretch represents capacity, reserved space, or metadata"

#section-label[Most basic usage]

#example-pair(
  ```typst
  #box(width: 160pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[…]
    #brace(span: 160pt)[capacity]
  ]
  ```
,
  [
    #box(width: 160pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #note[…]
      #brace(span: 160pt)[capacity]
    ]
  ],
)

#section-label[Common parameters]

#params-box("brace",
  ("body",      ("content",)),
  ("span",      ("length",)),
  ("direction", ("str",)),
  returns: "content",
)

#param-detail("span", ("length",),
  default: raw("10em", lang: none))[
  Brace span. Width when horizontal, height when vertical.
]

#param-detail("direction", ("str",),
  default: raw("\"down\"", lang: none))[
  Brace direction:
  - `down`: horizontal, label below
  - `up`: horizontal, label above
  - `right`: vertical, label on the right
  - `left`: vertical, label on the left
]

#section-label[More directions]

#example-pair(
  ```typst
  #brace(span: 120pt)[payload]
  #brace(direction: "up", span: 120pt)[header]
  #brace(direction: "right", span: 60pt)[body]
  ```
,
  [
    #brace(span: 120pt)[payload]
    #h(10pt)
    #brace(direction: "up", span: 120pt)[header]
    #h(10pt)
    #brace(direction: "right", span: 60pt)[body]
  ],
)

#section-label[When to use it]

- You want to mark a whole stretch
- You need a stronger range hint than `span-label` provides
- You're drawing protocol headers, array capacity, or grouped fields

== Chapter summary

If you only want to remember the most-used atoms, focus on these:

- `cell`: the most basic block
- `badge`: a compact status marker
- `sub-label`: field-size annotations
- `edge`: simple connections
- `wrap`: an extra emphasized border

Next up: if you want to organize multiple atoms into a whole, continue to the next chapter — *Layer 2 — Containers*.
