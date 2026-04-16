// ============================================================================
// blockcell 使用手册
// ============================================================================

#import "../lib.typ": *

#set page(width: 600pt, height: auto, margin: (x: 36pt, y: 30pt))
#set text(size: 10pt, lang: "zh", font: ("Source Han Sans SC", "PingFang SC", "Noto Sans CJK SC"))
#set par(leading: 0.8em, justify: true)
#show heading.where(level: 1): set text(size: 18pt)
#show heading.where(level: 2): it => {
  v(12pt)
  block(below: 8pt, text(size: 13pt, fill: rgb("#1565C0"), it.body))
}
#show heading.where(level: 3): it => {
  v(6pt)
  block(below: 4pt, text(size: 11pt, fill: rgb("#37474F"), it.body))
}
#show raw.where(block: true): set text(size: 8.5pt)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(246), radius: 3pt, inset: 8pt, it,
)

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
      #cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]]
      #cell(fill: rgb("#00FFFF"))[`len`#sub-label[2/4/8]]
      #cell(fill: rgb("#00FFFF"))[`cap`#sub-label[2/4/8]]
    ]
    #connector()
    #target(fill: rgb("#C6DBE7"), label: "(heap)", width: 130pt)[
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
      #note[… len]
    ]
  ]
  #schema(title: [*IPv4 Row 1*])[
    #bit-row(total: 32, width: 200pt, fields: (
      (bits: 4,  label: [Ver],  fill: rgb("#FFF9C4")),
      (bits: 4,  label: [IHL],  fill: rgb("#FFF9C4")),
      (bits: 8,  label: [DSCP], fill: rgb("#E1BEE7")),
      (bits: 16, label: [Total Len], fill: rgb("#FFF9C4")),
    ))
  ]
  #schema(title: [*enum E*])[
    #region(fill: rgb("#FAFAD2"))[
      #tag[`Tag`] #cell(fill: rgb("#FA8072"))[`A`]
    ]
    #divider(body: [exclusive or])
    #region(fill: rgb("#FAFAD2"))[
      #tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 60pt)[`B`]
    ]
  ]
]

#v(16pt)

= 简介

*blockcell* 是一个 Typst 包，用于绘制结构化的块状布局图表。通过组合简单的视觉原语（单元格、区域、连接线），可以快速构建：

- 内存布局图（栈帧、堆分配、指针关系）
- 网络协议格式（IPv4、TCP、Ethernet）
- 硬件寄存器映射
- 缓存层次结构与一致性协议
- 流水线和线程安全可视化

包的设计哲学是 *领域无关* —— 所有原语都是通用的彩色方块和容器，不绑定任何特定编程语言或技术领域。用户通过定义自己的调色板和辅助函数来适配特定领域。

== 安装

```typst
#import "@preview/blockcell:0.1.0": *
```

#v(4pt)

= API 参考

包的 API 分为三层，由底向上组合：

#align(center)[
  #grid(
    columns: 3,
    column-gutter: 12pt,
    region(fill: rgb("#E3F2FD"), width: 155pt)[
      #text(weight: "bold")[Layer 1 — 原子]
      #v(2pt)
      #text(size: 0.85em)[
        `cell` `tag` `note`\
        `badge` `sub-label`\
        `span-label` `wrap` `brace`
      ]
    ],
    region(fill: rgb("#E8F5E9"), width: 155pt)[
      #text(weight: "bold")[Layer 2 — 容器]
      #v(2pt)
      #text(size: 0.85em)[
        `region` `target`\
        `connector` `divider`\
        `detail` `entry-list`
      ]
    ],
    region(fill: rgb("#FFF3E0"), width: 155pt)[
      #text(weight: "bold")[Layer 3 — 组合]
      #v(2pt)
      #text(size: 0.85em)[
        `schema` `linked-schema`\
        `grid-row` `lane`\
        `section` `legend` `bit-row`
      ]
    ],
  )
]

#v(8pt)

== Layer 1 — 原子

=== `cell` — 单元格

最核心的原语。一个带颜色和标签的方块。

```typst
#cell(body, fill: luma(220), width: auto, height: auto,
  stroke: 0.8pt + black, dash: none, radius: 0pt,
  inset: (x: 4pt, y: 2pt), expandable: false,
  phantom: false, overlay: none, baseline: 30%)
```

#v(4pt)

常用参数：

