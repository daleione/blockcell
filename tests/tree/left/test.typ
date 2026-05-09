#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Left-growing tree — root on the right, children stacked vertically
// to its left. Mirror of the "right" case so the root's "out" edge is
// on its left side and connectors emit leftward.
#align(center)[
  #tree(
    direction: "left",
    node[Long term],
    node[Vision],
    tree(node[Roadmap],
      node[Q1],
      node[Q2],
    ),
  )
]
