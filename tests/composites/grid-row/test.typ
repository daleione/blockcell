#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Explicit label-width — stacked rows align tabularly regardless of label length.
#grid-row(label: [Main Memory], label-width: 80pt)[
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`03`]
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`21`]
  #cell(fill: palettes.pastel.orange, width: 28pt, height: 20pt, inset: 2pt)[`FF`]
]

#grid-row(label: [CPU Cache], label-width: 80pt)[
  #cell(fill: palettes.pastel.yellow, width: 28pt, height: 20pt, inset: 2pt, overlay: [M])[`03`]
  #cell(fill: palettes.pastel.yellow, width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`21`]
]

#v(10pt)

// Auto label-width (default) — label column hugs its natural width.
#grid-row(label: [RAM])[
  #cell(fill: palettes.pastel.blue, width: 28pt, height: 20pt, inset: 2pt)[`03`]
  #cell(fill: palettes.pastel.blue, width: 28pt, height: 20pt, inset: 2pt)[`21`]
]

#grid-row(label: [Long label demo])[
  #cell(fill: palettes.pastel.green, width: 28pt, height: 20pt, inset: 2pt)[`03`]
  #cell(fill: palettes.pastel.green, width: 28pt, height: 20pt, inset: 2pt)[`21`]
]

#v(10pt)

// label-align: left — label pinned to outer edge instead of hugging body.
#grid-row(label: [Left], label-width: 80pt, label-align: left)[
  #cell(fill: palettes.pastel.red, width: 28pt, height: 20pt, inset: 2pt)[`03`]
]