#grid(
  columns: (80pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`fill`], [背景颜色],
  text(weight: "bold")[`stroke`], [边框样式，接受 Typst 原生 stroke（如 `3pt + gold`）],
  text(weight: "bold")[`dash`], [边框虚线：`none`、`"dashed"`、`"dotted"`],
  text(weight: "bold")[`expandable`], [显示 `← ⋯ →` 标记（表示可变大小）],
  text(weight: "bold")[`phantom`], [半透明 + 虚线边框（表示不存在 / 零大小）],
  text(weight: "bold")[`overlay`], [右上角叠加标记（如缓存状态字母）],
)

#v(6pt)

用法示例：

#align(center)[
  #cell[`A`]
  #h(6pt)
  #cell(fill: rgb("#FA8072"))[`T`]
  #h(6pt)
  #cell(fill: rgb("#00FFFF"), stroke: 3pt + rgb("#FFD700"))[`len`]
  #h(6pt)
  #cell(fill: rgb("#FA8072"), expandable: true)[`T`]
  #h(6pt)
  #cell(phantom: true, width: 20pt)[]
  #h(6pt)
  #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, overlay: [S])[`03`]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  默认 #h(16pt) 着色 #h(16pt) 粗边框 #h(12pt) 可变大小 #h(10pt) 幽灵 #h(12pt) 叠加标记
])

#v(4pt)

可以用 `.with()` 创建领域特定的辅助函数：

```typst
#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
#let type-cell(body) = cell(body, fill: rgb("#FA8072"))
#let ptr-field(l: [ptr]) = cell(fill: rgb("#87CEFA"))[#l#sub-label[2/4/8]]
```

=== `tag` — 标记单元格

虚线边框的 `cell`，用于枚举判别器、标签等。

#align(center)[
  #tag[`Tag`]
  #h(6pt)
  #tag(fill: rgb("#FFD700"))[`D`]
]

=== `note` — 注释文本

小号内联文本，用于 "… n times" 等注释。

#align(center)[
  #cell(fill: rgb("#FA8072"))[`T`]
  #cell(fill: rgb("#FA8072"))[`T`]
  #note[… n times]
]

=== `badge` — 状态徽章

紧凑的状态指示器。

#align(center)[
  #badge[STALLED]
  #h(8pt)
  #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
  #h(8pt)
  #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
]

=== `sub-label` — 下标注释

字段大小的下标标注，通常在 `cell` 内部使用。

#align(center)[
  #cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]]
  #h(8pt)
  #cell(fill: rgb("#FFF9C4"))[`Length`#sub-label[2B]]
]

=== `span-label` — 跨度标签

水平跨度指示器 `← label →`。

#align(center, box(width: 120pt)[
  #cell(fill: rgb("#FA8072"))[`T`]
  #cell(fill: rgb("#FA8072"))[`T`]
  #note[…]
  #span-label[capacity]
])

=== `wrap` — 包裹装饰器

在内容外层添加厚边框，用于双层边框效果。例如 Rust 的 `Cell<T>` 需要内层黑色细边 + 外层金色粗边：

```typst
#wrap(stroke: 3pt + gold)[
  #cell(fill: salmon)[`T`]   // 内层保留自己的黑色细边
]
```

#align(center)[
  #cell(fill: rgb("#FA8072"))[`T`]
  #h(6pt)
  #text(size: 1.2em)[→]
  #h(6pt)
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: rgb("#FA8072"))[`T`]
  ]
  #h(16pt)
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: rgb("#00FFFF"))[`borrowed`]
  ]
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: rgb("#FA8072"), expandable: true)[`T`]
  ]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  普通 cell #h(12pt) → #h(12pt) wrap 后（双层边框） #h(20pt) RefCell\<T> 效果
])

=== `brace` — 水平花括号

在一组元素下方标注范围。

#align(center, box(width: 160pt)[
  #cell(fill: rgb("#FA8072"))[`T`]
  #cell(fill: rgb("#FA8072"))[`T`]
  #cell(fill: rgb("#FA8072"))[`T`]
  #note[…]
  #brace(width: 160pt)[capacity]
])

#v(8pt)

== Layer 2 — 容器

=== `region` — 区域

带边框和背景的容器，将多个 cell 组合为一个视觉单元。

