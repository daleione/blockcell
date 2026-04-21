#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof", edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],
  )
]
