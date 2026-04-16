#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#region[
  #cell(fill: rgb("#87CEFA"))[`ptr`]
  #cell(fill: rgb("#00FFFF"))[`len`]
  #cell(fill: rgb("#00FFFF"))[`cap`]
]
#h(12pt)
#region(danger: true)[
  #cell(fill: rgb("#87CEFA"))[`ptr`]
  #cell(fill: luma(230), dash: "dashed")[`meta`]
]
#h(12pt)
#region(faded: true, width: 20pt)[]
