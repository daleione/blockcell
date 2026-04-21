#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#section[Cache Coherency][
  #region[
    #cell(fill: palettes.pastel.yellow, overlay: [M])[`03`]
    #cell(fill: palettes.pastel.yellow, overlay: [S])[`21`]
  ]
  #v(4pt)
  #legend(
    (label: [Modified], fill: orange),
    (label: [Shared],   fill: green),
  )
]
