#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Cover every arrow-head modifier the PlantUML layer knows about. Each
// fixture row uses a labeled message so the rendered head is easy to spot.
#seq-puml(
  width: 380pt,
  `
  participant A
  participant B

  A ->  B : sync (filled)
  A ->> B : async (open V)
  A -x  B : lost (x)
  A ->x B : explicit lost
  A ->o B : circle endpoint
  A ->\ B : half top
  A ->/ B : half bottom
  A --> B : return (open V)
  A -->> B : async return
`)

#v(20pt)

// Reverse direction: `<` on the left side of the dashes flips the arrow.
// PlantUML's marker modifiers (`x`/`o`/`\`/`/`) are attached to the head
// that lands at the destination, so for reversed messages they sit between
// `<` and the dashes.
#seq-puml(
  width: 380pt,
  `
  participant A
  participant B

  A <-  B : sync reversed
  A <<- B : async reversed
  A <x- B : lost reversed
  A <o- B : circle reversed
  A <\- B : half top reversed
  A </- B : half bottom reversed
`)
