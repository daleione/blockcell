#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// The outermost `direction: "right"` should cascade to nested `tree(...)`
// calls whose own direction is still `auto` — same scheme as edge-style.
// Two levels deep: outer "right", inner with auto direction must also
// grow rightward (its own children stacked vertically to its right).
#align(center)[
  #tree(
    direction: "right",
    node[A],
    node[A1],
    tree(node[A2],
      node[A2a],
      tree(node[A2b],
        node[A2b-i],
        node[A2b-ii],
      ),
    ),
  )
]
