#import "../../lib.typ": *

= 完整示例

== 网络协议：IPv4 + TCP（使用 `bit-row`）

#let N = palettes.network

#section[IPv4 + TCP Header][
  #text(weight: "bold")[IPv4 Header]
  #v(4pt)
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 4,  label: [Ver],          fill: N.meta),
    (bits: 4,  label: [IHL],          fill: N.meta),
    (bits: 8,  label: [DSCP],         fill: N.flag),
    (bits: 16, label: [Total Length], fill: N.addr),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 8,  label: [TTL],          fill: N.meta),
    (bits: 8,  label: [Protocol],     fill: N.meta),
    (bits: 16, label: [Hdr Checksum], fill: N.checksum),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Source Address], fill: N.addr),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Destination Address], fill: N.addr),
  ))
  #v(8pt)
  #text(weight: "bold")[TCP Segment]
  #v(4pt)
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 16, label: [Src Port], fill: N.transport),
    (bits: 16, label: [Dst Port], fill: N.transport),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Sequence Number], fill: N.meta),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 4,  label: [Off],    fill: N.meta),
    (bits: 4,  label: [Rsv],    fill: N.reserved, dash: "dashed"),
    (bits: 8,  label: [Flags],  fill: N.flag),
    (bits: 16, label: [Window], fill: N.meta),
  ))
]

== Rust：Cell 类型族（使用 `wrap`）

#let R = palettes.rust

#schema(title: raw("UnsafeCell<T>"), desc: [允许别名可变性。])[
  #region(fill: R.cell-bg)[
    #cell(fill: R.any, expandable: true)[`T`]
  ]
]#schema(title: raw("Cell<T>"), desc: [移入移出 `T`。])[
  #region[
    #wrap(stroke: 3pt + R.cell-border)[
      #cell(fill: R.any, expandable: true)[`T`]
    ]
  ]
]#schema(title: raw("RefCell<T>"), desc: [动态借用检查。])[
  #region[
    #wrap(stroke: 3pt + R.cell-border)[
      #cell(fill: R.sized)[`borrowed`]
    ]
    #wrap(stroke: 3pt + R.cell-border)[
      #cell(fill: R.any, expandable: true)[`T`]
    ]
  ]
]#schema(title: raw("Option<T>"), desc: [Some 或 None。])[
  #region(fill: R.enum-bg)[#tag[`Tag`]]
  #divider(body: [or])
  #region(fill: R.enum-bg)[#tag[`Tag`] #cell(fill: R.any, width: 50pt)[`T`]]
]

== 缓存层次与 MESI（使用 `legend`）

#let K = palettes.cache
#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)

// Share a fixed label width so the three rows align tabularly.
#let mrow = grid-row.with(label-width: 40pt)

#section[MESI Protocol][
  #legend(
    (label: [#strong[M]odified],  fill: K.modified),
    (label: [#strong[E]xclusive], fill: K.exclusive),
    (label: [#strong[S]hared],    fill: K.shared),
    (label: [#strong[I]nvalid],   fill: K.invalid),
  )
  #v(8pt)
  #mrow(label: [Memory])[
    #mc(fill: K.data)[`03`] #mc(fill: K.data)[`FF`]
    #mc(fill: K.data)[`7F`] #mc(fill: K.data)[`A0`]
  ]
  #mrow(label: [CPU 0])[
    #mc(fill: K.shared, overlay: [S])[`03`]
    #mc(fill: K.shared, overlay: [S])[`FF`]
    #mc(fill: K.shared, overlay: [S])[`7F`]
    #mc(fill: K.shared, overlay: [S])[`A0`]
  ]
  #mrow(label: [CPU 1])[
    #mc(fill: K.shared, overlay: [S])[`03`]
    #mc(fill: K.shared, overlay: [S])[`FF`]
    #mc(fill: K.shared, overlay: [S])[`7F`]
    #mc(fill: K.shared, overlay: [S])[`A0`]
  ]
]

#v(20pt)

#align(center, text(size: 0.85em, fill: luma(140))[
  blockcell v0.1.0 — 使用 Typst 构建
])
