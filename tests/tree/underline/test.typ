#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// `node(shape: "underline")` — bottom rule only, no fill. PlantUML's `_`
// modifier on mind-map / WBS nodes maps here. Mix with the default rect
// fill to verify the two coexist in the same diagram.
#align(center)[
  #tree(
    direction: "right",
    node(shape: "underline")[OS],
    node(shape: "underline")[Long term],
    node[Marketing],
    node(shape: "underline")[Engineering],
  )
]
