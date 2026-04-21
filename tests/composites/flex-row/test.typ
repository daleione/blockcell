#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#grid-row(label: [Catalog])[
  #flex-row(
    (flex: 1, body: cell(fill: palettes.pastel.blue,  width: 100%)[Category Tree]),
    (flex: 1, body: cell(fill: palettes.pastel.cyan,  width: 100%)[Product Card]),
    (flex: 2, body: cell(fill: palettes.pastel.teal,  width: 100%)[Search Index]),
  )
]