#align(center)[
  #region[
    #cell(fill: rgb("#87CEFA"))[`ptr`]
    #cell(fill: rgb("#00FFFF"))[`len`]
    #cell(fill: rgb("#00FFFF"))[`cap`]
  ]
  #h(12pt)
  #region(danger: true)[
    #cell(fill: rgb("#87CEFA"))[`ptr`]
    #cell(fill: luma(230), dash: "dashed")[`meta`]
  ]
  #h(12pt)
  #region(faded: true, width: 20pt)[]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  普通区域 #h(40pt) 危险（红色边框） #h(24pt) 淡化（零大小）
])

=== `target` — 目标区域

被引用 / 链接的区域，虚线边框，可带右下角标签。

#align(center)[
  #target(fill: rgb("#C6DBE7"), label: "(heap)", width: 120pt)[
    #cell(fill: rgb("#FA8072"))[`T`]
    #cell(fill: rgb("#FA8072"))[`T`]
  ]
  #h(12pt)
  #target(fill: rgb("#DEB887"), label: "(static)")[
    #cell(fill: rgb("#FA8072"), expandable: true)[`T`]
  ]
]

=== `connector` — 连接线

区域和目标之间的垂直连接线。

#align(center, box[
  #region[#cell(fill: rgb("#87CEFA"))[`ptr`]]
  #connector()
  #target[#cell(fill: rgb("#FA8072"))[`T`]]
])

=== `divider` — 分隔符

布局替代方案之间的文本分隔符。

#align(center, box[
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"))[`A`]]
  #divider(body: [exclusive or])
  #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 60pt)[`B`]]
])

=== `entry-list` — 条目列表

目标区域内的垂直条目列表（如函数指针表、寄存器映射）。

#align(center)[
  #entry-list(
    label: "(vtable)",
    ([`*Drop::drop(&mut T)`], [`size`], [`align`], [`*Trait::f(&T, …)`]),
  )
]

#v(8pt)

== Layer 3 — 组合

=== `schema` — 图表容器

顶层内联容器，包含标题和描述。多个 `schema` 自动水平排列。

#align(center)[
  #schema(title: raw("u8"), desc: [8-bit unsigned.])[
    #region[#cell(fill: rgb("#FA8072"), width: 40pt)[`u8`]]
  ]#schema(title: raw("[T; 3]"), desc: [Fixed array.])[
    #region[
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
    ]
  ]#schema(title: raw("Option<T>"), desc: [Some or None.])[
    #region(fill: rgb("#FAFAD2"))[#tag[`Tag`]]
    #divider(body: [or])
    #region(fill: rgb("#FAFAD2"))[#tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 50pt)[`T`]]
  ]
]

=== `linked-schema` — 链接式图表

最常用的模式：顶部字段区域通过连接线指向底部目标区域。

#align(center)[
  #linked-schema(
    title: raw("Box<T>"),
    desc: [Heap-allocated.],
    fields: (cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]],),
    target-fill: rgb("#C6DBE7"),
    target-label: "(heap)",
    cell(fill: rgb("#FA8072"), expandable: true)[`T`],
  )#linked-schema(
    title: raw("String"),
    desc: [UTF-8 string.],
    fields: (
      cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]],
      cell(fill: rgb("#00FFFF"))[`len`#sub-label[2/4/8]],
      cell(fill: rgb("#00FFFF"))[`cap`#sub-label[2/4/8]],
    ),
    target-fill: rgb("#C6DBE7"),
    target-label: "(heap)",
    target-width: 120pt,
    {
      cell(fill: rgb("#90EE90"), width: 12pt, height: 18pt, dash: "dashed", radius: 3pt, inset: 1pt)[`H`]
      cell(fill: rgb("#90EE90"), width: 12pt, height: 18pt, dash: "dashed", radius: 3pt, inset: 1pt)[`i`]
      note[… len]
    },
  )
]

=== `grid-row` — 网格行

带标签的单元格行，标签和内容垂直居中对齐。

#align(center, box(width: 360pt)[
  #grid-row(label: [Main Memory])[
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`03`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`21`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`7F`]
    #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`A0`]
  ]
  #grid-row(label: [CPU Cache])[
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`03`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`21`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`7F`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`A0`]
  ]
])

=== `lane` — 通道

水平轨道上的色彩编码项目，用于线程或流水线可视化。

