// Header image for README — showcases key diagram types side by side.
#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 10pt)

#schema(title: raw("Vec<T>"))[
  #region[
    #cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]]
    #cell(fill: rgb("#00FFFF"))[`len`#sub-label[2/4/8]]
    #cell(fill: rgb("#00FFFF"))[`cap`#sub-label[2/4/8]]
  ]
  #connector()
  #target(fill: rgb("#C6DBE7"), label: "(heap)", width: 130pt)[
    #cell(fill: rgb("#FA8072"))[`T`]
    #cell(fill: rgb("#FA8072"))[`T`]
    #note[… len]
  ]
]#schema(title: [*IPv4 Row 1*])[
  #bit-row(total: 32, width: 200pt, fields: (
    (bits: 4,  label: [Ver],  fill: rgb("#FFF9C4")),
    (bits: 4,  label: [IHL],  fill: rgb("#FFF9C4")),
    (bits: 8,  label: [DSCP], fill: rgb("#E1BEE7")),
    (bits: 16, label: [Total Len], fill: rgb("#FFF9C4")),
  ))
]#schema(title: [*enum E*])[
  #region(fill: rgb("#FAFAD2"))[
    #tag[`Tag`] #cell(fill: rgb("#FA8072"))[`A`]
  ]
  #divider(body: [exclusive or])
  #region(fill: rgb("#FAFAD2"))[
    #tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 60pt)[`B`]
  ]
]
