#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Right-growing tree — root on the left, children stacked vertically
// to its right. Mixes a leaf with a nested subtree to verify cross-axis
// centering and that the resolved direction propagates to the inner
// `tree(...)` whose own direction is auto.
#align(center)[
  #tree(
    direction: "right",
    node[Engineering],
    node[Backend],
    tree(node[Frontend],
      node[Web],
      node[Mobile],
    ),
    node[Infra],
  )
]