#align(center, box(width: 400pt)[
  #lane(
    name: [Thread 1],
    items: (
      (label: [`Mutex<u32>`], fill: rgb("#B4E9A9")),
      (label: [`Cell<u32>`], fill: rgb("#FBF7BD")),
      (label: [`Rc<u32>`], fill: rgb("#F37142")),
    ),
  )
])

=== `section` — 分节卡片

带标题的卡片容器，用于组织相关图表。

#section[缓存一致性][
  MESI 协议通过 4 种状态协调缓存行的一致性。
  #v(4pt)
  #grid-row(label: [CPU 0])[
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`03`]
    #cell(fill: rgb("#C8E6C9"), width: 28pt, height: 20pt, inset: 2pt, overlay: [S])[`FF`]
  ]
]

=== `legend` — 色彩图例

一行代码生成色彩图例，替代手动拼 `grid` + `box`。

```typst
#legend(
  (label: [Modified], fill: orange),
  (label: [Shared],   fill: green),
  (label: [Invalid],  fill: gray),
)
```

#align(center)[
  #legend(
    (label: [Modified],  fill: rgb("#FFCC80")),
    (label: [Exclusive], fill: rgb("#B3E5FC")),
    (label: [Shared],    fill: rgb("#C8E6C9")),
    (label: [Invalid],   fill: luma(220)),
  )
]

=== `bit-row` — 比例位域行

按比特数等比缩放字段宽度，专为协议头部和寄存器映射设计。告别手动计算 `width`。

```typst
#bit-row(total: 32, width: 400pt, fields: (
  (bits: 4,  label: [Ver],          fill: yellow),
  (bits: 4,  label: [IHL],          fill: yellow),
  (bits: 8,  label: [DSCP],         fill: purple),
  (bits: 16, label: [Total Length], fill: cyan),
))
```

#align(center)[
  #bit-row(total: 32, width: 480pt, fields: (
    (bits: 4,  label: [Ver],         fill: rgb("#FFF9C4")),
    (bits: 4,  label: [IHL],         fill: rgb("#FFF9C4")),
    (bits: 8,  label: [DSCP],        fill: rgb("#E1BEE7")),
    (bits: 16, label: [Total Length], fill: rgb("#B2DFDB")),
  ))
  #v(2pt)
  #bit-row(total: 32, width: 480pt, fields: (
    (bits: 16, label: [Identification], fill: rgb("#FFF9C4")),
    (bits: 3,  label: [Flg],            fill: rgb("#E1BEE7")),
    (bits: 13, label: [Fragment Offset], fill: rgb("#FFF9C4")),
  ))
  #v(2pt)
  #bit-row(total: 32, width: 480pt, fields: (
    (bits: 8,  label: [TTL],          fill: rgb("#FFF9C4")),
    (bits: 8,  label: [Protocol],     fill: rgb("#FFF9C4")),
    (bits: 16, label: [Hdr Checksum], fill: rgb("#D1C4E9")),
  ))
]

#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  IPv4 头部前 3 行 — 每个字段宽度按比特数自动等比分配
])

#v(12pt)

= 使用模式

== 定义领域调色板

包本身不内置颜色语义。用户应根据领域定义自己的调色板：

```typst
// Rust 内存布局
#let C = (
  any: rgb("#FA8072"), ptr: rgb("#87CEFA"),
  sized: rgb("#00FFFF"), heap: rgb("#C6DBE7"),
  cell: rgb("#FFD700"),
)

// 网络协议
#let C = (
  header: rgb("#BBDEFB"), addr: rgb("#B2DFDB"),
  flag: rgb("#E1BEE7"), data: rgb("#DCEDC8"),
)
```

== 用 `.with()` 创建辅助函数

避免重复传参：

```typst
#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
#let tc(body, ..args) = cell(body, fill: C.any, ..args)
#let celled(body, fill: C.any) = wrap(
  stroke: 3pt + C.cell, cell(body, fill: fill),
)
#let ptr-field(l: [ptr]) = cell(fill: C.ptr)[#l#sub-label[2/4/8]]
```

== 让图表水平排列

`schema` 是内联盒子。将多个 `schema` *紧邻* 书写（不留空行），即可水平排列：

```typst
#schema(title: [A])[...
]#schema(title: [B])[...    // ← 紧贴前一个 ]
]#schema(title: [C])[...
]
```

若描述文字过宽导致图表撑大，可设置 `width` 约束：

```typst
#linked-schema(width: 160pt, desc: [较长描述会在此宽度内换行], ...)
```

