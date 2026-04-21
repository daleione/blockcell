#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#linked-schema(
  title: raw("Box<T>"),
  desc: [Heap-allocated.],
  fields: (cell(fill: palettes.pastel.blue)[`ptr`#sub-label[2/4/8]],),
  target-fill: rgb("#C6DBE7"),
  target-label: "(heap)",
  cell(fill: palettes.pastel.red, expandable: true)[`T`],
)
