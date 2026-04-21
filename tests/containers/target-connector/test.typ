#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// The canonical region → connector → target pattern.
#region[
  #cell(fill: palettes.pastel.blue)[`ptr`#sub-label[8]]
]
#connector()
#target(fill: rgb("#C6DBE7"), label: "(heap)", width: 120pt)[
  #cell(fill: palettes.pastel.red)[`T`]
  #cell(fill: palettes.pastel.red)[`T`]
]