#v(16pt)

= 完整示例

== 网络协议：IPv4 + TCP（使用 `bit-row`）

#section[IPv4 + TCP Header][
  #text(weight: "bold")[IPv4 Header]
  #v(4pt)
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 4,  label: [Ver],  fill: rgb("#FFF9C4")),
    (bits: 4,  label: [IHL],  fill: rgb("#FFF9C4")),
    (bits: 8,  label: [DSCP], fill: rgb("#E1BEE7")),
    (bits: 16, label: [Total Length], fill: rgb("#B2DFDB")),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 8,  label: [TTL],      fill: rgb("#FFF9C4")),
    (bits: 8,  label: [Protocol], fill: rgb("#FFF9C4")),
    (bits: 16, label: [Hdr Checksum], fill: rgb("#D1C4E9")),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Source Address], fill: rgb("#B2DFDB")),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Destination Address], fill: rgb("#B2DFDB")),
  ))
  #v(8pt)
  #text(weight: "bold")[TCP Segment]
  #v(4pt)
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 16, label: [Src Port], fill: rgb("#FFE0B2")),
    (bits: 16, label: [Dst Port], fill: rgb("#FFE0B2")),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 32, label: [Sequence Number], fill: rgb("#FFF9C4")),
  ))
  #bit-row(total: 32, width: 490pt, fields: (
    (bits: 4,  label: [Off],    fill: rgb("#FFF9C4")),
    (bits: 4,  label: [Rsv],    fill: luma(230), dash: "dashed"),
    (bits: 8,  label: [Flags],  fill: rgb("#E1BEE7")),
    (bits: 16, label: [Window], fill: rgb("#FFF9C4")),
  ))
]

== Rust：Cell 类型族（使用 `wrap`）

#let C-rust = (
  any: rgb("#FA8072"), sized: rgb("#00FFFF"),
  cell: rgb("#FFD700"), enum-bg: rgb("#FAFAD2"),
)

#schema(title: raw("UnsafeCell<T>"), desc: [允许别名可变性。])[
  #region(fill: C-rust.cell)[
    #cell(fill: C-rust.any, expandable: true)[`T`]
  ]
]#schema(title: raw("Cell<T>"), desc: [移入移出 `T`。])[
  #region[
    #wrap(stroke: 3pt + C-rust.cell)[
      #cell(fill: C-rust.any, expandable: true)[`T`]
    ]
  ]
]#schema(title: raw("RefCell<T>"), desc: [动态借用检查。])[
  #region[
    #wrap(stroke: 3pt + C-rust.cell)[
      #cell(fill: C-rust.sized)[`borrowed`]
    ]
    #wrap(stroke: 3pt + C-rust.cell)[
      #cell(fill: C-rust.any, expandable: true)[`T`]
    ]
  ]
]#schema(title: raw("Option<T>"), desc: [Some 或 None。])[
  #region(fill: C-rust.enum-bg)[#tag[`Tag`]]
  #divider(body: [or])
  #region(fill: C-rust.enum-bg)[#tag[`Tag`] #cell(fill: C-rust.any, width: 50pt)[`T`]]
]

== 缓存层次与 MESI（使用 `legend`）

#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)

#section[MESI Protocol][
  #legend(
    (label: [#strong[M]odified],  fill: rgb("#FFCC80")),
    (label: [#strong[E]xclusive], fill: rgb("#B3E5FC")),
    (label: [#strong[S]hared],    fill: rgb("#C8E6C9")),
    (label: [#strong[I]nvalid],   fill: luma(220)),
  )
  #v(8pt)
  #grid-row(label: [Memory])[
    #mc(fill: rgb("#FFE0B2"))[`03`] #mc(fill: rgb("#FFE0B2"))[`FF`]
    #mc(fill: rgb("#FFE0B2"))[`7F`] #mc(fill: rgb("#FFE0B2"))[`A0`]
  ]
  #grid-row(label: [CPU 0])[
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`03`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`FF`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`7F`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`A0`]
  ]
  #grid-row(label: [CPU 1])[
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`03`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`FF`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`7F`]
    #mc(fill: rgb("#C8E6C9"), overlay: [S])[`A0`]
  ]
]

#v(20pt)

#align(center, text(size: 0.85em, fill: luma(140))[
  blockcell v0.1.0 — 使用 Typst 构建
])
