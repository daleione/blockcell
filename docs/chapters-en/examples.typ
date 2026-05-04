#import "../../lib.typ": *
#import "../style.typ": *

= Examples and scenario guide <examples>

This chapter is organized by "what do you want to draw", not by component name.
If this is your first time using *blockcell*, pick the scenario closest to your need, run a complete example end-to-end, then come back to the reference chapters for details.

== How to use these examples <examples-how-to-use>

The example files in this repo use local imports:

```typst
#import "../lib.typ": *
```

If you're using the published package in your own document, switch to:

```typst
#import "@preview/blockcell:0.1.0": *
```

Compile any example:

```bash
typst compile --root . examples/http-handler-flow.typ
```

Just replace the filename with whichever example you want to view.

== If this is your first time <examples-first-time>

We suggest reading them in this order:

1. `rust-cells.typ`
   First, get familiar with the foundational structural components: #api-ref("layer1-cell", "cell"), #api-ref("layer2-region", "region"), #api-ref("layer3-schema", "schema").
2. `network-layers.typ`
   Then look at fixed-width layouts like #api-ref("layer3-bit-row", "bit-row").
3. `http-handler-flow.typ`
   When you need a flowchart, start here.
4. `file-io-states.typ`
   When you need a state machine, start here.
5. `cache-hierarchy.typ`
   When you need multi-row alignment, legends, and structured captions, start here.

== Pick an example by scenario <examples-by-scenario>

#grid(
  columns: (160pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[Memory layouts / data structures],
  [See `rust-cells.typ`],
  text(weight: "bold")[Protocol headers / bit fields],
  [See `network-layers.typ`],
  text(weight: "bold")[Business flows / decision branches],
  [See `http-handler-flow.typ`],
  text(weight: "bold")[State transitions],
  [See `file-io-states.typ`],
  text(weight: "bold")[Hierarchies / multi-row alignment],
  [See `cache-hierarchy.typ`],
)

== Scenario 1: memory layouts and structure diagrams <examples-structural>

=== `rust-cells.typ`

*Good fit if you're drawing:*

- Pointers + target objects
- Stack fields and heap contents
- Enums or tagged layouts
- Rust ownership, interior mutability, container structures

*You'll see:*

- `cell`
- `tag`
- `region`
- `target`
- `connector`
- `schema`
- `linked-schema`
- `wrap`
- `divider`
- `palettes.rust`

*Patterns worth copying:*

- A single `region` inside a `schema`
- `connector` + `target` for "the storage region this points to"
- `wrap` to add an extra emphasized border around a field
- `divider` to express mutually exclusive layouts

*Why look at this one first:*

It best illustrates the core idea behind *blockcell*: build structure with small components, then compose those into a complete figure.

== Scenario 2: protocol headers and bit fields <examples-bitfields>

=== `network-layers.typ`

*Good fit if you're drawing:*

- IPv4 / TCP / UDP headers
- Fixed-width field layouts
- Layered protocol stacks
- Register or packet format diagrams

*You'll see:*

- #api-ref("layer3-bit-row", "bit-row")
- #api-ref("layer3-schema", "schema")
- #api-ref("layer3-section", "section")
- #api-ref("layer2-region", "region")
- #api-ref("layer1-cell", "cell")
- #api-ref("layer3-legend", "legend")
- #api-ref("palettes-domain", "palettes.network")

*Patterns worth copying:*

- Stack multiple #api-ref("layer3-bit-row", "bit-row") into a full header
- Use a uniform `width:` to keep rows aligned
- Use #api-ref("layer3-legend", "legend") to explain what the colors mean
- Use #api-ref("layer3-section", "section") to gather everything into a complete card

*When to prefer this example:*

When the diagram is fundamentally about "field width" and "bit-segmented layout", rather than freeform connections or complex containers.

== Scenario 3: flowcharts and business branching <examples-flows>

=== `http-handler-flow.typ`

*Good fit if you're drawing:*

- Request handling flows
- Backend business branching
- Retry / loop / dispatch logic
- Operations or approval workflows

*You'll see:*

- `flow-col`
- `branch`
- `branch-merge`
- `switch`
- `case`
- `flow-loop`
- `process`
- `terminal`
- `junction`
- `legend`
- `status:` semantic colors

*Patterns worth copying:*

- Use `flow-col` as the trunk
- Use `branch` for "branches that don't return to the main line"
- Use `branch-merge` for "branches that rejoin the main line"
- Use `switch` for multi-way dispatch
- Use `flow-loop` for retries or polling

*When to prefer this example:*

When you want to express "the order between steps and decisions", not object structure or temporal interactions.

== Scenario 4: state machines and lifecycles <examples-states>

=== `file-io-states.typ`

*Good fit if you're drawing:*

- Resource lifecycles
- Protocol states
- File / connection / job state transitions
- Compact finite state machines

*You'll see:*

- `state-chain`
- `state`
- `loop`
- `jump`

*Patterns worth copying:*

- Draw the main state chain in linear mode first
- Use `loop` for self-transitions
- Use `jump` for cross-state transitions
- Mark start and end with `initial` / `accept`

*When to prefer this example:*

When the focus is "how states transition", not "who calls whom".

== Scenario 5: hierarchies and multi-row alignment <examples-hierarchy>

=== `cache-hierarchy.typ`

*Good fit if you're drawing:*

- Cache hierarchies
- Layered architectures
- Multi-row parallel structures
- Structure diagrams that need a legend

*You'll see:*

- `section`
- `grid-row`
- `region`
- `connector`
- `legend`
- `cell`
- `palettes.cache`

*Patterns worth copying:*

- Use `grid-row` for multi-row alignment
- Use a uniform `label-width:` to keep label columns flush
- Use `legend` to explain states or colors
- Use `section` to wrap the whole group

*When to prefer this example:*

When you need "multiple rows aligned cleanly" — not single-row field diagrams or flowcharts.

== From examples back to the manual <examples-back-to-manual>

Once you've found the example closest to your scenario, head back to the matching reference chapter:

#grid(
  columns: (180pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[Structure / memory layout],
  [Re-read #doc-link("layer1")["Layer 1 — Atoms"], #doc-link("layer2")["Layer 2 — Containers"], #doc-link("layer3")["Layer 3 — Composites"]],
  text(weight: "bold")[Headers / bit fields],
  [Re-read #doc-link("layer3-bit-row")[`bit-row`], #doc-link("layer3-legend")[`legend`], #doc-link("palettes")[the palettes chapter]],
  text(weight: "bold")[Flowcharts],
  [Re-read the #doc-link("flows")["Flowcharts" chapter]],
  text(weight: "bold")[State machines],
  [Re-read the #doc-link("states")["State transition diagrams" chapter]],
  text(weight: "bold")[Color choices],
  [Re-read the #doc-link("palettes")["Palettes" chapter]],
)

== A simple rule for picking an example <examples-how-to-choose>

If you're not sure where to start, use this rule:

- First, look at *the example that most resembles your target diagram*
- First, copy *the overall structure*, then replace text and colors
- Only when you actually need to, go back to the API reference for parameter details

This is usually faster than reading the full API end-to-end.
