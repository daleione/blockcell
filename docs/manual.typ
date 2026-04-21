// ============================================================================
// blockcell 使用手册
// ============================================================================

#import "../lib.typ": *

#set page(width: 600pt, height: auto, margin: (x: 36pt, y: 30pt))
#set text(size: 10pt, lang: "zh", font: ("LXGW WenKai"))
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

= 简介

*blockcell* 是一个 Typst 包，用于绘制结构化的块状布局图表。通过组合简单的视觉原语（单元格、区域、连接线），可以快速构建：

- 内存布局图（栈帧、堆分配、指针关系）
- 网络协议格式（IPv4、TCP、Ethernet）
- 硬件寄存器映射
- 缓存层次结构与一致性协议
- 流水线和线程安全可视化

包的设计哲学是 *领域无关* —— 所有原语都是通用的彩色方块和容器，不绑定任何特定编程语言或技术领域。包内置了以视觉角色分类的调色板（状态、柔和色、分类、梯度）作为即用起点，用户也可以自行定义领域调色板和辅助函数。

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
        `span-label` `wrap`\
        `brace` `edge`
      ]
    ],
    region(fill: rgb("#E8F5E9"), width: 155pt)[
      #text(weight: "bold")[Layer 2 — 容器]
      #v(2pt)
      #text(size: 0.85em)[
        `region` `target`\
        `connector` `divider`\
        `detail` `entry-list`\
        `stack` `group`
      ]
    ],
    region(fill: rgb("#FFF3E0"), width: 155pt)[
      #text(weight: "bold")[Layer 3 — 组合]
      #v(2pt)
      #text(size: 0.85em)[
        `schema` `linked-schema`\
        `grid-row` `lane`\
        `section` `legend`\
        `bit-row` `flex-row`\
        `seq-lane`
      ]
    ],
  )
  #v(6pt)
  #region(fill: rgb("#F3E5F5"), width: 490pt)[
    #text(weight: "bold")[Palettes — 调色板（按视觉角色分类）]
    #v(2pt)
    #text(size: 0.85em)[
      `palettes.status` `palettes.pastel` `palettes.categorical` `palettes.sequential`
      #h(6pt) (+ 域示例 `rust` / `network` / `cache`)
    ]
  ]
  #v(6pt)
  #region(fill: rgb("#FFECB3"), width: 490pt)[
    #text(weight: "bold")[流程图 — 专题章节]
    #v(2pt)
    #text(size: 0.85em)[
      `process` `decision` `terminal` `junction` (`flow-node`)
      #h(4pt) `flow-col`
      #h(4pt) `branch` `branch-merge` `switch` + `case`
      #h(4pt) `flow-loop`
      #h(6pt) → 详见 "流程图" 章节
    ]
  ]
  #v(6pt)
  #region(fill: rgb("#FCE4EC"), width: 490pt)[
    #text(weight: "bold")[状态转换图 — 专题章节]
    #v(2pt)
    #text(size: 0.85em)[
      `state-chain`
      #h(4pt) `state` (`initial` / `accept`)
      #h(4pt) `loop` `jump`
      #h(6pt) → 详见 "状态转换图" 章节
    ]
  ]
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

=== `label` — 弱化标签

用于结构图中的短标签、说明文字或轻量标题，比 `note` 更偏结构说明，但比正文更轻。

#align(center)[
  #label[Memory]
  #h(10pt)
  #label[(heap)]
  #h(10pt)
  #label[Only on eviction]
]

=== `badge` — 状态徽章

紧凑的状态指示器。

#align(center)[
  #badge[STALLED]
  #h(8pt)
  #badge(status: "success")[HIT]
  #h(8pt)
  #badge(status: "danger")[MISS]
]

`status` 参数为常见语义状态提供了更短的入口：

#align(center)[
  #badge(status: "success")[OK]
  #h(4pt)
  #badge(status: "warning")[WAIT]
  #h(4pt)
  #badge(status: "danger")[ERROR]
  #h(4pt)
  #badge(status: "info")[INFO]
  #h(4pt)
  #badge(status: "neutral")[SKIP]
]

需要完全控制时，`badge` 仍然接受显式的 `fill` 和 `stroke`：

#align(center)[
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

=== `edge` — 有向连接线

带可选标签和实心三角箭头的有向线段，用于表达 "A → B" 的调用、引用、状态转移
关系。横向（`"right"` / `"left"`）是 inline 元素，夹在一行 cell 之间；纵向
（`"down"` / `"up"`）是块级元素，用在竖排节点之间（见 `flow-col`），标签贴
在线的右侧。跨容器路由请用 `cetz` / `fletcher`。

```typst
#cell[Controller] #edge(label: [HTTP]) #cell[Business]
#cell[Business]   #edge(label: [SQL], style: "dashed") #cell[MySQL]
```

#align(center)[
  #cell(fill: palettes.pastel.blue)[Controller]
  #edge(label: [HTTP])
  #cell(fill: palettes.pastel.cyan)[Business]
  #edge(label: [SQL], style: "dashed")
  #cell(fill: palettes.pastel.teal)[MySQL]
]

#v(4pt)

状态机风格 —— 用 stroke 颜色编码"成功 / 失败"语义：

