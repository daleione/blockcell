# Examples

This directory contains complete `blockcell` examples organized by use case.

If you are new to the project, start here. Pick the scenario closest to the diagram you want to draw, compile that example, and then copy the parts you need into your own document.

## How to use these examples

Inside this repository, examples import the local package source:

```typ
#import "../lib.typ": *
```

If you are using the published package in your own document, use the preview import instead:

```typ
#import "@preview/blockcell:0.1.0": *
```

## Where to begin

Choose the example by the kind of diagram you want to make:

- **Memory layout or ownership diagram** → `rust-cells.typ`
- **Protocol header or layered network diagram** → `network-layers.typ`
- **Business flow or request-processing flowchart** → `http-handler-flow.typ`
- **State machine or lifecycle diagram** → `file-io-states.typ`
- **Hardware hierarchy or cache diagram** → `cache-hierarchy.typ`

If you only want one file to study first:

1. Start with `rust-cells.typ` for structural diagrams
2. Start with `http-handler-flow.typ` for flowcharts
3. Start with `file-io-states.typ
` for state transitions

## Example index

### `rust-cells.typ`

**A good fit if you want to draw:**

- memory layouts
- pointer + payload structures
- enum-like storage layouts
- ownership / heap-reference diagrams

**What this example includes:**

- `schema`
- `linked-schema`
- `region`
- `target`
- `wrap`
- `divider`
- `cell`
- `tag`
- domain palette: `palettes.rust`

**Good patterns to copy first:**

- `schema + region + cell` for simple structure diagrams
- `linked-schema` for pointer-to-target layouts
- `wrap` for highlighted outer borders

---

### `network-layers.typ`

**A good fit if you want to draw:**

- IPv4 / TCP / UDP headers
- layered protocol stacks
- encapsulation diagrams
- register-like fixed-width field layouts

**What this example includes:**

- `bit-row`
- `schema`
- `section`
- `region`
- `cell`
- `legend`
- domain palette: `palettes.network`

**Good patterns to copy first:**

- `bit-row` for packet headers and bit fields
- `legend` for field color explanations
- `section` for grouping related protocol parts

---

### `http-handler-flow.typ`

**A good fit if you want to draw:**

- backend request flows
- decision-heavy business logic
- retry / loop workflows
- operational process diagrams

**What this example includes:**

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

**Good patterns to copy first:**

- `flow-col` for straight-line flows
- `branch` for yes/no decisions
- `flow-loop` for retry or polling loops

---

### `file-io-states.typ`

**A good fit if you want to draw:**

- lifecycle diagrams
- protocol states
- resource state transitions
- compact finite-state machines

**What this example includes:**

- `state-chain`
- `state`
- `loop`
- `jump`

**Good patterns to copy first:**

- `state-chain` for left-to-right state flows
- `loop` for self-transitions
- `jump` for non-adjacent transitions

---

### `cache-hierarchy.typ`

**A good fit if you want to draw:**

- layered architecture
- cache / memory hierarchy
- MESI-style state illustrations
- tabular hardware diagrams

**What this example includes:**

- `section`
- `grid-row`
- `region`
- `connector`
- `legend`
- `cell`
- domain palette: `palettes.cache`

**Good patterns to copy first:**

- `grid-row` for aligned labeled rows
- `legend` for state/color keys
- `connector` for simple vertical relationships

## Compile an example

From the repository root:

```bash
typst compile --root . examples/http-handler-flow.typ
```

Replace the filename with any example listed above.

## Suggested workflow

1. Pick the closest example
2. Compile it unchanged
3. Delete the parts you do not need
4. Rename labels and colors
5. Extract repeated patterns into helpers with `.with()` or small wrapper functions

## Related documentation

- Project overview and quick start: `README.md`
- Full manual: `docs/manual.typ`
- Snapshot tests and focused fixtures: `tests/README.md`
