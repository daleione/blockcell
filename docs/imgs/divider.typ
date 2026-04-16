#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#box[
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"))[`A`]]
  #divider(body: [exclusive or])
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 60pt)[`B`]]
]