#align(center)[
  #region(fill: palettes.pastel.yellow)[WAIT_BUYER_PAY]
  #edge(label: [支付成功], stroke: 1pt + green)
  #region(fill: palettes.pastel.orange)[WAIT_SELLER_SEND]
  #edge(label: [超时关单], style: "dashed", stroke: 1pt + red)
  #region(fill: palettes.status.danger.fill)[CLOSED]
]

#v(4pt)

参数：`direction` 取 `"right"` / `"left"` / `"down"` / `"up"`；`style` 取 `"solid"`、`"dashed"`、`"dotted"`；`head` 取 `"arrow"` 或 `"none"`；`length` 沿方向轴自适应或手动设定。

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

=== `stack` — 垂直堆叠

用于把多个图块按垂直方向排列。每一项都作为独立的内容块传入，这样边界更明确，也避免反复手写 `#v(...)` 或单列 `grid`。

#align(center)[
  #stack(
    [#region(fill: palettes.cache.l1.lighten(40%), width: 120pt)[
      #text(weight: "bold")[L1 Cache]
    ]],
    [#region(fill: palettes.cache.l2.lighten(40%), width: 160pt)[
      #text(weight: "bold")[L2 Cache]
    ]],
    [#region(fill: palettes.cache.l3.lighten(40%), width: 200pt)[
      #text(weight: "bold")[L3 Cache]
    ]],
  )
]

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

=== `group` — 逻辑分组外框

带左上角小标题的边框容器，用于把*多个独立子组件*圈在同一逻辑边界内。语义介于
`region`（单个结构单元，右下角小注）和 `section`（文档级卡片，顶部大标题）之间。
`dash: "dashed"` 表示逻辑分组（非物理边界）。

```typst
#let cat = palettes.categorical
#group(label: [业务层 Business], fill: cat.at(1).lighten(42%))[
  #region(fill: cat.at(1))[Business: 自有平台]
  #v(4pt)
  #region(fill: cat.at(1).lighten(10%))[Business: 外部平台同步]
  #v(4pt)
  #region(fill: cat.at(1).lighten(20%))[Business: 横向公共能力]
]
```

#align(center)[
  #group(label: [业务层 Business], fill: palettes.categorical.at(1).lighten(42%), width: 320pt)[
    #region(fill: palettes.categorical.at(1), width: 100%)[
      #text(weight: "bold")[Business: 自有平台]
    ]
    #v(4pt)
    #region(fill: palettes.categorical.at(1).lighten(10%), width: 100%)[
      #text(weight: "bold")[Business: 外部平台同步]
    ]
    #v(4pt)
    #region(fill: palettes.categorical.at(1).lighten(20%), width: 100%)[
      #text(weight: "bold")[Business: 横向公共能力]
    ]
  ]
]

#v(4pt)

可嵌套；用 `fill` 深浅区分层级。

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

=== `seq-lane` — 时序图

声明式 UML 时序图。与 `lane`（"状态随时间走"）互补，`seq-lane` 表达
"参与者之间互相调用"。覆盖 UML 标准词汇：跨参与者消息、回调、自调用、
控制焦点（activation）、组合片段（alt / opt / loop / par）、便签。

*Step 构造函数* —— Step 由 `seq-*` 构造，直接以位置参数传给 `seq-lane`：

#grid(
  columns: (160pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`seq-call(from, to)[..]`],
  [同步消息（实线 + 实心三角箭头）；`from == to` 时自动渲染为自调用 U 形回环],
  text(weight: "bold")[`seq-ret(from, to)[..]`],
  [回调（虚线 + 开口 V 形箭头）],
  text(weight: "bold")[`seq-note(over)[..]`],
  [便签（折角矩形）；`over` 取单个 id 或 `("a","b")` 跨多列],
  text(weight: "bold")[`seq-act(who)[..]`],
  [单参与者列内的工作块],
  text(weight: "bold")[`seq-alt(cond, ..)`],
  [可选分支组合片段；首参为条件（方括号内容），其余为嵌套 step],
  text(weight: "bold")[`seq-opt` / `seq-loop` / `seq-par`],
  [同上，分别对应 opt / loop / par 片段语义],
)

#v(4pt)

*参与者* —— 从 step id 按首次出现顺序自动推导，颜色循环使用 `palettes.categorical`。
传 `participants:` 可自定义显示名或颜色（按 id 局部覆盖，用户顺序优先）。

*控制焦点* —— 默认开启。每个 `seq-call` 在目标列生命线上开启一段活动区间，
匹配的 `seq-ret` 关闭。`call` 的实心三角与 `ret` 的开口 V 头形不同，便于一眼
区分请求与回复。用 `activate: false` 关闭，`activation-width` 调整矩形宽度。

*组合片段* —— `seq-alt` / `seq-opt` / `seq-loop` / `seq-par` 以位置参数嵌套，
渲染为虚线框 + 左上角小标签 + 方括号条件。天然支持任意层嵌套。

#v(4pt)

*示例* —— 用户登录流程，涵盖跨参与者调用、自调用、便签、alt 分支与回调：

```typst
#seq-lane(
  participants: (
    (id: "browser", name: [Browser]),
    (id: "api",     name: [API]),
    (id: "auth",    name: [Auth Service]),
    (id: "db",      name: [Database]),
  ),
  seq-call("browser", "api")[POST /login],
  seq-call("api", "api")[validate input],
  seq-alt([credentials provided],
    seq-call("api", "auth")[authenticate(user, pwd)],
    seq-call("auth", "db")[SELECT user],
    seq-ret("db", "auth")[user row],
    seq-note("auth")[bcrypt compare],
    seq-ret("auth", "api")[session token],
  ),
  seq-ret("api", "browser")[200 + Set-Cookie],
)
```

