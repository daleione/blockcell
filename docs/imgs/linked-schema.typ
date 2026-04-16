#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#linked-schema(
  title: raw("Box<T>"),
  desc: [Heap-allocated.],
  fields: (cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]],),
  target-fill: rgb("#C6DBE7"),
  target-label: "(heap)",
  cell(fill: rgb("#FA8072"), expandable: true)[`T`],
)#linked-schema(
  title: raw("String"),
  desc: [UTF-8 string.],
  fields: (
    cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]],
    cell(fill: rgb("#00FFFF"))[`len`#sub-label[2/4/8]],
    cell(fill: rgb("#00FFFF"))[`cap`#sub-label[2/4/8]],
  ),
  target-fill: rgb("#C6DBE7"),
  target-label: "(heap)",
  target-width: 120pt,
  {
    cell(fill: rgb("#90EE90"), width: 12pt, height: 18pt, dash: "dashed", radius: 3pt, inset: 1pt)[`H`]
    cell(fill: rgb("#90EE90"), width: 12pt, height: 18pt, dash: "dashed", radius: 3pt, inset: 1pt)[`i`]
    note[… len]
  },
)
