#import "../../lib.typ": *
#import "../style.typ": *

= Hierarchical tree diagrams <tree>

*blockcell*'s `tree` draws top-down hierarchical structures — BSTs, heaps, tries, directory
trees, JSON, org charts. There's a single entry point:

#section-label[Minimal form]

#example-pair(
  ```typ
  #tree(root, ..children)
  ```
,
  [
    #tree(
      node[root],
      node[left],
      node[right],
    )
  ],
)

`root` and each `child` are *arbitrary content* — `node(...)` / nested `tree(...)` /
`cell` / `flow-node` / `process` / even `[plain text]`. Mix and match freely.
`node(...)` is the tree-specific node constructor, with visual conventions tuned for trees:
pastel-blue fill, natural height (the box grows with the text), and a `"circle"` minimum
diameter of 28pt (so single- and double-digit nodes line up evenly across BSTs and heaps).

#v(6pt)

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #text(weight: "bold")[Components in this chapter]
    #v(2pt)
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[Main entry],
      text(size: 0.85em)[`tree(root, ..children)` — top-level renderer that doubles as a subtree constructor],
      text(size: 0.85em, weight: "bold")[Convenience node],
      text(size: 0.85em)[`node(body, shape, fill, size)` — tree's default node
        (natural height, pastel-blue fill, circle min-diameter 28pt)],
      text(size: 0.85em, weight: "bold")[Edge style],
      text(size: 0.85em)[`edge-style: "elbow"` (default, orthogonal) /
        `"line"` (diagonal straight, common for BSTs)],
    )
  ]
]

== Quick start <tree-quick-start>

The classic balanced binary tree — one function plays both top-level renderer and subtree
constructor:

#wide-example(
  ```typ
  #tree(
    node[root],
    tree(node[L], node[LL], node[LR]),
    tree(node[R], node[RL], node[RR]),
  )
  ```,
  [
    #tree(
      node[root],
      tree(node[L], node[LL], node[LR]),
      tree(node[R], node[RL], node[RR]),
    )
  ],
)

#v(4pt)

How to read it: the outermost `tree(...)` is the top-level call that produces the figure;
the two inner `tree(...)`s are passed as children, treated as subtrees by the parent. *Same
function, two roles*, no need to distinguish.

The default style is orthogonal elbow lines, suitable for directory trees and org charts.
For BSTs / heaps with diagonal lines, set `edge-style: "line"` *once on the outermost call* —
all nested subtrees inherit it.

== Core API <tree-core-api>

=== `node` <tree-node>

The tree-specific node constructor. It sits alongside `cell` / `flow-node` from the atoms
chapter — they're all "a shape with text", but each is tuned for a different context:
`cell` for memory layouts (zero corner radius, tight 4pt padding), `flow-node` for flowcharts
(uniform 28pt height), `node` for trees (natural height, 3pt corner radius, pastel-blue fill,
and a 28pt minimum diameter for `"circle"`).

It returns content, so it can render standalone like `#cell[x]` or fill any slot in a `tree(...)`.

#section-label[Example]

#wide-example(
  ```typ
  #node[root]                     // default rectangle
  #node(shape: "circle")[7]       // circle, auto-diameter
  #node(shape: "stadium")[start]  // stadium
  #node(fill: palettes.pastel.yellow)[dir/]
  ```,
  [
    #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt, align: center + horizon,
      node[root],
      node(shape: "circle")[7],
      node(shape: "stadium")[start],
      node(fill: palettes.pastel.yellow)[dir/],
    )
  ],
)

#section-label[Parameters]

#params-box("node",
  ("body",   ("content",)),
  ("shape",  ("str",)),
  ("fill",   ("color",)),
  ("stroke", ("stroke",)),
  ("radius", ("length",)),
  ("inset",  ("length", "dictionary")),
  ("size",   ("auto", "length")),
  returns: "content",
)