#align(center)[
  #seq-lane(
    width: 460pt,
    participants: (
      (id: "browser", name: [Browser]),
      (id: "api",     name: [API]),
      (id: "auth",    name: [Auth Service]),
      (id: "db",      name: [Database]),
    ),
    seq-call("browser", "api")[POST /login],
    seq-call("api", "api")[validate input],
    seq-alt([credentials provided],
      seq-call("api", "auth")[authenticate(user, pwd)],
      seq-call("auth", "db")[SELECT user],
      seq-ret("db", "auth")[user row],
      seq-note("auth")[bcrypt compare],
      seq-ret("auth", "api")[session token],
    ),
    seq-ret("api", "browser")[200 + Set-Cookie],
  )
]

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

=== `flex-row` — 按比例分配列宽

用 `flex` 权重（类似 CSS `flex-grow`）切分行内宽度，告别手写 `width: NNpt`。
每项是 `(flex:, body:)` 字典，列宽 = `flex / sum(flex) * 行宽`。底层是 Typst 的
`fr` 列单元。

```typst
#flex-row(
  (flex: 1, body: cell(fill: blue)[Category Tree]),
  (flex: 1, body: cell(fill: cyan)[Product Card]),
  (flex: 2, body: cell(fill: teal)[Search Index]),  // 2× 宽
)
```

#align(center, box(width: 480pt)[
  #let Q = palettes.sequential
  #flex-row(gap: 4pt,
    (flex: 1, body: cell(fill: Q.blue.at(0), width: 100%)[Category Tree]),
    (flex: 1, body: cell(fill: Q.blue.at(2), width: 100%)[Product Card]),
    (flex: 2, body: cell(fill: Q.blue.at(4), width: 100%)[Search Index]),
  )
])

#v(4pt)

子元素默认 `width: auto`（保留自身宽度）；要让它填满所分列宽，显式传
`width: 100%`。`width: auto`（默认）让整行撑满父容器，可传显式长度固定宽度。

== 调色板

包通过 `palettes` 命名空间提供一组按 *视觉角色* 分类的内置调色板，开箱即用。无需手写 RGB 字典。

=== `palettes.status` — 语义状态

每种状态都是一个 `(fill, stroke)` 对，直接用 `..` 展开传给任何接受这两个参数的函数。对 `badge` 来说，包还提供了更短的 `status` 参数入口。

```typst
#badge(status: "success")[OK]
#cell(..palettes.status.danger)[Error]
```

#align(center)[
  #badge(status: "success")[SUCCESS]
  #h(4pt)
  #badge(status: "warning")[WARNING]
  #h(4pt)
  #badge(status: "danger")[DANGER]
  #h(4pt)
  #badge(status: "info")[INFO]
  #h(4pt)
  #badge(status: "neutral")[NEUTRAL]
]

#v(2pt)

键：`success` `warning` `danger` `info` `neutral` —— 每个都是 `(fill:, stroke:)` 字典。需要深色用作文字时取 `.stroke`：

```typst
#text(fill: palettes.status.info.stroke)[note]
```

=== `palettes.pastel` — 13 色命名柔和色

通用基础色。需要 "一个好看的蓝" 时直接用。

```typst
#cell(fill: palettes.pastel.blue)[Inbox]
```

#align(center)[
  #let swatch(name) = cell(fill: palettes.pastel.at(name), width: 34pt, height: 22pt)[
    #text(size: 0.72em)[#name]
  ]
  #swatch("red")  #swatch("pink")  #swatch("purple") #swatch("indigo")
  #swatch("blue") #swatch("cyan")  #swatch("teal")   #swatch("green")
  #swatch("lime") #swatch("yellow") #swatch("orange") #swatch("brown")
  #swatch("gray")
]

#v(2pt)

键：`red` `pink` `purple` `indigo` `blue` `cyan` `teal` `green` `lime` `yellow` `orange` `brown` `gray`。

=== `palettes.categorical` — 8 色分类数组

8 种彼此可区分的颜色组成的*数组*。按索引 `.at(i)` 取色——适合图例、N 分组、数据系列。

```typst
#for (i, label) in ([Alpha], [Beta], [Gamma]).enumerate() {
  cell(fill: palettes.categorical.at(i))[#label]
}
```

#align(center)[
  #for (i, label) in (
    [Design], [Engineering], [Marketing], [Sales],
    [Support], [Finance], [Legal], [Ops],
  ).enumerate() {
    cell(fill: palettes.categorical.at(i), width: 50pt, height: 22pt)[
      #text(size: 0.8em)[#label]
    ]
  }
]

=== `palettes.sequential` — 明度梯度

5 组单色梯度（`blue`、`green`、`orange`、`purple`、`gray`），每组 5 阶（浅→深）。适合等级、强度、热力图式编码。

```typst
#for lvl in range(5) {
  cell(fill: palettes.sequential.blue.at(lvl))[L#lvl]
}
```

