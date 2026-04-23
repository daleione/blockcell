#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #tree(
    node[root],
    tree(node[L], node[LL], node[LR]),
    tree(node[R], node[RL], node[RR]),
  )
]
