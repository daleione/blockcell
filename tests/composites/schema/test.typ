#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#schema(title: raw("u8"), desc: [8-bit unsigned.])[
  #region[#cell(fill: palettes.pastel.red, width: 40pt)[`u8`]]
]#schema(title: raw("[T; 3]"), desc: [Fixed array.])[
  #region[
    #cell(fill: palettes.pastel.red)[`T`]
    #cell(fill: palettes.pastel.red)[`T`]
    #cell(fill: palettes.pastel.red)[`T`]
  ]
]
