#import "../../lib.typ": *
#import "../style.typ": *

= Palettes <palettes>

`blockcell` ships with a set of ready-to-use palettes that help you give your diagrams a stable, clear visual hierarchy.

The recommended use is simple:

- For "success / warning / error"-style semantic colors, use `palettes.status`
- For a soft, general-purpose color set, use `palettes.pastel`
- To assign distinct colors to multiple categories, use `palettes.categorical`
- For intensity / rank / depth, use `palettes.sequential`
- To reuse the example domain palettes directly, use `palettes.rust`, `palettes.network`, `palettes.cache`

== How to choose <palettes-choose>

#align(center)[
  #region(fill: rgb("#F8FAFC"), width: 100%)[
    #grid(
      columns: (130pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[What you express], text(weight: "bold")[Recommended palette],
      [Status], [`palettes.status` — success, warning, danger, info, neutral],
      [General coloring], [`palettes.pastel` — soft, stable, fits most structure diagrams],
      [Multiple categories], [`palettes.categorical` — distinct color per group],
      [Intensity / rank], [`palettes.sequential` — same hue, light to dark],
      [Domain examples], [`palettes.rust` / `palettes.network` / `palettes.cache`],
    )
  ]
]

== `palettes.status` <palettes-status>

For semantic statuses. Best for:

- Success / failure
- Hit / miss
- Normal / warning / error
- Done / waiting / skipped

If a component supports a `status:` parameter, prefer `status:` directly.
If you want to reuse the same palette on `cell`, `region`, etc., spread it in.

#section-label[Example]

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]

  #cell(..palettes.status.info)[Info]
  ```
  ,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
    #h(10pt)
    #cell(..palettes.status.info)[Info]
  ],
)

#section-label[Keys]

#align(center)[
  #badge(status: "success")[SUCCESS]
  #h(4pt)
  #badge(status: "warning")[WARNING]
  #h(4pt)
  #badge(status: "danger")[DANGER]
  #h(4pt)
  #badge(status: "info")[INFO]
  #h(4pt)
  #badge(status: "neutral")[NEUTRAL]
]

#grid(
  columns: (80pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`success`], [Success, pass, hit, completed],
  text(weight: "bold")[`warning`], [Warning, waiting, degraded, deferred],
  text(weight: "bold")[`danger`], [Failure, error, rejected, miss],
  text(weight: "bold")[`info`], [Hint, note, general information],
  text(weight: "bold")[`neutral`], [Neutral, skipped, pending, placeholder],
)

#section-label[When to use]

- You want color to carry semantics, not just decoration
- You want consistent status colors across diagrams
- You want to reduce hand-written `fill` / `stroke`

#entry-title("palettes.pastel", kind: "Constant", anchor: "palettes-pastel")

A general-purpose set of soft colors. Suitable for most structure, explanatory, and illustrative diagrams.

If you just want "comfortable, stable colors for different blocks", this is usually enough.

#section-label[Example]

#example-pair(
  ```typ
  #let C = palettes.pastel

  #cell(fill: C.blue)[API]
  #cell(fill: C.green)[Worker]
  #cell(fill: C.orange)[Queue]
  ```
  ,
  [
    #let C = palettes.pastel
    #cell(fill: C.blue)[API]
    #h(4pt)
    #cell(fill: C.green)[Worker]
    #h(4pt)
    #cell(fill: C.orange)[Queue]
  ],
)

#section-label[Keys]

#align(center)[
  #let swatch(name) = cell(
    fill: palettes.pastel.at(name),
    width: 38pt,
    height: 24pt,
  )[
    #text(size: 0.72em)[#name]
  ]
  #swatch("red")
  #swatch("pink")
  #swatch("purple")
  #swatch("indigo")
  #swatch("blue")
  #swatch("cyan")
  #swatch("teal")
  #swatch("green")
  #swatch("lime")
  #swatch("yellow")
  #swatch("orange")
  #swatch("brown")
  #swatch("gray")
]

#section-label[When to use]

- Memory layouts, structure diagrams, module diagrams, explanatory figures
- You need multiple colors but don't want them too punchy
- You don't yet have a domain palette and want to ship a figure quickly

#entry-title("palettes.categorical", kind: "Constant", anchor: "palettes-categorical")

A set of mutually distinguishable colors, suitable for multiple categories, roles, or groups.

It's an array; use `.at(i)` to pick a color.

#section-label[Example]

#example-pair(
  ```typ
  #for (i, label) in
    ([API], [DB], [Cache], [Queue]).enumerate() {
    cell(fill: palettes.categorical.at(i))[#label]
  }
  ```
  ,
  [
    #for (i, label) in ([API], [DB], [Cache], [Queue]).enumerate() {
      cell(fill: palettes.categorical.at(i))[#label]
    }
  ],
)

#section-label[Swatches]

#align(center)[
  #for (i, label) in (
    [A], [B], [C], [D], [E], [F], [G], [H],
  ).enumerate() {
    cell(fill: palettes.categorical.at(i), width: 34pt, height: 22pt)[
      #text(size: 0.8em)[#label]
    ]
  }
]

#section-label[When to use]

- Legends
- Multiple services / modules / roles
- Several branches or categories side by side
- "One distinct color per group"

#section-label[Tip]

If the number of categories is small, `categorical` is usually more stable than hand-picking colors.

#entry-title("palettes.sequential", kind: "Constant", anchor: "palettes-sequential")

Same-hue intensity ramps, suitable for:

- Rank
- Intensity
- Heat
- Priority
- Numeric scale low-to-high

Each ramp is ordered "light → dark".

#section-label[Example]

#example-pair(
  ```typ
  #for lvl in range(5) {
    cell(fill: palettes.sequential.blue.at(lvl))[L#lvl]
  }
  ```
  ,
  [
    #for lvl in range(5) {
      cell(fill: palettes.sequential.blue.at(lvl))[L#lvl]
    }
  ],
)

#section-label[Ramps]

#align(center)[
  #grid(
    columns: (auto, auto),
    column-gutter: 8pt,
    row-gutter: 4pt,
    align: (right + horizon, left + horizon),
    ..(for hue in ("blue", "green", "orange", "purple", "gray") {
      (
        text(size: 0.85em, weight: "bold")[#hue],
        {
          for lvl in range(5) {
            cell(
              fill: palettes.sequential.at(hue).at(lvl),
              width: 38pt,
              height: 22pt,
            )[
              #text(
                size: 0.78em,
                fill: if lvl < 2 { black } else { white },
                weight: "bold",
              )[L#lvl]
            ]
          }
        },
      )
    })
  )
]

#section-label[When to use]

- Importance tiers in protocol fields
- Risk level, priority, heat
- Light / heavy distinctions among the same kind of object
- "Same group, different intensity"

#entry-title("palettes.rust / network / cache", kind: "Constant", anchor: "palettes-domain")

These three are the domain palettes used in the examples.
If your diagram is close to one of these scenarios, reuse it directly. Otherwise, copy it and adjust as needed.

#section-label[Overview]

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[`palettes.rust`],
  text(weight: "bold", size: 0.9em)[`palettes.network`],
  text(weight: "bold", size: 0.9em)[`palettes.cache`],
  text(size: 0.8em)[Rust memory layout, pointers, heap objects, enums],
  text(size: 0.8em)[Protocol headers, network layers, addresses, flags, checksums],
  text(size: 0.8em)[Cache hierarchy, memory, MESI states, data blocks],
)

#section-label[Example]

#example-pair(
  ```typ
  #let R = palettes.rust
  #let N = palettes.network
  #let K = palettes.cache

  #cell(fill: R.ptr)[ptr]
  #cell(fill: N.flag)[Flags]
  #cell(fill: K.shared)[Shared]
  ```
  ,
  [
    #let R = palettes.rust
    #let N = palettes.network
    #let K = palettes.cache
    #cell(fill: R.ptr)[ptr]
    #h(4pt)
    #cell(fill: N.flag)[Flags]
    #h(4pt)
    #cell(fill: K.shared)[Shared]
  ],
)

#section-label[When to use]

- Your diagram is close to one of the official example scenarios
- You want a vetted domain palette quickly
- You want similar diagrams across the project to share a consistent style

== Common usages <palettes-common-usage>

== 1. Pass `fill` to a component directly

#example-pair(
  ```typ
  #cell(fill: palettes.pastel.blue)[API]
  #region(fill: palettes.pastel.green)[...]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[API]
    #h(6pt)
    #region(fill: palettes.pastel.green)[...]
  ],
)

