#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#group(label: [Business layer], fill: palettes.categorical.at(1).lighten(50%))[
  #region(fill: palettes.categorical.at(1).lighten(20%))[
    #cell[own platform]
  ]
  #v(4pt)
  #region(fill: palettes.categorical.at(1).lighten(30%))[
    #cell[external sync]
  ]
]

#v(6pt)

// Logical (non-physical) grouping via dashed border.
#group(label: [Logical], dash: "dashed")[
  #cell[A] #cell[B]
]
