#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Four cards covering the kind palette (class / interface / abstract /
// enum). Also exercises stereotype line, generic parameter, three
// compartments, and the per-member decorations: visibility glyph
// (+/-/#/~), abstract italic, static underline, and an unmarked row
// (vis = "") for enum constants.
#align(center)[
  #class-layout(
    classes: (
      (x: 0pt, y: 0pt, kind: "class", name: [Box],
       generic: [T],
       fields: (
         (vis: "+", body: [data: T]),
         (vis: "-", body: [count: Int], static: true),
       ),
       methods: (
         (vis: "+", body: [get(): T]),
         (vis: "#", body: [reset()], abstract: true),
       )),
      (x: 200pt, y: 0pt, kind: "interface", name: [Comparable],
       stereotype: "trait",
       fields: (),
       methods: (
         (vis: "+", body: [compare(other): Int], abstract: true),
       )),
      (x: 0pt, y: 140pt, kind: "abstract", name: [Shape],
       fields: ((vis: "#", body: [origin: Point]),),
       methods: ((vis: "+", body: [area(): Float], abstract: true),)),
      (x: 200pt, y: 140pt, kind: "enum", name: [Color],
       fields: (
         (vis: "", body: [RED]),
         (vis: "", body: [GREEN]),
         (vis: "", body: [BLUE]),
       ),
       methods: ()),
    ),
    edges: (),
  )
]
