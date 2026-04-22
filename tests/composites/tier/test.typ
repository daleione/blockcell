#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Stack of two tiers with accents — the classic layered-architecture shape.
#tier(label: [Client], accent: palettes.categorical.at(0).darken(30%))[
  #group(
    fill: palettes.categorical.at(0).lighten(55%),
    stroke: 0.6pt + palettes.categorical.at(0).darken(10%),
    width: 100%, inset: 6pt,
  )[
    #cell(fill: palettes.categorical.at(0).lighten(20%), width: 100%)[Web]
  ]
]
#v(6pt)
#tier(label: [Data], accent: palettes.categorical.at(4).darken(30%))[
  #group(
    fill: palettes.categorical.at(4).lighten(55%),
    stroke: 0.6pt + palettes.categorical.at(4).darken(10%),
    width: 100%, inset: 6pt,
  )[
    #cell(
      fill: palettes.categorical.at(4).lighten(20%),
      subtitle: [MySQL],
      width: 100%,
      inset: (x: 6pt, y: 6pt),
    )[Orders]
  ]
]
