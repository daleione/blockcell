#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #tree(
    node(fill: palettes.pastel.yellow)[src/],
    node(fill: palettes.pastel.blue)[atoms.typ],
    tree(node(fill: palettes.pastel.yellow)[composites/],
      node(fill: palettes.pastel.blue)[grid.typ],
      node(fill: palettes.pastel.blue)[flex.typ],
    ),
    node(fill: palettes.pastel.blue)[palettes.typ],
    edge-style: "elbow",
  )
]
