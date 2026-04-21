#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// sub-label inside a cell, span-label under a region.
#cell(fill: palettes.pastel.blue)[`ptr`#sub-label[2/4/8]]
#cell(fill: palettes.pastel.yellow)[`Length`#sub-label[2B]]

#v(6pt)

#region[
  #cell(fill: palettes.pastel.red)[`T`]
  #cell(fill: palettes.pastel.red)[`T`]
  #note[…]
  #span-label[capacity]
]
