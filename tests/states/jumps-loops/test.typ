#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Linear chain with a self-loop and a skip-ahead jump.
#align(center)[
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof", edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],

    loop("reading")[`read()`],
    jump("reading", "closed", route: "below")[`close()`],
  )
]