#align(center)[
  #grid(
    columns: (auto, auto),
    column-gutter: 8pt,
    row-gutter: 4pt,
    align: (right + horizon, left + horizon),
    ..(for hue in ("blue", "green", "orange", "purple", "gray") {
      (
        text(size: 0.8em, weight: "bold")[#hue],
        {
          for lvl in range(5) {
            cell(fill: palettes.sequential.at(hue).at(lvl), width: 36pt, height: 20pt)[
              #text(size: 0.75em, fill: if lvl < 2 { black } else { white }, weight: "bold")[L#lvl]
            ]
          }
        },
      )
    })
  )
]

=== 域示例

以下三个调色板是官方示例文档使用的域调色板。可以直接用，可以复制改键，也可以完全忽略。

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[`palettes.rust`],
  text(weight: "bold", size: 0.9em)[`palettes.network`],
  text(weight: "bold", size: 0.9em)[`palettes.cache`],
  text(size: 0.8em)[Rust 内存布局\ （any/ptr/sized/heap...）],
  text(size: 0.8em)[TCP/IP 协议头\ （link/addr/flag/meta...）],
  text(size: 0.8em)[CPU 缓存层次 + MESI\ （l1/l2/l3/ram/modified...）],
)

#v(8pt)

= 流程图

*blockcell* 内置一套完整的流程图工具，覆盖线性流程、条件分支、N 路分发、循环
回流等常见结构。本章作为独立专题，自底向上依次介绍：*节点 → 容器 → 分支 →
循环*，每节配有可直接复制的代码与渲染效果。

适用范围：*自顶向下*、以树形嵌套表达的结构化流程图（业务流程、API 调用链、
状态转移等）。非树形 2D 拓扑（对角线箭头、跨层连线、自由 DAG）请使用
`fletcher` / `cetz`。

#v(6pt)

#align(center)[
  #region(fill: rgb("#FFECB3"), width: 490pt)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[节点],
      text(size: 0.85em)[`process` / `decision` / `terminal` / `junction`（别名，带默认色）· `flow-node`（底层）],
      text(size: 0.85em, weight: "bold")[纵向容器],
      text(size: 0.85em)[`flow-col` 自动插入下行箭头；节点上加 `edge-label:` 标注进入它的那条箭头],
      text(size: 0.85em, weight: "bold")[分支],
      text(size: 0.85em)[`branch`（不汇合）·`branch-merge`（汇合）·`switch` + `case(label, body)`（N 路）],
      text(size: 0.85em, weight: "bold")[循环],
      text(size: 0.85em)[`flow-loop` 带左侧回边],
    )
  ]
]

== 节点形状

语义别名按流程图的颜色惯例自带默认色——无需每次都写 `fill:`：

#grid(
  columns: (110pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[`process`], [矩形执行步骤；默认 `pastel.blue`],
  text(weight: "bold")[`decision`], [菱形条件判断；默认 `pastel.yellow`，宽度自动适配文字],
  text(weight: "bold")[`terminal`], [胶囊开始/结束；默认 `pastel.green`],
  text(weight: "bold")[`junction`], [圆形跨页锚点；默认 `pastel.cyan`，`size:` 控制直径],
  text(weight: "bold")[`flow-node`], [底层构造函数；想要额外的 `shape: "circle"` 或自定义配色时直接调用],
)

#v(4pt)

```typst
#process[Process]
#decision[Go?]
#terminal[Start / End]
#junction[1]
```

#align(center)[
  #process[Process]
  #h(8pt)
  #decision[Go?]
  #h(8pt)
  #terminal[Start / End]
  #h(8pt)
  #junction[1]
]

#v(4pt)

*状态色快捷方式：* 所有节点支持 `status:`（对应 `palettes.status` 的 5 个键），
一键切成语义状态色并同时设置 fill 和 stroke。典型用法是错误出口：

```typst
#terminal(status: "danger")[Exit]
#process(status: "warning")[Retry]
```

#align(center)[
  #terminal(status: "danger")[Exit]
  #h(8pt)
  #process(status: "warning")[Retry]
]

#v(4pt)

当然也可以覆盖默认 `fill` / `stroke` / `width` / `height` / `inset` 来自定义。

== 线性流程：`flow-col`

把节点竖排为一条流水线，相邻节点之间自动插入向下箭头。要给某条箭头加标签，
给 *目标节点* 传 `edge-label:`——即"标注那条指向我的箭头"。这种写法
不依赖下标，插入/移动节点不会错位：

```typst
#flow-col(
  terminal[Start],
  process[Load config],
  decision[Config valid?],
  process(edge-label: [Yes])[Start server],
  terminal(status: "danger")[Exit],
)
```

#align(center)[
  #flow-col(
    terminal[Start],
    process[Load config],
    decision[Config valid?],
    process(edge-label: [Yes])[Start server],
    terminal(status: "danger")[Exit],
  )
]

#v(4pt)

`flow-col` 是流程图的 *纵向骨架*——后面介绍的 `branch` / `branch-merge` /
`switch` / `flow-loop` 都被设计为直接塞进 `flow-col` 当作"加胖了的一节"。

== 条件分支：`branch` vs. `branch-merge`

两种 if-else 形态，区别在 No 路径是否回到主干：

#grid(
  columns: (110pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[`branch`], [
    Yes 向下继续主路径，No 向右散出 —— *两条路不汇合*。
    适合主流程 + 异常/快速返回。
  ],
  text(weight: "bold")[`branch-merge`], [
    Yes / No 并列两列展开，底部通过水平汇合线重新汇入单一出口 ——
    *两条路归一*。适合都回到主流程的 if-else。
  ],
)

=== `branch` — No 分支不汇合

