#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Short vertical edges exercising every head shape × line style. Each
// column is a pair of stub classes connected by a single Bezier; the
// painter snaps endpoints to the rendered class top/bottom edges, so
// the edges fill the gap regardless of measured class size.
#let stub(x, y, name) = (
  x: x, y: y, kind: "class", name: name, fields: (), methods: (),
)

#align(center)[
  #class-layout(
    classes: (
      // Row 1
      stub(0pt,   0pt,  [A]), stub(0pt,   60pt, [B]),
      stub(120pt, 0pt,  [C]), stub(120pt, 60pt, [D]),
      stub(240pt, 0pt,  [E]), stub(240pt, 60pt, [F]),
      // Row 2
      stub(0pt,   140pt, [G]), stub(0pt,   200pt, [H]),
      stub(120pt, 140pt, [I]), stub(120pt, 200pt, [J]),
      stub(240pt, 140pt, [K]), stub(240pt, 200pt, [L]),
    ),
    edges: (
      (from: 0,  to: 1,  head-from: "none",           head-to: "triangle-open",
       style: "solid",
       path: ((c1: (10pt,  45pt),  c2: (10pt,  55pt),  end: (10pt,  60pt)),)),
      (from: 2,  to: 3,  head-from: "none",           head-to: "triangle-filled",
       style: "dashed",
       path: ((c1: (130pt, 45pt),  c2: (130pt, 55pt),  end: (130pt, 60pt)),)),
      (from: 4,  to: 5,  head-from: "diamond-open",   head-to: "arrow-open",
       style: "solid",
       path: ((c1: (250pt, 45pt),  c2: (250pt, 55pt),  end: (250pt, 60pt)),)),
      (from: 6,  to: 7,  head-from: "diamond-filled", head-to: "arrow-open",
       style: "solid",
       path: ((c1: (10pt,  185pt), c2: (10pt,  195pt), end: (10pt,  200pt)),)),
      (from: 8,  to: 9,  head-from: "circle",         head-to: "cross",
       style: "dotted",
       path: ((c1: (130pt, 185pt), c2: (130pt, 195pt), end: (130pt, 200pt)),)),
      (from: 10, to: 11, head-from: "plus",           head-to: "circle",
       style: "solid",
       path: ((c1: (250pt, 185pt), c2: (250pt, 195pt), end: (250pt, 200pt)),)),
    ),
  )
]
