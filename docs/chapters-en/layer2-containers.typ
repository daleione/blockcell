#import "../../lib.typ": *
#import "../style.typ": *

== Layer 2 — Containers <layer2>

This chapter covers the most-used containers — the components you reach for when you need to organize multiple primitives into one whole.

If #api-ref("layer1-cell", "cell") in Layer 1 is "a single block", then this chapter answers questions like:

- How do I wrap several blocks into one structure?
- How do I express "this region points to that region"?
- How do I stack a few stretches of content vertically?
- How do I add a title, caption, or grouping border to a set of items?

If this is your first time, focus on these first:

1. #api-ref("layer2-region", "region")
2. #api-ref("layer2-target", "target")
3. #api-ref("layer2-connector", "connector")
4. #api-ref("layer2-stack", "stack")
5. #api-ref("layer2-group", "group")

=== `region` <layer2-region>

The most-used container — wraps multiple pieces of content into a single whole.

Typical scenarios:

- Struct field groups
- Module boundaries
- A logical region
- A group of items that should share a uniform background and border

#section-label[Simplest form]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
    #cell(fill: palettes.pastel.cyan)[cap]
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.cyan)[len]
      #cell(fill: palettes.pastel.cyan)[cap]
    ]
  ],
)

#section-label[Common parameters]

#params-box("region",
  ("body",          ("content",)),
  ("fill",          ("color",)),
  ("stroke",        ("stroke",)),
  ("dash",          ("none", "str")),
  ("radius",        ("length",)),
  ("width",         ("auto", "length")),
  ("content-align", ("alignment",)),
  ("label",         ("none", "str", "content")),
  ("danger",        ("bool",)),
  ("faded",         ("bool",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Container background color. Most often you give the whole group a softer background than the inner `cell`s.
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  Container border style. Thicken or recolor it when you need a more pronounced boundary.
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  Border line style. Common values: `none`, `"dashed"`, `"dotted"`.
]

#param-detail("radius", ("length",),
  default: raw("4pt", lang: none))[
  Corner radius.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Container width. Set explicitly when multiple blocks need to align.
]

#param-detail("content-align", ("alignment",),
  default: raw("center", lang: none))[
  Alignment of inner content.
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  Lower-right corner label. Good for `(heap)`, `(stack)`, `(shared)` and similar hints.
]

#param-detail("danger", ("bool",),
  default: raw("false", lang: none))[
  Apply a stronger "danger" style to emphasize this region. Good for errors, out-of-bounds, restricted access, or high-risk regions.
]

#param-detail("faded", ("bool",),
  default: raw("false", lang: none))[
  Apply a softer style to indicate the region is missing, a placeholder, zero-sized, or no longer valid.
]

#section-label[Common usage]

#example-pair(
  ```typst
  #region(
    fill: palettes.pastel.yellow,
    label: "(heap)",
  )[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.green)[len]
  ]
  ```
,
  [
    #region(
      fill: palettes.pastel.yellow,
      label: "(heap)",
    )[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.green)[len]
    ]
  ],
)

#section-label[State variants]

#align(center)[
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
  ]
  #h(12pt)
  #region(danger: true)[
    #cell(fill: palettes.pastel.red)[unsafe]
    #cell(fill: palettes.pastel.orange)[meta]
  ]
  #h(12pt)
  #region(faded: true, width: 56pt)[]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  Normal #h(42pt) `danger: true` #h(24pt) `faded: true`
])

#section-label[When to use it]

- You want to wrap several elements into one whole
- You need a clear structural boundary
- You want a uniform background and border for a group
- You're drawing structure diagrams, module diagrams, field groups

#section-label[Often paired with]

- `cell` to form a structure block
- `schema` to form a complete diagram block
- `connector` and `target` to express references
- `detail` to add a caption

=== `target` <layer2-target>

For "the region being pointed at" or "target region".

Typical uses:

- A heap object
- An external storage region
- Referenced content
- A lower-layer structure
- A target resource

Usually paired with `connector`.

#section-label[Simplest form]

