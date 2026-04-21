#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #state-chain(
    col-gap: 90pt, row-gap: 90pt,

    state("pending",   pos: (0, 0), initial: true)[pending],
    state("paid",      pos: (1, 0))[paid],
    state("shipped",   pos: (2, 0))[shipped],
    state("delivered", pos: (3, 0), accept: true)[delivered],
    state("cancelled", pos: (1.5, 1), accept: true,
      fill: palettes.pastel.red)[cancelled],

    jump("pending",   "paid")[pay()],
    jump("paid",      "shipped")[ship()],
    jump("shipped",   "delivered")[deliver()],
    jump("pending",   "cancelled")[cancel],
    jump("paid",      "cancelled")[refund],
  )
]
