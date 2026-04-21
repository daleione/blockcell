#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Default, colored, thick-stroke, dashed, rounded, sized.
#cell[A]
#cell(fill: palettes.pastel.blue)[B]
#cell(fill: palettes.pastel.yellow, stroke: 2pt + orange)[C]
#cell(fill: palettes.pastel.green, dash: "dashed")[D]
#cell(fill: palettes.pastel.purple, radius: 4pt)[E]
#cell(width: 40pt, height: 24pt)[F]