#example-pair(
  ```typst
  #target(fill: palettes.pastel.blue, label: "(heap)", width: 120pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #target(fill: palettes.pastel.blue, label: "(heap)", width: 120pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[Common parameters]

#params-box("target",
  ("body",  ("content",)),
  ("fill",  ("color",)),
  ("label", ("none", "str", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("rgb(\"#FDECDC\")", lang: none))[
  Target region background color. Usually a soft, light tone.
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  Lower-right corner label. Common choices: `(heap)`, `(static)`, `(shared)`.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Target region width. Set explicitly when it needs to align with the structure above.
]

#section-label[When to use it]

- You want to convey "this is the content being pointed at"
- You're drawing pointers, references, heap objects
- You need to visually separate the main structure from its target

#section-label[Often paired with]

- `connector` to attach to the structure above
- `linked-schema` to express "field region → target region"
- `cell` to populate fields inside the target

=== `connector` <layer2-connector>

A simple vertical line connecting an upper structure to a lower target region.

Most common uses:

- `region` to `target`
- An upper structure to a lower structure
- A field region to a target region

#section-label[Simplest form]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
  ]
  #connector()
  #target[
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
    ]
    #connector()
    #target[
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[Common parameters]

#params-box("connector",
  ("length", ("length",)),
  ("stroke", ("stroke",)),
  returns: "content",
)

#param-detail("length", ("length",),
  default: raw("8pt", lang: none))[
  Connector length. Adjust for tighter or looser vertical spacing.
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  Connector stroke. Use color or weight to convey different meanings.
]

#section-label[When to use it]

- You only need a simple top-down link
- You're expressing "the structure above points at the target below"
- You don't need complex freeform routing

=== `divider` <layer2-divider>

Separates two or more mutually exclusive layouts.

Typical scenarios:

- Enum variants
- Mutually exclusive structures
- Two alternative options
- "A or B" style explanations

#section-label[Simplest form]

#example-pair(
  ```typst
  #region(fill: palettes.pastel.yellow)[
    #tag[Tag] #cell(fill: palettes.pastel.red)[A]
  ]
  #divider(body: [exclusive or])
  #region(fill: palettes.pastel.yellow)[
    #tag[Tag] #cell(fill: palettes.pastel.red)[B]
  ]
  ```
,
  [
    #region(fill: palettes.pastel.yellow)[
      #tag[Tag] #cell(fill: palettes.pastel.red)[A]
    ]
    #divider(body: [exclusive or])
    #region(fill: palettes.pastel.yellow)[
      #tag[Tag] #cell(fill: palettes.pastel.red)[B]
    ]
  ],
)

#section-label[Common parameters]

#params-box("divider",
  ("body", ("content",)),
  returns: "content",
)

#section-label[When to use it]

- You want to make "these two layouts cannot occur simultaneously" explicit
- You're drawing enums, branching structures, or alternatives
- You need a clearer separator than plain text

=== `detail` <layer2-detail>

Adds a single-line caption below a region.

Typical scenarios:

- Explain what the region does
- Add an implementation or runtime hint
- Tack a short note onto a structure diagram

#section-label[Simplest form]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
  ]
  #detail[
    Runtime borrow count tracked here.
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.cyan)[len]
    ]
    #detail[
      Runtime borrow count tracked here.
    ]
  ],
)

#section-label[Common parameters]

#params-box("detail",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Caption-bar background. Keep it soft so it doesn't steal focus from the main structure.
]

#section-label[When to use it]

- You want to tack a short caption onto a region
- The caption should sit next to the structure, not as separate prose
- You want the diagram itself to be self-explanatory

=== `entry-list` <layer2-entry-list>

Displays a column of entries.

Typical scenarios:

- vtables
- Function tables
- Register entries
- Fixed-order list-like structures

#section-label[Simplest form]

#example-pair(
  ```typst
  #entry-list(
    label: "(vtable)",
    (
      [drop],
      [size],
      [align],
      [call],
    ),
  )
  ```
,
  [
    #entry-list(
      label: "(vtable)",
      (
        [drop],
        [size],
        [align],
        [call],
      ),
    )
  ],
)

#section-label[Common parameters]

#params-box("entry-list",
  ("entries", ("array",)),
  ("fill",    ("color",)),
  ("label",   ("none", "str", "content")),
  ("width",   ("auto", "length")),
  returns: "content",
)

#param-detail("entries", ("array",))[
  Entry array. Each item is content, rendered top-to-bottom in order.
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Entry-region background.
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  Lower-right corner label. Good for `(vtable)`, `(table)`, `(map)`.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Overall width. Set explicitly when it needs to align with other structures.
]

#section-label[When to use it]

- You want to express a column of fixed-order items
- You need a tighter list structure than several stacked `cell`s
- You're drawing table entries, function tables, or maps

=== `stack` <layer2-stack>

The simplest vertical stack container.

Typical scenarios:

- Stack multiple diagram blocks vertically
- Build hierarchical structures
- Avoid scattering many `#v(...)` calls
- Keep multiple independent blocks at uniform spacing

#section-label[Simplest form]

#example-pair(
  ```typst
  #stack(
    [#region(width: 100pt)[L1]],
    [#region(width: 140pt)[L2]],
    [#region(width: 180pt)[L3]],
  )
  ```
