# Changelog

All notable changes to this project. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project adheres to semantic versioning once it reaches 1.0.

## [Unreleased]

### Added

- **Sequence diagrams (`seq-lane`)**: full layer with calls, returns, self-calls, fragments (`alt` / `else` / `opt` / `loop` / `par` / `group` / `break` / `critical`), notes, dividers, delays, spacers, refs, swim-lane boxes, lifeline create/destroy, autonumber, and arrow-head variants (`filled` / `v` / `x` / `o` / `half-top` / `half-bottom`).
- **PlantUML compatibility layer (`seq-puml`)**: parses PlantUML sequence syntax and dispatches to `seq-lane`. Covers participants, aliases, all listed fragments, notes, dividers, delays, spacers, refs, boundary arrows, autonumber, `create` / `destroy`, and the full set of arrow modifiers.
- **State diagrams (`state-chain`)**: `state`, `loop`, `jump`, `bi-jump`, and a 2D mode for non-linear topologies.
- **Tree diagrams (`tree` / `node`)**: hierarchical layout with elbow connectors and atom interop.
- **Records (`record` / `record-graph` / `record-layout`)**: bordered key-value blocks with internal row / column separators, plus two 2D modes that link records via dashed reference arrows. Origin dot is rendered inside the parent value cell (PlantUML record style), with one dot per anchor row regardless of fan-out. Value column auto-reserves min width when any row has an outgoing reference, so all-compound records don't collapse onto the column separator. `record-graph` does its own auto column-by-depth placement with sibling stacking; `record-layout` is a painter for diagrams whose record positions and per-edge cubic Bezier control points were computed externally — start / end snap to the actual rendered record geometry, and `c1` / `c2` shape the curve. Useful for object diagrams, JSON visualizations, ER-style links, and box-and-pointer / heap diagrams.
- **Flow diagrams (`flow-col`)**: dedicated chapter with `process`, `decision`, `terminal`, `junction`, `branch`, `branch-merge`, `switch`, `flow-loop`.
- **New composites**: `tier`, `match-row`, `cell` `subtitle:` support for architecture diagrams; `group` container; `stack` helper.
- **Status badges**: shortcuts for semantic colors via `palettes.status`.
- `examples/` directory with end-to-end scenarios (rust cells, network layers, HTTP flow, file IO states, cache hierarchy, architecture diagrams).
- Snapshot test infrastructure under `tests/` plus a CI workflow.
- Showcase image grid and clickable cross-links throughout the manual.

### Changed

- Diagrams scale with surrounding `text.size`.
- Manual split into per-chapter Typst files with restyled headings.
- Centralized base palette defaults; reused `region` to back `target`.
- Refactored edge rendering; fixed loop label placement.
- `brace` parameter `span` replaces the prior name; added direction support.
- Tightened `state-chain` circle measurement and auto-shrink.
- Self-call base activation: anchor geometry corrected; activations auto-close on cross-participant calls.
- Header bar gets padding before the body content.

### Fixed

- `seq-act` inside an activation on the same participant now panics with a fix hint instead of rendering as visual noise.
- `seq-line` no longer wraps inside surrounding tables.
- 2D state topology example now fits within page margins.
- `seq-note` renders as a real folded-corner pentagon.
- Replaced invalid Typst color identifiers in docs and docstrings.
- Visual regressions in early diagram rendering rebuilt all reference SVGs.

## [0.1.0] — 2026-04-16

Initial release: composable block-and-cell diagrams for Typst — atoms (`cell`, `tag`, `badge`, `note`, `edge`, …), containers (`region`, `target`, `connector`, …), and composites (`schema`, `linked-schema`, `bit-row`, `legend`, `section`, …) plus the `palettes` system.

[Unreleased]: https://github.com/daleione/blockcell/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/daleione/blockcell/releases/tag/v0.1.0
