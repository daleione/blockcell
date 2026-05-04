#import "../../lib.typ": *
#import "../style.typ": *

= Common patterns <patterns>

This chapter isn't organized by API layer — it's organized by "what are you trying to draw right now?".
If you already know what you want to draw but aren't sure where to start, this is the right place.

== Recommended learning path <patterns-learning-path>

If this is your first time using *blockcell*, we suggest learning in this order:

1. `cell`: draw a single block first
2. `region`: combine multiple blocks into one structure
3. `schema`: add a title and caption to a structure
4. `linked-schema`: express "field region + target region"
5. Pick a topical chapter for your scenario:
   - Flowcharts: see "Flowcharts"
   - State machines: see "State transition diagrams"
   - Hierarchies: see "Hierarchical tree diagrams"
   - Participant interactions: see "Sequence diagrams"

== Pick the right component <patterns-choose-components>

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (160pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[Just one block],
      [Use #api-ref("layer1-cell", "cell"). Good for fields, status blocks, label blocks, single nodes.],
      text(weight: "bold")[Wrap several blocks into one],
      [Use #api-ref("layer2-region", "region"). Good for structs, field groups, logical regions.],
      text(weight: "bold")[Add a title and caption],
      [Use #api-ref("layer3-schema", "schema"). Good for showing a structure as a standalone diagram.],
      text(weight: "bold")[Express "pointer / ref → target"],
      [Use #api-ref("layer3-linked-schema", "linked-schema"). Good for heap objects, references, layered structures.],
      text(weight: "bold")[Fixed-width fields],
      [Use #api-ref("layer3-bit-row", "bit-row"). Good for protocol headers, registers, bit-field layouts.],
      text(weight: "bold")[Linear flow],
      [Use #api-ref("flows-flow-col", "flow-col"). For branches, combine with #api-ref("flows-branch", "branch"), #api-ref("flows-switch", "switch"), #api-ref("flows-flow-loop", "flow-loop").],
      text(weight: "bold")[State transitions],
      [Use #api-ref("states-state-chain", "state-chain"). Both simple chains and complex state machines start here.],
      text(weight: "bold")[Hierarchies],
      [Use #api-ref("tree-tree", "tree"). Good for directory trees, org charts, JSON hierarchies.],
      text(weight: "bold")[Participant interactions],
      [Use #api-ref("layer3-seq-lane", "seq-lane"). Good for request chains, protocol exchanges, service calls.],
    )
  ]
]

== Start from the smallest combination <patterns-start-small>

Many diagrams build up from these three layers:

- `cell`: a single element
- `region`: a group of elements
- `schema`: a complete diagram block

#section-label[Minimal structure diagram]

#example-pair(
  ```typst
  #schema(title: [User])[
    #region[
      #cell[id]
      #cell[name]
      #cell[email]
    ]
  ]
  ```,
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

This combination fits most "structure-explanation" diagrams:

- Data structures
- Configuration blocks
- Module boundaries
- Simple intent-conveying blocks

== Reuse colors <patterns-colors>

Prefer the built-in palettes over hand-written colors scattered around the document.

#section-label[Use a built-in palette directly]

#example-pair(
  ```typst
  #let C = palettes.pastel

  #cell(fill: C.blue)[Inbox]
  #cell(fill: C.green)[Done]
  #cell(fill: C.yellow)[Pending]
  ```,
  [
    #let C = palettes.pastel
    #cell(fill: C.blue)[Inbox]
    #h(4pt)
    #cell(fill: C.green)[Done]
    #h(4pt)
    #cell(fill: C.yellow)[Pending]
  ],
)

A few good defaults:

- Use `palettes.pastel` for general-purpose coloring
- Use `palettes.status` for success / warning / error
- Use `palettes.categorical` to assign distinct colors to multiple groups
- Use a domain palette to start a real-world scenario diagram quickly

#section-label[Semantic status colors]

#example-pair(
  ```typst
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]
  ```,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
  ],
)

If you want to reuse the same status colors with other components, just spread them in:

#example-pair(
  ```typst
  #cell(..palettes.status.info)[Queued]
  #cell(..palettes.status.danger)[Failed]
  ```,
  [
    #cell(..palettes.status.info)[Queued]
    #h(6pt)
    #cell(..palettes.status.danger)[Failed]
  ],
)

== Define your own color aliases <patterns-custom-colors>

When the same group of colors keeps appearing in one diagram, give it a short alias. The code gets shorter, and a single edit re-tunes the whole figure.

#example-pair(
  ```typst
  #let C = (
    header: rgb("#BBDEFB"),
    meta: rgb("#B2DFDB"),
    flag: rgb("#FFE082"),
    data: rgb("#FFCCBC"),
  )

  #cell(fill: C.header)[Header]
  #cell(fill: C.meta)[Length]
  #cell(fill: C.flag)[Flags]
  ```,
  [
    #let C = (
      header: rgb("#BBDEFB"),
      meta: rgb("#B2DFDB"),
      flag: rgb("#FFE082"),
      data: rgb("#FFCCBC"),
    )

    #cell(fill: C.header)[Header]
    #h(4pt)
    #cell(fill: C.meta)[Length]
    #h(4pt)
    #cell(fill: C.flag)[Flags]
  ],
)

Suggestions:

- Use `#let C = ...` inside a single diagram
- Name colors by semantics, not by appearance
- Let colors serve structure first; decorate only after

== Reduce repetition with `.with()` <patterns-with>

When you keep writing the same set of arguments, lock them in with `.with()`.

#section-label[Fix sizing]

#example-pair(
  ```typst
  #let mc = cell.with(
    width: 28pt,
    height: 20pt,
    inset: 2pt,
  )

  #mc[03] #mc[21] #mc[7F] #mc[A0]
  ```,
  [
    #let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
    #mc[03] #mc[21] #mc[7F] #mc[A0]
  ],
)

