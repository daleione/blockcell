#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Short column stretched to match a taller natural neighbor.
#match-row(
  width-ratio: (1, 1),
  gap: 8pt,
  group(label: [Tall], fill: palettes.pastel.blue.lighten(30%), width: 100%, inset: 6pt)[
    #stack(
      cell(fill: palettes.pastel.blue, width: 100%)[A],
      cell(fill: palettes.pastel.blue, width: 100%)[B],
      cell(fill: palettes.pastel.blue, width: 100%)[C],
      cell(fill: palettes.pastel.blue, width: 100%)[D],
    )
  ],
  h => group(label: [Short], fill: palettes.pastel.green.lighten(30%),
             width: 100%, height: h, inset: 6pt)[
    #cell(fill: palettes.pastel.green, width: 100%)[Only one]
  ],
)
