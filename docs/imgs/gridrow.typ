#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#box(width: 360pt)[
  #grid-row(label: [Main Memory])[
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`03`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`21`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`7F`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`A0`]
  ]
  #grid-row(label: [CPU Cache])[
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`03`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`21`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`7F`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`A0`]
  ]
]
