#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#grid-row(label: [Main Memory], label-width: 80pt)[
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`03`]
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`21`]
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`FF`]
]

#grid-row(label: [CPU Cache], label-width: 80pt)[
  #cell(fill: palettes.pastel.yellow, width: 28pt, height: 20pt, inset: 2pt, overlay: [M])[`03`]
  #cell(fill: palettes.pastel.yellow, width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`21`]
]