```typst
#flow-col(
  terminal[Start],
  process[Load config],
  branch([Config valid?],
    yes: process[Start server],
    no:  process(status: "danger")[Log error + exit],
  ),
  terminal[Ready],
)
```

#align(center)[
  #flow-col(
    terminal[Start],
    process[Load config],
    branch([Config valid?],
      yes: process[Start server],
      no:  process(status: "danger")[Log error + exit],
    ),
    terminal[Ready],
  )
]

#v(4pt)

#grid(
  columns: (110pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`cond`], [菱形内的说明文字（位置参数）],
  text(weight: "bold")[`yes`], [Yes 分支（向下）；`none` 时止于菱形，由外层 `flow-col` 接续],
  text(weight: "bold")[`no`], [No 分支（向右）；`none` 则不渲染替代分支],
  text(weight: "bold")[`yes-label` / `no-label`], [箭头标签，默认 `[Yes]` / `[No]`],
  text(weight: "bold")[`diamond-width`], [菱形宽度，默认 120pt],
)

#v(4pt)

`yes` / `no` 接受任意内容，可以嵌套 `flow-col` 或再套 `branch` 表达子流程。

=== `branch-merge` — Yes/No 底部汇合

```typst
#flow-col(
  process[Parse request],
  branch-merge([Cached?],
    yes: process(fill: palettes.pastel.green)[Return cached],
    no:  process(fill: palettes.pastel.orange)[Compute + cache],
  ),
  process[Respond],
)
```

#align(center)[
  #flow-col(
    process[Parse request],
    branch-merge([Cached?],
      yes: process(fill: palettes.pastel.green)[Return cached],
      no:  process(fill: palettes.pastel.orange)[Compute + cache],
    ),
    process[Respond],
  )
]

#v(4pt)

#grid(
  columns: (110pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`merge`], [`false` 关闭底部汇合线，退化为两列并列],
  text(weight: "bold")[`col-gap`], [两列间距，默认 40pt],
  text(weight: "bold")[`diamond-width`], [菱形宽度，默认 120pt],
)

== N 路分支：`switch`

`branch-merge` 的泛化，任意数量分支从菱形分发、底部汇合。case 用 `case(label,
body)` 构造器声明（位置参数），`label` 作为从菱形下行的箭头注释：

```typst
#flow-col(
  process[Receive event],
  switch([event.kind],
    case([order],  process(fill: palettes.pastel.green)[Place order]),
    case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
    case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
  ),
  process[Emit audit log],
)
```

#align(center)[
  #flow-col(
    process[Receive event],
    switch([event.kind],
      case([order],  process(fill: palettes.pastel.green)[Place order]),
      case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
      case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
    ),
    process[Emit audit log],
  )
]

#v(4pt)

列宽统一取所有 case body 的最大宽度以保证对称（奇数 case 时中列落在菱形主轴
上）。命名参数与 `branch-merge` 一致；默认 `diamond-width: 140pt`、
`col-gap: 24pt`（更紧凑以容纳更多分支）。

== 循环：`flow-loop`

把一段流程包成"循环体"，左侧自动画一条回边：*body 底部中心 → 向左 → 向上 →
向右，以向下箭头重新插入 body 顶部中心*。

典型搭配：body 放一个 `flow-col`，内含一个 `branch`——一路是循环出口，另一路
由回边回到顶部：

```typst
#flow-loop(
  flow-col(
    process[Poll queue],
    process[Handle job],
    branch([More work?],
      yes: process[Continue],
      no:  terminal(status: "danger")[Shutdown],
    ),
  ),
  back-label: [continue],
)
```

#align(center)[
  #flow-loop(
    flow-col(
      process[Poll queue],
      process[Handle job],
      branch([More work?],
        yes: process[Continue],
        no:  terminal(status: "danger")[Shutdown],
      ),
    ),
    back-label: [continue],
  )
]

#v(4pt)

#grid(
  columns: (110pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`back-label`], [回边标签；`none` 隐藏（默认 `[retry]`）],
  text(weight: "bold")[`arm`], [回边到 body 主列（中心）的横向距离，默认 80pt。按主列度量——即使 body 含侧出分支导致宽度很大，回边也始终贴近主列],
)

== 选型速查

#align(center)[
  #region(width: 490pt)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[`flow-col`], [纯线性：Start → A → B → End],
      text(weight: "bold")[`branch`], [主线 + 一路侧出不汇合（异常/快速返回/终止）],
      text(weight: "bold")[`branch-merge`], [Yes/No 都属于主流程，最终汇回同一出口],
      text(weight: "bold")[`switch`], [3 路及以上分支（`event.kind`、`status` 枚举等）],
      text(weight: "bold")[`flow-loop`], [循环/重试；通常包一个含出口 `branch` 的 `flow-col`],
    )
  ]
]

#v(6pt)

这几个组合都是块级图元，可以 *自由嵌套*：`branch-merge` 的某一臂里再塞
`switch`、`flow-loop` 里包 `branch-merge` 都是合法的。复杂流程通过树状嵌套即可
描述，无需手动摆放坐标。

#v(8pt)

= 状态转换图

*blockcell* 内置一层状态机专用图元——`state-chain`。两种模式共用同一个渲染器：

- *线性模式*：状态不带 `pos:`，按出现顺序自动左→右排列，相邻状态之间自动画箭头。
  适合链式流程（文件 I/O、连接握手、订单阶段……）。
