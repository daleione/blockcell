#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 10pt)

#box(width: 400pt)[
  #lane(
    name: [Thread 1],
    items: (
      (label: [`Mutex<u32>`], fill: rgb("#B4E9A9")),
      (label: [`Cell<u32>`], fill: rgb("#FBF7BD")),
      (label: [`Rc<u32>`], fill: rgb("#F37142")),
    ),
  )
]
