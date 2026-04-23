#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Exercises mixing leaf children and subtree children as siblings, plus a
// single-child root — ensures the center-above-children layout works when
// sibling sub-blobs have very uneven widths.
#align(center)[
  #tree(
    node(fill: palettes.status.info.fill)[JSON],
    tree(node[obj], node[a: 1], node[b: "x"]),
    node[null],
    tree(node[arr], node[0], node[1], node[2]),
  )
]
