# Examples

This directory contains end-to-end `blockcell` examples organized by scenario.  
If you're new to the project, start here: pick the example closest to your use case, compile it, and then copy the relevant patterns into your own document.

## How to use these examples

Inside this repository, examples import the local package source:

```typ
#import "../lib.typ": *
```

If you are using the published package instead of the repository checkout, use the preview import form in your own document:

```typ
#import "@preview/blockcell:0.1.0": *
```

## Example index

### `rust-cells.typ`

**Scenario:** Rust memory layout / ownership / interior mutability

**Demonstrates:**

- `schema`
- `linked-schema`
- `region`
- `target`
- `wrap`
- `divider`
- `cell`
- `tag`
- domain palette: `palettes.rust`

**Good starting point if you want to draw:**

- memory layouts
- pointer + payload structures
- enum-like storage layouts
- ownership / heap-reference diagrams

---

### `network-layers.typ`

**Scenario:** protocol stack / packet header / encapsulation diagrams

**Demonstrates:**

- `bit-row`
- `schema`
- `section`
- `region`
- `cell`
- `legend`
- domain palette: `palettes.network`

**Good starting point if you want to draw:**

- IPv4 / TCP / UDP headers
- layered protocol stacks
- encapsulation diagrams
- register-like fixed-width field layouts

---

### `http-handler-flow.typ`

**Scenario:** request-processing flowchart / worker loop

**Demonstrates:**

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

**Good starting point if you want to draw:**

- backend request flows
- decision-heavy business logic
- retry / loop workflows
- operational process diagrams

---

### `file-io-states.typ`

**Scenario:** simple state machine

**Demonstrates:**

- `state-chain`
- `state`
- `loop`
- `jump`

**Good starting point if you want to draw:**

- lifecycle diagrams
- protocol states
- resource state transitions
- compact finite-state machines

---

### `cache-hierarchy.typ`

**Scenario:** computer architecture / cache hierarchy / coherence behavior

**Demonstrates:**

- `section`
- `grid-row`
- `region`
- `connector`
- `legend`
- `cell`
- domain palette: `palettes.cache`

**Good starting point if you want to draw:**

- layered architecture
- cache / memory hierarchy
- MESI-style state illustrations
- tabular hardware diagrams

## Compile an example

From the repository root:

```bash
typst compile --root . examples/http-handler-flow.typ
```

Replace the filename with any example listed above.