This is a good fit for:

- Memory byte cells
- Cache lines
- Register fields
- Small fixed-size cells

#section-label[Fix a common parameter set]

#example-pair(
  ```typst
  #let field = cell.with(
    width: 44pt,
    height: 24pt,
    fill: palettes.pastel.blue,
  )

  #field[id] #field[len] #field[cap]
  ```,
  [
    #let field = cell.with(
      width: 44pt,
      height: 24pt,
      fill: palettes.pastel.blue,
    )
    #field[id] #field[len] #field[cap]
  ],
)

Rules of thumb:

- Use `.with()` to fix sizing, spacing, default colors
- If you want to convey a clearer business meaning, wrap it again with your own function name

== Name the structures you reuse <patterns-helpers>

When the same combination shows up repeatedly across the document, define a small helper.

#example-pair(
  ```typst
  #let ptr-field(body) = cell(
    fill: palettes.rust.ptr,
  )[#body#sub-label[2/4/8]]

  #ptr-field[ptr]
  ```,
  [
    #let ptr-field(body) = cell(
      fill: palettes.rust.ptr,
    )[#body#sub-label[2/4/8]]

    #ptr-field[ptr]
  ],
)

Why bother:

- Clearer semantics
- Shorter code
- Easier global restyling later

== Place several diagrams side by side <patterns-side-by-side>

When comparing structures, write multiple `schema`s right next to each other.

#section-label[Side-by-side comparison]

#wide-example(
  ```typst
  #schema(title: [A])[
    #region[#cell[x]]
  ]#schema(title: [B])[
    #region[#cell[y]]
  ]#schema(title: [C])[
    #region[#cell[z]]
  ]
  ```,
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

If a block ends up too wide, set `width:` so the title, caption, and body all stay within a sensible bound.

#section-label[Constrain block width]

#example-pair(
  ```typst
  #linked-schema(
    width: 160pt,
    title: [Box<T>],
    desc: [A longer description will wrap here automatically.],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
    ),
    cell(fill: palettes.rust.any)[T],
  )
  ```,
  [
    #linked-schema(
      width: 160pt,
      title: [Box<T>],
      desc: [A longer description will wrap here automatically.],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
      ),
      cell(fill: palettes.rust.any)[T],
    )
  ],
)

== Common combinations for structure diagrams <patterns-common-combos>

These combinations are the most common — and the most worth learning early.

#section-label[`cell` + `region`]

For: field groups, structs, logical blocks

#example-pair(
  ```typst
  #region[
    #cell[id]
    #cell[len]
    #cell[cap]
  ]
  ```,
  [
    #region[
      #cell[id]
      #cell[len]
      #cell[cap]
    ]
  ],
)

#section-label[`schema` + `region`]

For: presenting a structure as a standalone unit

#example-pair(
  ```typst
  #schema(title: [Vec<T>])[
    #region[
      #cell[ptr]
      #cell[len]
      #cell[cap]
    ]
  ]
  ```,
  [
    #schema(title: [Vec<T>])[
      #region[
        #cell[ptr]
        #cell[len]
        #cell[cap]
      ]
    ]
  ],
)

#section-label[`linked-schema`]

For: references, heap objects, layered structures

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
  ```,
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

== Jump to topical chapters by task <patterns-by-task>

If you already know what you want to draw, take a direct path:

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (130pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[Flowchart],
      [Start with #api-ref("flows-flow-col", "flow-col"); for conditional branches see #api-ref("flows-branch", "branch") / #api-ref("flows-branch-merge", "branch-merge") / #api-ref("flows-switch", "switch"); for loops see #api-ref("flows-flow-loop", "flow-loop").],
      text(weight: "bold")[State machine],
      [Start with #api-ref("states-state-chain", "state-chain"); use auto layout for simple chains, then 2D mode for complex topologies.],
      text(weight: "bold")[Tree],
      [Start with #api-ref("tree-tree", "tree"); nodes usually use #api-ref("tree-node", "node"), but you can also drop in #api-ref("layer1-cell", "cell"), #api-ref("flows-process", "process"), etc.],
      text(weight: "bold")[Sequence diagram],
      [Start with #api-ref("layer3-seq-lane", "seq-lane"); learn #api-ref("seq-seq-call", "seq-call"), #api-ref("seq-seq-ret", "seq-ret"), #api-ref("seq-seq-note", "seq-note") first, then fragments and autonumbering.],
      text(weight: "bold")[Headers / bit fields],
      [Start with #api-ref("layer3-bit-row", "bit-row"); get one row right first, then assemble a full header.],
    )
  ]
]

== When to extract a helper <patterns-when-helper>

Extract a helper when any of these is true:

- The same parameter set appears 3+ times
- The same color semantic appears repeatedly
- The same structural combination appears repeatedly
- You want names in the diagram that match your domain

A simple rule:

- When the repetition is *style*, use `.with()`
- When the repetition is *semantic composition*, define your own function

== Tips for keeping diagrams simple <patterns-keep-simple>

To keep diagrams stable and maintainable, prefer these habits:

- Use the fewest components needed to express the structure
- One diagram, one main point
- Let colors carry grouping and semantic meaning first; don't introduce too many at once
- Put complex cases under `examples/`; keep inline figures minimal
- Reuse existing helpers before adding new ones

== Where to go next <patterns-next>

- Want the full component reference: continue with the Layer 1 / 2 / 3 chapters
- Want real-world examples: see "Worked examples" and `examples/`
- Want to draw flowcharts, state machines, trees, or sequence diagrams: jump straight to the matching topical chapter