== 2. Reduce repetition with a short alias

#example-pair(
  ```typ
  #let C = palettes.pastel

  #cell(fill: C.blue)[A]
  #cell(fill: C.green)[B]
  #cell(fill: C.orange)[C]
  ```
,
  [
    #let C = palettes.pastel

    #cell(fill: C.blue)[A]
    #h(4pt)
    #cell(fill: C.green)[B]
    #h(4pt)
    #cell(fill: C.orange)[C]
  ],
)

== 3. Express semantic state with `status:`

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #terminal(status: "danger")[Exit]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(8pt)
    #terminal(status: "danger")[Exit]
  ],
)

== 4. Spread status colors into other components

#example-pair(
  ```typ
  #cell(..palettes.status.warning)[Retry]
  #region(..palettes.status.info)[Pending]
  ```
,
  [
    #cell(..palettes.status.warning)[Retry]
    #h(8pt)
    #region(..palettes.status.info)[Pending]
  ],
)

== 5. Add a custom color on top of an existing palette

#example-pair(
  ```typ
  #let C = (..palettes.pastel, accent: rgb("#FF6F00"))

  #cell(fill: C.accent)[Highlight]
  ```
,
  [
    #let C = (..palettes.pastel, accent: rgb("#FF6F00"))

    #cell(fill: C.accent)[Highlight]
  ],
)

== Tips <palettes-tips>

- Keep color semantics consistent within a single diagram
- Don't change colors per block "for variety"
- If color is already carrying status, don't make it carry an unrelated meaning at the same time
- When in doubt, start with `pastel`; switch to `status` when you need clear semantics

== Where to go next <palettes-next>

- To see how to reuse palettes with `.with()`: continue with "Common patterns"
- For full scenario examples: continue with "Worked examples"
