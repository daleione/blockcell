#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #flow-col(
    terminal[Start],
    process[Receive request],
    decision(width: 170pt)[state == CLOSED?],
    process[Recover + refund],
    terminal[Done],
  )
]