- *2D 模式*：任一状态带上 `pos: (col, row)`，立刻切换为坐标网格——所有边都要
  用 `jump` 显式声明，`bend:` 参数控制曲率，可画任意拓扑（订阅状态流转、复杂
  协议状态机……）。

两种模式下 `loop` / `jump` 都用 id 交叉引用，顺序随写随放。

#v(6pt)

#align(center)[
  #region(fill: rgb("#FCE4EC"), width: 490pt)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[状态节点],
      text(size: 0.85em)[`state(id)` —— 圆形自适应；`initial` / `accept` 着色 + 双边框；可选 `pos: (col, row)` 切 2D],
      text(size: 0.85em, weight: "bold")[链上转移],
      text(size: 0.85em)[线性模式下，目标节点的 `edge-label:` 给相邻自动箭头加标],
      text(size: 0.85em, weight: "bold")[自环],
      text(size: 0.85em)[`loop(id)[label]` —— 四向任选：`above` / `below` / `left` / `right`],
      text(size: 0.85em, weight: "bold")[单向转移],
      text(size: 0.85em)[`jump(from, to)[label]` —— 线性模式用 `route:`，2D 模式用 `bend:` 控制曲率],
      text(size: 0.85em, weight: "bold")[双向转移],
      text(size: 0.85em)[`bi-jump(from, to, forward:, back:)` —— 一条线两头箭头，两端各一标签（2D 专用）],
      text(size: 0.85em, weight: "bold")[容器],
      text(size: 0.85em)[`state-chain(..items)` 把所有节点和覆盖层混排传入即可],
    )
  ]
]

== 快速上手

经典的文件 I/O 状态机：`reading → eof → closed`，`reading` 可自环读下一块，
也可直接 `close()` 跳到 `closed`：

```typst
#state-chain(
  state("reading", initial: true)[reading],
  state("eof",    edge-label: [`read()`])[eof],
  state("closed", edge-label: [`close()`], accept: true)[closed],
  loop("reading")[`read()`],
  jump("reading", "closed", route: "below")[`close()`],
)
```

#align(center)[
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof",    edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],
    loop("reading")[`read()`],
    jump("reading", "closed", route: "below")[`close()`],
  )
]

#v(6pt)

读法：链上的状态按出现顺序左→右排；相邻两状态之间自动画前向箭头，箭头标签
由 *后一个状态* 的 `edge-label:` 提供。`loop` / `jump` 按 id 引用状态，顺序不
重要，写在 `state-chain` 里哪都行。

== `state` — 状态节点

```typst
#state("id", pos: none, initial: false, accept: false, edge-label: none,
       fill: none, size: auto)[显示名]
```

*核心参数：*

#grid(
  columns: (110pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[id], [字符串，供 `loop` / `jump` 交叉引用（*位置参数*）],
  text(weight: "bold")[*body*], [尾随内容块，是圆内的显示标签],
  text(weight: "bold")[`pos`], [`(col, row)` 二元组（支持浮点），任意状态带上就切 2D 模式],
  text(weight: "bold")[`initial`], [设为 `true` → 默认绿底，自动画灰色入口小圆点 + 进入箭头],
  text(weight: "bold")[`accept`], [设为 `true` → 默认黄底 + 双边框（UML 的"接受状态"）],
  text(weight: "bold")[`edge-label`], [线性模式下，*进入* 本状态的自动箭头的标签（2D 模式忽略）],
  text(weight: "bold")[`fill`], [自定义填充色，覆盖默认],
  text(weight: "bold")[`size`], [固定直径；默认按 body 自适应，下限 44pt],
)

#v(4pt)

*默认配色约定：*

#align(center)[
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.green, stroke: 0.8pt + black) #h(4pt)
    `initial` 绿色
  ]
  #h(12pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.yellow, stroke: 0.8pt + black) #h(4pt)
    `accept` 黄色 + 双边框
  ]
  #h(12pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.blue, stroke: 0.8pt + black) #h(4pt)
    普通 蓝色
  ]
]

#v(6pt)

三类状态颜色不同，一眼能区分链首、链尾和中间态。`fill:` 显式设置会覆盖默认色。

== `loop` — 自环

```typst
#loop("id")[label]                        // 默认在状态上方
#loop("id", route: "below")[label]
#loop("id", route: "left")[label]         // 四向任选
#loop("id", style: "dashed")[label]
```

在指定 id 的状态上画一段回到自身的小弧，带标签。`route` 可选 `"above"`（默认）/
`"below"` / `"left"` / `"right"`；`style: "dashed"` 画虚线弧（表示可选/条件
转移）。2D 模式下四向都有意义；线性模式下一般用上/下，避免和主链冲突。

== `jump` — 单向转移

```typst
// 线性模式：按 route 走链上方/下方的大弧
#jump("from", "to", route: "below")[label]

// 2D 模式：按 bend 控制曲率；可省略标签
#jump("from", "to", bend: 0.15)[label]
#jump("from", "to")                       // 直线，无标签

// 标签沿线挪位 / 翻到另一侧，用来避让邻近状态。
#jump("a", "b", label-pos: 0.3)[label]    // label-pos 0–1：沿线位置
#jump("a", "b", label-side: -1)[label]    // ±1：+perp / -perp 一侧
```

从 `from` 到 `to` 画一条*单向*连线：

