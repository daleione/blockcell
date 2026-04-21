#import "../../lib.typ": *

// ---------------------------------------------------------------------------

#align(center)[
  #text(size: 28pt, weight: "bold")[blockcell]
  #v(4pt)
  #text(size: 12pt, fill: luma(100))[可组合的块状单元格布局图表]
  #v(2pt)
  #text(size: 9pt, fill: luma(140))[v0.1.0]
]

#v(16pt)

// Quick visual showcase
#align(center)[
  #schema(title: raw("Vec<T>"))[
    #region[
      #cell(fill: palettes.rust.ptr)[`ptr`#sub-label[2/4/8]]
      #cell(fill: palettes.rust.sized)[`len`#sub-label[2/4/8]]
      #cell(fill: palettes.rust.sized)[`cap`#sub-label[2/4/8]]
    ]
    #connector()
    #target(fill: palettes.rust.heap, label: "(heap)", width: 130pt)[
      #cell(fill: palettes.rust.any)[`T`]
      #cell(fill: palettes.rust.any)[`T`]
      #note[… len]
    ]
  ]
  #schema(title: [*IPv4 Row 1*])[
    #bit-row(total: 32, width: 200pt, fields: (
      (bits: 4,  label: [Ver],       fill: palettes.network.meta),
      (bits: 4,  label: [IHL],       fill: palettes.network.meta),
      (bits: 8,  label: [DSCP],      fill: palettes.network.flag),
      (bits: 16, label: [Total Len], fill: palettes.network.meta),
    ))
  ]
  #schema(title: [*enum E*])[
    #region(fill: palettes.rust.enum-bg)[
      #tag[`Tag`] #cell(fill: palettes.rust.any)[`A`]
    ]
    #divider(body: [exclusive or])
    #region(fill: palettes.rust.enum-bg)[
      #tag[`Tag`] #cell(fill: palettes.rust.any, width: 60pt)[`B`]
    ]
  ]
]

#v(16pt)
