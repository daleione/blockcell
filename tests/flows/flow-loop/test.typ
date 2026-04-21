#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #flow-loop(
    flow-col(
      terminal[Accept],
      process[Handle request],
      process[Write response],
    ),
    back-label: [next request],
  )
]