#param-detail("shape", ("str",), default: raw("\"rect\"", lang: none))[
  `"rect"` / `"circle"` / `"stadium"`. With `size: auto`, `"circle"` has a 28pt minimum
  diameter — a BST mixing `1`, `8`, `10`, `14` lines up evenly without setting `size:`.
  For other shapes (e.g. diamond), pass `flow-node(shape: "diamond")` directly as content to `tree`.
]

#param-detail("size", ("auto", "length"), default: raw("auto", lang: none))[
  Fixed circle diameter or rectangle/stadium width. `auto` adapts to the body. To size three-digit
  numbers uniformly:
]

#section-label[Example — uniform circle-node sizing]

#example-pair(
  ```typ
  #let c(body) = node(shape: "circle", size: 36pt, body)
  #tree(c[100], c[250], c[999])
  ```
,
  [
    #{
      let c(body) = node(shape: "circle", size: 36pt, body)
      tree(c[100], c[250], c[999])
    }
  ],
)

#param-detail("fill", ("color",),
  default: raw("palettes.pastel.blue", lang: none))[
  Node fill. Directory-tree convention: `palettes.pastel.yellow` for directories,
  `palettes.pastel.blue` for files.
]

#param-detail("stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  Node border. Same default as the other atoms.
]

#param-detail("inset", ("length", "dictionary"),
  default: raw("(x: 8pt, y: 4pt)", lang: none))[
  Padding from text to node edge. Tighter than `flow-node` (`10pt × 6pt`) — tree nodes are
  usually short (a name or number), so a tighter fit doesn't waste canvas space.
]

#param-detail("radius", ("length",), default: raw("3pt", lang: none))[
  Rectangle corner radius. `stadium` forces 999pt (capsule); `circle` forces 50%; this parameter
  doesn't affect them.
]

=== `tree` <tree-tree>

The hierarchical-tree renderer. The first positional argument is the root; the rest are children.
*Every slot is content* — `node(...)`, nested `tree(...)`, `cell` / `flow-node` / `process`,
plain text, all valid, all mixable.

#section-label[Example]

#wide-example(
  ```typ
  #tree(
    node(shape: "circle")[8],
    tree(node(shape: "circle")[3],
      node(shape: "circle")[1],
      node(shape: "circle")[6],
    ),
    tree(node(shape: "circle")[10],
      node(shape: "circle")[9],
      node(shape: "circle")[14],
    ),
    edge-style: "line",   // BST convention: diagonal lines
  )
  ```,
  [
    #tree(
      node(shape: "circle")[8],
      tree(node(shape: "circle")[3],
        node(shape: "circle")[1],
        node(shape: "circle")[6],
      ),
      tree(node(shape: "circle")[10],
        node(shape: "circle")[9],
        node(shape: "circle")[14],
      ),
      edge-style: "line",
    )
  ],
)

#section-label[Parameters]

#params-box("tree",
  ("root",        ("content",)),
  ("..children",  ("content",)),
  ("x-gap",       ("length",)),
  ("y-gap",       ("length",)),
  ("edge-style",  ("auto", "str")),
  ("edge-stroke", ("stroke",)),
  returns: "content",
)

#param-detail("edge-style", ("auto", "str"),
  default: raw("auto", lang: none))[
  Edge style. Three values:

  - `"elbow"` — *orthogonal*: parent bottom → shared horizontal manifold → child top.
    The standard for directory trees, org charts, and JSON hierarchies.
  - `"line"` — *diagonal straight*: parent bottom → child top. Common for BSTs / heaps.
  - `auto` (default) — inherits from the enclosing `tree(...)`; if no enclosing tree set it,
    falls back to `"elbow"`.

  *Set it once on the outermost call and every nested subtree inherits it* —
  no need to repeat `edge-style:` on every level.
]

#param-detail("x-gap", ("length",), default: raw("16pt", lang: none))[
  Horizontal spacing between sibling subtrees / leaves. Increase for wide subtrees to avoid
  visual crowding.
]

