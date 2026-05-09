#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// One side empty: canvas should hug the populated half — the root sits
// flush against the empty side with no spurious side-gap. Also exercises
// branch-width asymmetry (short leaf vs wider subtree) on the same side
// to verify the right-aligning of left-blobs / left-aligning of
// right-blobs keeps the trunk clean.
#align(center)[
  #mindmap(
    node[Root],
    rights: (
      node[A],
      tree(direction: "right", node[Bigger Subtree],
        node[child-1],
        node[child-2],
        node[child-3],
      ),
      node[Z],
    ),
  )
]
