#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Canonical mind-map shape: a central root with branch subtrees stacked
// vertically on each side. Each branch is a `tree(direction: ...)` so its
// root anchor faces the central root. Mixes a bare leaf and a multi-level
// subtree on the right to exercise the column packing.
#align(center)[
  #mindmap(
    node(shape: "underline")[OS],
    lefts: (
      tree(direction: "left", node(shape: "underline")[Long term],
        node[Vision],
        node[Roadmap],
      ),
      node[Short term],
    ),
    rights: (
      node[Marketing],
      tree(direction: "right", node(shape: "underline")[Engineering],
        node[Backend],
        node[Frontend],
      ),
    ),
  )
]