#param-detail("y-gap", ("length",), default: raw("22pt", lang: none))[
  Vertical spacing between parent and child. In elbow mode, the horizontal manifold sits at
  `y-gap / 2`.
]

#param-detail("edge-stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  Edge stroke. Adjust thickness / color / dashing — e.g. light gray to de-emphasize a background
  subtree.
]

== Common patterns <tree-common-patterns>

#section-label[Directory tree (default elbow)]

An elbow-style directory tree — yellow folders, blue files, distinguished by `fill:`. No
`edge-style:` needed on the outer call; the default `"elbow"` is correct.

#wide-example(
  ```typ
  #tree(
    node(fill: palettes.pastel.yellow)[src/],
    node(fill: palettes.pastel.blue)[atoms.typ],
    tree(node(fill: palettes.pastel.yellow)[composites/],
      node(fill: palettes.pastel.blue)[grid.typ],
      node(fill: palettes.pastel.blue)[flex.typ],
    ),
    node(fill: palettes.pastel.blue)[palettes.typ],
  )
  ```,
  [
    #tree(
      node(fill: palettes.pastel.yellow)[src/],
      node(fill: palettes.pastel.blue)[atoms.typ],
      tree(node(fill: palettes.pastel.yellow)[composites/],
        node(fill: palettes.pastel.blue)[grid.typ],
        node(fill: palettes.pastel.blue)[flex.typ],
      ),
      node(fill: palettes.pastel.blue)[palettes.typ],
    )
  ],
)

#section-label[JSON hierarchy (mixing leaves and subtrees)]

`tree`'s children can *mix leaves and subtrees*. JSON's "object → fields, array → indices"
naturally composes this way:

#wide-example(
  ```typ
  #tree(
    node(fill: palettes.status.info.fill)[JSON],
    tree(node[obj], node[a: 1], node[b: "x"]),
    node[null],
    tree(node[arr], node[0], node[1], node[2]),
  )
  ```,
  [
    #tree(
      node(fill: palettes.status.info.fill)[JSON],
      tree(node[obj], node[a: 1], node[b: "x"]),
      node[null],
      tree(node[arr], node[0], node[1], node[2]),
    )
  ],
)

#section-label[Interop with atoms]

Tree slots are content — and `node` and `cell` / `tag` / `process` / `flow-node` are essentially
the same kind of thing (all thin aliases on `flow-node` or its derivatives), so you can mix
them inside a single tree. The "payment callback" tree below uses `process` for the root and
`cell` / `tag` / `flow-node` for the leaves — no `node(...)` anywhere:

#wide-example(
  ```typ
  #tree(
    process[payment callback],
    cell(fill: palettes.status.info.fill)[business handling],
    tag[side effect],
    flow-node(shape: "stadium", fill: palettes.pastel.red)[refund],
  )
  ```,
  [
    #tree(
      process[payment callback],
      cell(fill: palettes.status.info.fill)[business handling],
      tag[side effect],
      flow-node(shape: "stadium", fill: palettes.pastel.red)[refund],
    )
  ],
)

#v(4pt)

Edges leave from the root's bottom center and land at each child's top center — perfectly
flush against rectangles, stadiums, and circles. Pointy shapes like diamonds will leave the
endpoint slightly suspended; in those cases use `node` or `shape: "rect"`.

== Limitations <tree-limitations>

- *No tight layout* — sibling subtrees use uniform `x-gap`, with no Reingold-Tilford / tidy-tree
  style compression. For dense trees, split into smaller pieces or hand-tune `x-gap`.
- *No automatic routing* — only `"line"` and `"elbow"` edge styles, no curves, no obstacle
  avoidance. For cross-layer references, use `edge()` or `place(line(...))` directly.
- *Top-down only* — sideways trees can be approximated with `rotate(-90deg)`, but labels rotate too.
- *The whole tree is unbreakable* — internally wrapped in `block(breakable: false)` so absolute
  positioning isn't cut. For very tall / wide trees, split into multiple figures.
