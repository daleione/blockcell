#import "../../lib.typ": *
#import "../style.typ": *

= Introduction <intro>

*blockcell* is a block-style diagram library for Typst. You can use it to quickly produce structurally clear, visually consistent diagrams, such as:

- Data structures and memory layouts
- Protocol headers and bit fields
- Layered architectures and module relationships
- Flowcharts and state diagrams
- Sequence diagrams and hierarchical trees

Its focus is not freeform drawing, but expressing common technical diagrams as stable, reusable Typst code via a set of composable components.

== What it's good for <intro-fit>

`blockcell` is a good fit if you want diagrams that satisfy these properties:

- Built from blocks, containers, groups, and connections
- Structurally clear and easy to maintain over time in your documents
- Visually consistent across many figures
- Composed from small components, rather than hand-placing coordinates

Common uses include:

- Memory layouts and structure diagrams with #doc-link("layer1-cell")[`cell`], #doc-link("layer2-region")[`region`], and #doc-link("layer3-schema")[`schema`]
- Protocol headers, registers, and bit fields with #doc-link("layer3-bit-row")[`bit-row`]
- Business and processing flows with #doc-link("flows-flow-col")[`flow-col`]
- State transitions with #doc-link("states-state-chain")[`state-chain`]
- Directory trees, organizational charts, and hierarchies with #doc-link("tree-tree")[`tree`]
- Interactions between participants with #doc-link("layer3-seq-lane")[`seq-lane`]

== What it's not good for <intro-not-fit>

`blockcell` is built for structured diagrams; it's not the right tool for every drawing task.

If you need:

- Free placement at arbitrary coordinates
- Complex freeform routing
- Lots of cross-region connections
- More of a "canvas-style" 2D topology

then a dedicated drawing library is a better fit.
Think of `blockcell` as a "structured-diagram component library", not a general-purpose drawing engine — picking the right tool gets easier from there.

== Installation <intro-install>

If you're using the published package, import it in your document:

```typst
#import "@preview/blockcell:0.1.0": *
```

If you're browsing the in-repo examples, the example files typically import the local source via a relative path.

#section-label[Minimal smoke test after import]

#example-pair(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #cell[Loaded]
  ```
,
  [
    #cell[Loaded]
  ],
)

== Your first example <intro-first-example>

Start with the smallest possible example. The snippet below produces a basic set of block elements:

#example-pair(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #cell[A]
  #cell(fill: palettes.pastel.blue)[B]
  #badge(status: "success")[OK]
  #tag[x]
  ```
,
  [
    #cell[A]
    #h(4pt)
    #cell(fill: palettes.pastel.blue)[B]
    #h(6pt)
    #badge(status: "success")[OK]
    #h(6pt)
    #tag[x]
  ],
)

These few components already cover the most common starting points:

- `cell`: the most basic block
- `badge`: a compact status marker
- `tag`: small blocks for labels, discriminants, and so on

== A more realistic example <intro-real-example>

When you need to express a "field region + pointed-to target region" structure, start with the `schema` / `region` / `target` combination:

#wide-example(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #let C = palettes.rust

  #schema(title: raw("Vec<T>"))[
    #region[
      #cell(fill: C.ptr)[`ptr`#sub-label[2/4/8]]
      #cell(fill: C.sized)[`len`#sub-label[2/4/8]]
      #cell(fill: C.sized)[`cap`#sub-label[2/4/8]]
    ]
    #connector()
    #target(fill: C.heap, label: "(heap)", width: 130pt)[
      #cell(fill: C.any)[`T`]
      #cell(fill: C.any)[`T`]
      #note[… len]
    ]
  ]
  ```
,
  [
    #let C = palettes.rust

    #schema(title: raw("Vec<T>"))[
      #region[
        #cell(fill: C.ptr)[`ptr`#sub-label[2/4/8]]
        #cell(fill: C.sized)[`len`#sub-label[2/4/8]]
        #cell(fill: C.sized)[`cap`#sub-label[2/4/8]]
      ]
      #connector()
      #target(fill: C.heap, label: "(heap)", width: 130pt)[
        #cell(fill: C.any)[`T`]
        #cell(fill: C.any)[`T`]
        #note[… len]
      ]
    ]
  ],
)

This example illustrates the typical `blockcell` pattern: express the local pieces with small components, then compose them into a complete diagram.

== Recommended learning path <intro-learning-path>

If this is your first time, we suggest reading the manual in this order:

1. Start with the #doc-link("api-overview")[*API overview*] to see what's available
2. Then move to #doc-link("patterns")[*Common patterns*] for the most useful idioms
3. Then read:
   - #doc-link("layer1-cell")[the foundational chapter on `cell`]
   - #doc-link("layer2-region")[the container chapter on `region`]
   - #doc-link("layer3-schema")[the composite chapter on `schema` and `linked-schema`]
4. Finally, jump into topical chapters by need:
   - #doc-link("flows")[Flowcharts]
   - #doc-link("states")[State transition diagrams]
   - #doc-link("tree")[Hierarchical tree diagrams]
   - #doc-link("seq")[Sequence diagrams]

This is faster than reading the full API reference end-to-end.

== Choosing your entry point <intro-choose-entry>

If you already know what you're trying to draw, jump straight in by task:

- Memory layouts and structure diagrams: start with #doc-link("layer1-cell")[`cell`], #doc-link("layer2-region")[`region`], #doc-link("layer3-schema")[`schema`]
- Protocol headers, registers, bit fields: start with #doc-link("layer3-bit-row")[`bit-row`]
- Flowcharts: start with the #doc-link("flows")["Flowcharts" chapter]
- State machines: start with the #doc-link("states")["State transition diagrams" chapter]
- Hierarchies: start with the #doc-link("tree")["Hierarchical tree diagrams" chapter]
- Service interactions and call chains: start with the #doc-link("seq")["Sequence diagrams" chapter]

== How to use this manual <intro-how-to-use>

This manual has two halves:

- The first half helps you get started fast and pick components by task
- The second half is the full reference for parameters and examples

If you just want to start drawing right away, read:

- #doc-link("intro")[Introduction]
- #doc-link("api-overview")[API overview]
- #doc-link("patterns")[Common patterns]
- #doc-link("examples")[Worked examples]

If you're already drawing and just need to look up a component's parameters or behavior, jump straight to the relevant reference chapter.

== Highlights <intro-highlights>

BlockCell isn't trying to turn Typst into a freeform canvas. It provides a stable, composable, reusable component set for the structured diagrams that show up most often in technical documentation.

- *Structural expression*: no manual coordinate placement — describe diagrams in terms of "fields, containers, groups, connections, flows", with code that mirrors structure one-to-one.
- *Clear composition layers*: from #doc-link("layer1-cell")[`cell`] and #doc-link("layer2-region")[`region`] foundations, build up to richer figures like #doc-link("layer3-schema")[`schema`], #doc-link("layer3-bit-row")[`bit-row`], and #doc-link("layer3-seq-lane")[`seq-lane`].
- *Built for maintenance*: similar diagrams reuse the same idioms, palettes, and helpers — adding fields, removing nodes, or restyling never requires a redraw.
- *Targeted at technical scenarios*: native support for memory layouts, protocol headers, flowcharts, state diagrams, sequence diagrams, hierarchical trees — not just isolated drawing primitives.
- *Visual consistency*: built-in palettes, layered API, and composition patterns keep multiple figures in a document looking the same.
