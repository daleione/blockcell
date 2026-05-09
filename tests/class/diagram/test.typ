#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Small inheritance diagram: an abstract base with two concrete
// subclasses. Exercises the title, stereotype + abstract member
// rendering, the triangle-open head shape on both solid and dashed
// edges, and edge label / multiplicity placement (the painter centers
// each on its parametric chord position).
//
// Per the painter's TB contract (codegen flips edges so source is the
// upper-rank node), `from` is the parent and `head-from` carries the
// shape that visually belongs to the parent end.
#align(center)[
  #class-layout(
    title: [Animals],
    classes: (
      (x: 100pt, y: 0pt, kind: "abstract", name: [Animal],
       stereotype: "abstract",
       fields: ((vis: "#", body: [name: String]),),
       methods: ((vis: "+", body: [speak()], abstract: true),)),
      (x: 0pt, y: 140pt, kind: "class", name: [Dog],
       fields: (), methods: ((vis: "+", body: [speak()]),)),
      (x: 200pt, y: 140pt, kind: "class", name: [Cat],
       fields: (), methods: ((vis: "+", body: [speak()]),)),
    ),
    edges: (
      (from: 0, to: 1,
       head-from: "triangle-open", head-to: "none", style: "solid",
       label: [extends],
       path: ((c1: (153pt, 100pt), c2: (25pt, 110pt), end: (25pt, 140pt)),)),
      (from: 0, to: 2,
       head-from: "triangle-open", head-to: "none", style: "dashed",
       mult-from: [1], mult-to: [\*],
       path: ((c1: (153pt, 100pt), c2: (225pt, 110pt), end: (225pt, 140pt)),)),
    ),
  )
]
