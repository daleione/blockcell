#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Divider between two enum-variant regions.
#region(fill: palettes.pastel.green.lighten(30%))[
  #tag[`Some`]
  #cell(fill: palettes.pastel.red)[`T`]
]
#divider(body: [exclusive or])
#region(fill: palettes.pastel.gray.lighten(30%))[
  #tag[`None`]
]

#v(6pt)

// Detail bar below a region.
#region[
  #cell(fill: palettes.pastel.blue)[`ptr`]
  #cell(fill: palettes.pastel.cyan)[`len`]
]
#detail[Runtime borrow count tracked here.]
