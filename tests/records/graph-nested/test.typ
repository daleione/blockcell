#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Multi-depth references (column 0 → column 1 → column 2) — exercises the
// per-depth column layout and arrow routing across depth boundaries.
#align(center)[
  #record-graph(title: [Person record], (
    rows: (
      (key: [name],    value: ["John"]),
      (key: [address], value: []),
      (key: [phone],   value: []),
      (key: [spouse],  value: [␀]),
    ),
    children: (
      (row: 1, node: (
        rows: (
          (key: [city],   value: ["NYC"]),
          (key: [country], value: []),
        ),
        children: (
          (row: 1, node: (rows: ((key: [code], value: [US]), (key: [name], value: ["United States"])))),
        ),
      )),
      (row: 2, node: (rows: ((key: [type], value: [home]), (key: [number], value: ["555-1234"])))),
    ),
  ))
]
