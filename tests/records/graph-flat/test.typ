#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// One parent + multiple children springing from the same row — exercises
// vertical stacking of siblings and the "preferred y = parent row center"
// placement rule.
#align(center)[
  #record-graph(title: [Order], (
    rows: (
      (key: [id],    value: [#42]),
      (key: [items], value: []),
    ),
    children: (
      (row: 1, node: (rows: ((key: [sku], value: [A]), (key: [qty], value: [1])))),
      (row: 1, node: (rows: ((key: [sku], value: [B]), (key: [qty], value: [3])))),
      (row: 1, node: (rows: ((key: [sku], value: [C]), (key: [qty], value: [2])))),
    ),
  ))
]
