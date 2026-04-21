// ============================================================================
// blockcell — Composable block-and-cell layout diagrams
// ============================================================================
//
// A Typst package for drawing structured layout diagrams using composable
// visual primitives. Useful for memory maps, data format specifications,
// register layouts, protocol headers, cache/pipeline diagrams, and more.
//
// Layer 1 — Atoms (individual visual elements):
//   cell         Colored rectangular box — the core building block
//   tag          Dotted-border cell for markers or discriminants
//   note         Small inline annotation text
//   badge        Compact status indicator (STALLED, ERROR, HIT, …)
//   sub-label    Subscript-style size annotation (2/4/8, 4B, …)
//   span-label   Horizontal extent label (← capacity →)
//   wrap         Decorative border wrapper (double-border effects)
//   brace        Horizontal brace with centered label below
//   edge         Horizontal directed connector with optional label/arrow
//   flow-node    Flowchart node (rect / diamond / stadium / circle)
//                + semantic aliases process / decision / terminal / junction
//                (each ships with a conventional default fill)
//
// Layer 2 — Containers (grouping and structure):
//   region       Bordered container grouping cells into a unit
//   target       Linked / referenced region (dashed, faded, labeled)
//   connector    Vertical line linking a region to its target
//   divider      Text separator between layout alternatives
//   detail       Explanation / zoom bar below a region
//   entry-list   Vertical list of entries inside a target
//   group        Bordered container with top-left title for logical grouping
//
// Layer 3 — Composites (complete diagram patterns):
//   schema         Top-level inline diagram with title and description
//   linked-schema  Schema with fields → connector → target
//   grid-row       Labeled row for tabular / cache diagrams
//   lane           Horizontal track for thread / timeline diagrams
//   section        Titled card for grouping related diagrams
//   legend         Color legend mapping fills to labels
//   bit-row        Proportional bit-field row for protocol/register layouts
//   flex-row       Row of cells with fr-based proportional widths
//   flow-col       Vertical flow-chart column with auto-inserted down-arrows
//   branch         Diamond decision: Yes continues down, No branches right
//   branch-merge   Diamond with Yes / No columns that rejoin below
//   switch         N-way branch (diamond fans out to cases, rejoining below);
//                  cases are built with the `case(label, body)` constructor
//   flow-loop      Wraps a body with a back-edge on the left ("repeat")
//   seq-lane       Sequence diagram; steps built with the `seq-*` constructors
//                  (seq-call / seq-ret / seq-note / seq-act /
//                   seq-alt / seq-opt / seq-loop / seq-par)
//   state-chain    State-transition diagram (linear chain or 2D grid);
//                  edges built with state / loop / jump / bi-jump
//
// Palettes (curated color sets):
//   palettes.status       Semantic states (success/warning/danger/info/neutral)
//   palettes.pastel       Named soft swatches (red, blue, green, …)
//   palettes.categorical  8 distinct colors for legends / N-way groups
//   palettes.sequential   Light→dark single-hue ramps (5 steps)
//   palettes.rust / .network / .cache — domain examples
//
// ============================================================================

#import "src/atoms.typ": cell, tag, note, label, badge, sub-label, span-label, wrap, brace, edge, flow-node, process, decision, terminal, junction
#import "src/containers.typ": region, target, connector, divider, detail, entry-list, stack, group
#import "src/composites.typ": schema, linked-schema, grid-row, lane, section, legend, bit-row, flex-row, flow-col
#import "src/flows.typ": branch, branch-merge, switch, case, flow-loop
#import "src/seq.typ": seq-lane, seq-call, seq-ret, seq-note, seq-act, seq-alt, seq-opt, seq-loop, seq-par
#import "src/states.typ": state-chain, state, loop, jump, bi-jump
#import "src/palettes.typ": palettes
