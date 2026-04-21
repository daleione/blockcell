#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #flow-col(
    process[Lookup cache],
    branch-merge([Cache hit?],
      yes: process(fill: palettes.pastel.green)[Return cached],
      no:  process(fill: palettes.pastel.orange)[Compute + store],
    ),
    process[Serialize response],
  )
]
