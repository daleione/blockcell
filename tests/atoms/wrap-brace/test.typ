#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// wrap adds an outer border around a cell (RefCell<T>-style).
#wrap(stroke: 3pt + rgb("#FFD700"))[
  #cell(fill: palettes.pastel.red)[`T`]
]

#v(6pt)

// brace marks a horizontal span with a centered caption.
#brace(span: 160pt)[capacity]