- *线性模式*下，`route: "above" / "below"` 决定弧往链的哪一边走；算法对正向
  （from 在左）和反向（from 在右）两种写法对称。
- *2D 模式*下，`bend` 是有符号曲率比（典型 `0.1`–`0.3`）；正值把曲线向"直线
  方向的视觉左侧"偏，可用于绕开中间状态或分离重叠的平行边。
- *标签避让*：`label-pos`（默认 `0.5` 中点）沿直线挪位；`label-side`（默认
  `+1`）翻到另一侧。默认 `+perp` 一侧若指向邻近的某个状态，把 `label-side`
  改成 `-1` 即可让标签回到本线对面。
- `style: "dashed"` 画虚线（表示"软转移"）。

双向转移（A ↔ B）用 *`bi-jump`* 而不是写两条相反方向的 `jump`——后者画出来
是两条平行箭头，前者只画一条线、两头加箭头，更符合状态图惯例，也省一次写
相同坐标/参数。

== `bi-jump` — 双向转移（2D 专用）

```typst
#bi-jump("a", "b",
  forward: [a→b label],   // 标注 a → b 方向，显示在靠近 b 的那一端
  back:    [b→a label],   // 标注 b → a 方向，显示在靠近 a 的那一端
  bend: 0,                // 默认直线，需要绕开时再加
)

// 两个标签默认镜像放在线两侧（forward=+perp, back=-perp）。
// 如果默认一侧压到旁边某根线上，把两个 side 设成同号即可把标签并到
// 同一侧（沿线的两个不同 t 位置自然不会互相压字）。
#bi-jump("active", "grace",
  forward: [...], back: [...],
  back-side: 1,          // 两个标签都放到 +perp 一侧
)
```

一条线上同时画两头箭头：

- `forward` 在靠近 `to` 的一端，默认放在线的 `+perp` 一侧（"直线方向的视觉
  左侧"）。
- `back` 在靠近 `from` 的一端，默认放在 `-perp` 一侧。
- `forward-side` / `back-side` 取值 `±1`，分别控制两个标签在哪一侧。两者
  同号 ⇒ 并到同一侧；异号 ⇒ 镜像分两侧（默认）。

== 综合示例：TCP 连接生命周期

展示多条 jump 和双向转移的画法——TCP 从 `CLOSED` 开始，经 `LISTEN` /
`SYN_RECVD` 到 `ESTABLISHED`，空闲时会回到 `CLOSED`：

```typst
#state-chain(
  state("closed", initial: true, accept: true)[CLOSED],
  state("listen",    edge-label: [listen()])[LISTEN],
  state("syn-recvd", edge-label: [SYN recv])[SYN_RECVD],
  state("established", edge-label: [ACK])[ESTABLISHED],
  loop("listen")[SYN recv],
  jump("established", "closed", route: "below", style: "dashed")[close()],
  jump("listen", "closed", route: "above", style: "dashed")[close()],
)
```

#align(center)[
  #state-chain(
    state("closed", initial: true, accept: true)[CLOSED],
    state("listen",    edge-label: [listen()])[LISTEN],
    state("syn-recvd", edge-label: [SYN recv])[SYN_RECVD],
    state("established", edge-label: [ACK])[ESTABLISHED],
    loop("listen")[SYN recv],
    jump("established", "closed", route: "below", style: "dashed")[close()],
    jump("listen", "closed", route: "above", style: "dashed")[close()],
  )
]

#v(4pt)

注意：
- `CLOSED` 同时有 `initial` 和 `accept`——初始状态的语义胜出，填充色取绿色，
  双边框仍画（来自 `accept`）。
- 两条 `close()` 用 `style: "dashed"` 表示"软关闭"，视觉上和主链实线区分。
- 一条 `above` 一条 `below`，避免多条弧在同一侧堆叠。

== 2D 模式：任意拓扑

当状态之间不是简单的线性顺序——比如订阅/订单流转里 active 可以绕三角进到
billing retry、grace period、revoke、expired——给每个 `state` 加上 `pos: (col,
row)`，其余 API 不变，`state-chain` 自动切到 2D：

```typst
#state-chain(
  col-gap: 115pt, row-gap: 115pt,

  state("active",  pos: (0, 0), initial: true)[active],
  state("billing", pos: (3, 0), fill: palettes.pastel.yellow)[billing \ retry],
  state("grace",   pos: (1, 0.8), fill: palettes.pastel.green)[grace \ period],
  state("revoke",  pos: (2, 0.8), fill: palettes.pastel.red)[revoke],
  state("expired", pos: (1.5, 2.3), fill: palettes.pastel.red)[expired],

  loop("active", route: "above")[正常续期],

  // 双向转移：一条线、两头箭头、两端各一个标签
  bi-jump("active", "billing",
    forward: [60天内扣款失败],
    back:    [60天内成功续期],
  ),
  // active↔grace 默认 back 一侧正好压到 active→expired 线上，
  // 用 back-side: 1 把两个标签并到 +perp 同一侧。
  bi-jump("active", "grace",
    forward: [取消订阅],
    back:    [开启订阅],
    back-side: 1,
  ),

  jump("grace",   "revoke")[取消订阅],
  jump("billing", "revoke"),

  jump("grace",   "expired")[宽限期未续订],
  // active→expired 默认 +perp 一侧指向 grace；翻到另一侧让标签
  // 可视化地属于自己这条线。billing→expired 默认一侧正好朝外，不用翻。
  jump("active",  "expired", label-side: -1)[取消订阅],
  jump("billing", "expired")[取消订阅 or 60天后仍扣款失败],
)
```

