#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #flow-col(
    process[Route request],
    switch([endpoint],
      case([/users],  process(fill: palettes.pastel.cyan)[Fetch user data]),
      case([/orders], process(fill: palettes.pastel.orange)[Fetch orders]),
      case([/stats],  process(fill: palettes.pastel.purple)[Compute stats]),
    ),
    process[Serialize],
  )
]
