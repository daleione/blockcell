#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#cell(fill: rgb("#FA8072"))[`T`]
#h(6pt)
#text(size: 1.2em)[→]
#h(6pt)
#wrap(stroke: 3pt + rgb("#FFD700"))[
  #cell(fill: rgb("#FA8072"))[`T`]
]
#h(16pt)
#wrap(stroke: 3pt + rgb("#FFD700"))[
  #cell(fill: rgb("#00FFFF"))[`borrowed`]
]
#wrap(stroke: 3pt + rgb("#FFD700"))[
  #cell(fill: rgb("#FA8072"), expandable: true)[`T`]
]
