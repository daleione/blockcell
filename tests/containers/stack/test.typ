#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#stack(
  [#region(fill: palettes.pastel.blue.lighten(40%), width: 120pt)[L1 Cache]],
  [#region(fill: palettes.pastel.cyan.lighten(40%), width: 160pt)[L2 Cache]],
  [#region(fill: palettes.pastel.teal.lighten(40%), width: 200pt)[L3 Cache]],
)