,
  [
    #stack(
      [#region(fill: palettes.pastel.blue.lighten(40%), width: 100pt)[
        #text(weight: "bold")[L1]
      ]],
      [#region(fill: palettes.pastel.cyan.lighten(40%), width: 140pt)[
        #text(weight: "bold")[L2]
      ]],
      [#region(fill: palettes.pastel.teal.lighten(40%), width: 180pt)[
        #text(weight: "bold")[L3]
      ]],
    )
  ],
)

#section-label[Common parameters]

#params-box("stack",
  ("..items", ("content",)),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("content",))[
  Items to stack vertically.
]

#param-detail("gap", ("length",),
  default: raw("6pt", lang: none))[
  Vertical spacing between items.
]

#param-detail("align", ("alignment",),
  default: raw("center", lang: none))[
  Alignment of stacked content.
]

#section-label[When to use it]

- You want to stack multiple blocks vertically
- You need something more stable than scattering `#v(...)`
- You're drawing cache hierarchies, layered structures, layer-by-layer expansions

#section-label[Often paired with]

- `region` to build hierarchical structures
- `group` to form larger groupings
- `section` to assemble complete card content

=== `group` <layer2-group>

Adds a more explicit grouping border and a title to a set of items.

Typical scenarios:

- Logical module groupings
- Subsystem boundaries
- Multiple related blocks at the same hierarchical level
- A grouping frame that needs a title

It fits "wrap multiple independent sub-blocks together" better than `region`, which is for a single structural unit.

#section-label[Simplest form]

#example-pair(
  ```typst
  #group(label: [Business layer], fill: palettes.categorical.at(1).lighten(42%))[
    #region(fill: palettes.categorical.at(1))[Owned platform]
    #v(3pt)
    #region(fill: palettes.categorical.at(1).lighten(10%))[External sync]
  ]
  ```
,
  [
    #group(
      label: [Business layer],
      fill: palettes.categorical.at(1).lighten(42%),
      width: 100%,
    )[
      #region(fill: palettes.categorical.at(1), width: 100%)[
        #text(weight: "bold", size: 0.85em)[Owned platform]
      ]
      #v(3pt)
      #region(fill: palettes.categorical.at(1).lighten(10%), width: 100%)[
        #text(weight: "bold", size: 0.85em)[External sync]
      ]
    ]
  ],
)

#section-label[Common parameters]

#params-box("group",
  ("body",          ("content",)),
  ("label",         ("none", "content")),
  ("fill",          ("color",)),
  ("stroke",        ("stroke",)),
  ("dash",          ("none", "str")),
  ("radius",        ("length",)),
  ("width",         ("auto", "length")),
  ("inset",         ("length",)),
  ("content-align", ("alignment",)),
  returns: "content",
)

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  Upper-left title. Good for module names, layer names, group names.
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  Group background. Usually lighter than the inner blocks.
]

#param-detail("stroke", ("stroke",),
  default: raw("0.5pt + palettes.base.border-soft", lang: none))[
  Group border style.
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  Border line style. A dashed border usually indicates a softer logical boundary.
]

#param-detail("radius", ("length",),
  default: raw("6pt", lang: none))[
  Corner radius.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Group width.
]

#param-detail("inset", ("length",),
  default: raw("10pt", lang: none))[
  Spacing between the group border and the inner content.
]

#param-detail("content-align", ("alignment",),
  default: raw("center", lang: none))[
  Alignment of inner content.
]

#section-label[When to use it]

- You want to group multiple independent blocks under one logical heading
- You need a titled grouping border
- You're drawing system layers, module boundaries, or business-domain groupings

#section-label[Often paired with]

- `region` to form multi-layer structures
- `stack` for vertical groupings
- `section` for fuller document-level cards

#section-label[Nested groups]

#example-pair(
  ```typst
  #group(label: [System], fill: palettes.pastel.blue.lighten(45%))[
    #group(label: [Business], fill: palettes.pastel.green.lighten(40%))[
      #region[Service A]
      #v(3pt)
      #region[Service B]
    ]
  ]
  ```
,
  [
    #group(label: [System], fill: palettes.pastel.blue.lighten(45%), width: 100%)[
      #group(label: [Business], fill: palettes.pastel.green.lighten(40%), width: 100%)[
        #region(width: 100%)[Service A]
        #v(3pt)
        #region(width: 100%)[Service B]
      ]
    ]
  ],
)

== Chapter summary <layer2-summary>

If you only want to remember the most-used containers, focus on these:

- `region`: the most-used structural container
- `target`: the region being pointed at
- `connector`: top-down connection line
- `stack`: vertical stack
- `group`: titled logical grouping

Next up: if you want to use full diagram patterns directly, continue to *Layer 3 — Composites*.
