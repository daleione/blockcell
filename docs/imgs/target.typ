#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#target(fill: rgb("#C6DBE7"), label: "(heap)", width: 120pt)[
  #cell(fill: rgb("#FA8072"))[`T`]
  #cell(fill: rgb("#FA8072"))[`T`]
]
#h(12pt)
#target(fill: rgb("#DEB887"), label: "(static)")[
  #cell(fill: rgb("#FA8072"), expandable: true)[`T`]
]
