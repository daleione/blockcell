#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// BST convention: diagonal lines, not orthogonal — so explicitly set
// edge-style: "line" on the outer call. Propagation covers the nested trees.
#align(center)[
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
]
