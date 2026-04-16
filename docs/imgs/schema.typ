#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#schema(title: raw("u8"), desc: [8-bit unsigned.])[
  #region[#cell(fill: rgb("#FA8072"), width: 40pt)[`u8`]]
]#schema(title: raw("[T; 3]"), desc: [Fixed array.])[
  #region[
    #cell(fill: rgb("#FA8072"))[`T`]
    #cell(fill: rgb("#FA8072"))[`T`]
    #cell(fill: rgb("#FA8072"))[`T`]
  ]
]#schema(title: raw("Option<T>"), desc: [Some or None.])[
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`]]
  #divider(body: [or])
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 50pt)[`T`]]
]