#align(center)[
  #state-chain(
    col-gap: 115pt, row-gap: 115pt,

    state("active",  pos: (0, 0), initial: true)[active],
    state("billing", pos: (3, 0), fill: palettes.pastel.yellow)[billing \ retry],
    state("grace",   pos: (1, 0.8), fill: palettes.pastel.green)[grace \ period],
    state("revoke",  pos: (2, 0.8), fill: palettes.pastel.red)[revoke],
    state("expired", pos: (1.5, 2.3), fill: palettes.pastel.red)[expired],

    loop("active", route: "above")[正常续期],

    bi-jump("active", "billing",
      forward: [60天内扣款失败],
      back:    [60天内成功续期],
    ),
    bi-jump("active", "grace",
      forward: [取消订阅],
      back:    [开启订阅],
      back-side: 1,
    ),

    jump("grace",   "revoke")[取消订阅],
    jump("billing", "revoke"),

    jump("grace",   "expired")[宽限期未续订],
    jump("active",  "expired", label-side: -1)[取消订阅],
    jump("billing", "expired")[取消订阅 or 60天后仍扣款失败],
  )
]

#v(6pt)

2D 模式的几个要点：

- `pos` 是逻辑网格坐标（浮点即可），实际像素由 `col-gap` / `row-gap` 放大。
  最左/最上的状态自动贴到画布边。
- 2D 模式下没有"自动相邻箭头"——每条边都要自己 `jump` / `bi-jump` 出来。
  状态上的 `edge-label:` 被忽略。
- *双向对用 `bi-jump`*：画一条线、两端各一个箭头和一个标签，而不是两条
  单向箭头并排。
- 画面分三层：*连线 → 状态 → 标签*，顺序无需手动调。连线穿过无关状态时
  被圆形自动遮住；标签压到圆形上也依然在最上层可读。
- 单向 `jump` 直线穿过中间状态，要真正绕开就加 `bend:` 往对侧推；多数
  情况下先尝试 `label-side: -1`（把标签翻到对面），比弯曲线更省画面。
- `bi-jump` 的两个标签默认镜像分两侧；如果默认一侧正好落到另一根线上，
  把 `back-side` 改成与 `forward-side` 同号，两个标签就并到一起。
- 标签自动按文字宽度做最小垂直偏移，`bend = 0` 的直线也不会压线。

== `state-chain` 参数

容器参数控制整体布局：

#grid(
  columns: (110pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`gap`], [线性模式下相邻状态圆的水平间距，默认 60pt],
  text(weight: "bold")[`col-gap` / `row-gap`], [2D 模式下每单位 `pos` 对应的像素距离，默认 90pt / 100pt],
  text(weight: "bold")[`loop-height`], [自环弧的最高点相对状态边缘的距离，默认 28pt],
  text(weight: "bold")[`jump-height`], [线性越级弧的最高点相对链上/下边缘的距离，默认 48pt],
  text(weight: "bold")[`min-size`], [状态最小直径，默认 44pt],
)

== 局限

- *不做自动路由/避障*——2D 模式下长对角可能穿过中间状态，需要手动写 `bend`
  让它绕开；密集标签也可能相互压字，同样靠手动调 `bend` 的符号/大小分开。
- *不做复合状态*——UML 的 "state with substates" 要自己用嵌套 region +
  state-chain 模拟。
- *不做自动编号/转移表*——要生成文档索引得用 Typst 的 `locate` 配合自定义
  metadata，本章不涉及。

换句话说：*布局是你自己定的*。`state-chain` 负责把状态画圆、把边画弯、让箭
头对齐切线、让标签不压线——但 `pos` 和 `bend` 的值是设计者自己拍板的。密集
拓扑需要先在纸上摆一遍再抄进来。

#v(8pt)

= 使用模式

== 使用调色板

首选：直接使用内置 `palettes.xxx`。用 `#let C = ...` 给常用调色板起个短别名：

```typst
#let C = palettes.pastel
#cell(fill: C.blue)[Inbox]
#cell(fill: C.green)[Approved]
```

要在已有调色板上增/改几个键，用展开运算符：

```typst
#let C = (..palettes.pastel, accent: rgb("#FF6F00"))
#cell(fill: C.accent)[Highlight]
```

内置不够用时，定义自己的字典：

```typst
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

#section[MESI Protocol][
  #legend(
    (label: [#strong[M]odified],  fill: K.modified),
    (label: [#strong[E]xclusive], fill: K.exclusive),
    (label: [#strong[S]hared],    fill: K.shared),
    (label: [#strong[I]nvalid],   fill: K.invalid),
  )
  #v(8pt)
  #grid-row(label: [Memory])[
    #mc(fill: K.data)[`03`] #mc(fill: K.data)[`FF`]
    #mc(fill: K.data)[`7F`] #mc(fill: K.data)[`A0`]
  ]
  #grid-row(label: [CPU 0])[
    #mc(fill: K.shared, overlay: [S])[`03`]
    #mc(fill: K.shared, overlay: [S])[`FF`]
    #mc(fill: K.shared, overlay: [S])[`7F`]
    #mc(fill: K.shared, overlay: [S])[`A0`]
  ]
  #grid-row(label: [CPU 1])[
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
