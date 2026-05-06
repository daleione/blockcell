#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// `record-layout` is the painter mode — record positions and per-edge
// cubic Bezier control points are supplied directly. Exercises start /
// end snapping (curves land on the actually rendered record edges) and
// per-(record, row) dot dedup.
#align(center)[
  #record-layout(
    title: [Order],
    records: (
      (x: 0pt, y: 30pt, rows: (
        (key: [id],    value: [#42]),
        (key: [items], value: []),
      )),
      (x: 200pt, y: 0pt, rows: (
        (key: [sku], value: [A]),
        (key: [qty], value: [1]),
      )),
      (x: 200pt, y: 50pt, rows: (
        (key: [sku], value: [B]),
        (key: [qty], value: [3]),
      )),
      (x: 200pt, y: 100pt, rows: (
        (key: [sku], value: [C]),
        (key: [qty], value: [2]),
      )),
    ),
    edges: (
      (from: 0, from-row: 1, to: 1, c1: (130pt, 60pt), c2: (170pt, 25pt)),
      (from: 0, from-row: 1, to: 2, c1: (130pt, 60pt), c2: (170pt, 75pt)),
      (from: 0, from-row: 1, to: 3, c1: (130pt, 60pt), c2: (170pt, 125pt)),
    ),
  )
]
