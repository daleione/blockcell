#import "../../lib.typ": *
#import "../style.typ": *

== Layer 1 — 原子

=== `cell`

单元格 — 最核心的视觉原语：一个带背景色、边框和标签的方块。所有上层结构（region、
schema、bit-row 等）都是 `cell` 的堆叠与包裹。

#section-label[Example]

#example-pair(
  ```typ
  #cell[A]
  #cell(fill: rgb("#FA8072"))[T]
  #cell(fill: aqua,
        stroke: 3pt + rgb("#FFD700"))[len]
  ```,
  [
    #cell[`A`]
    #h(4pt)
    #cell(fill: rgb("#FA8072"))[`T`]
    #h(4pt)
    #cell(fill: aqua, stroke: 3pt + rgb("#FFD700"))[`len`]
  ],
)

#section-label[Parameters]

#params-box("cell",
  ("body",       ("content",)),
  ("fill",       ("color",)),
  ("width",      ("auto", "length")),
  ("height",     ("auto", "length")),
  ("stroke",     ("stroke",)),
  ("dash",       ("none", "str")),
  ("radius",     ("length",)),
  ("inset",      ("length", "dictionary")),
  ("expandable", ("bool",)),
  ("phantom",    ("bool",)),
  ("overlay",    ("none", "content")),
  ("baseline",   ("ratio",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface-strong", lang: none))[
  背景颜色。
]

#param-detail("stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  边框样式。接受 Typst 原生 stroke（如 `3pt + red` 或 `3pt + rgb("#FFD700")`）。
]

#param-detail("dash", ("none", "str"), default: raw("none", lang: none))[
  边框虚线模式。可选 `none`、`"dashed"`、`"dotted"`。
]

#param-detail("expandable", ("bool",), default: raw("false", lang: none))[
  在单元格内容两侧显示 `← ⋯ →` 标记，表示该字段大小可变。
]

#param-detail("phantom", ("bool",), default: raw("false", lang: none))[
  半透明 + 虚线边框，用于表达"不存在 / 零大小"字段（如 `()` 单元类型、
  ZST、被 move 走的字段）。
]

#param-detail("overlay", ("none", "content"), default: raw("none", lang: none))[
  右上角叠加小号标记，常用于标注缓存行状态（M / E / S / I）等。
]

#section-label[Idioms]

用 `.with()` 锁定领域常用参数：

```typ
#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
#let type-cell(body) = cell(body, fill: rgb("#FA8072"))
#let ptr-field(l: [ptr]) = cell(fill: rgb("#87CEFA"))[#l#sub-label[2/4/8]]
```

=== `tag`

带点状虚线边框的 `cell`，语义上区别于普通单元格，常用于枚举判别器（`Some` /
`None`）、标签或 tagged-union 的 tag 字段。

#section-label[Example]

#example-pair(
  ```typ
  #tag[`Tag`]
  #tag(fill: rgb("#FFD700"))[`D`]
  ```,
  [
    #tag[`Tag`]
    #h(6pt)
    #tag(fill: rgb("#FFD700"))[`D`]
  ],
)

#section-label[Parameters]

#params-box("tag",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

=== `note`

小号内联注释文本。典型用途是在 `cell` 序列之后写 "… n times" 这类省略提示。

#section-label[Example]

#example-pair(
  ```typ
  #cell(fill: rgb("#FA8072"))[T]
  #cell(fill: rgb("#FA8072"))[T]
  #note[… n times]
  ```,
  [
    #cell(fill: rgb("#FA8072"))[`T`]
    #cell(fill: rgb("#FA8072"))[`T`]
    #note[… n times]
  ],
)

#section-label[Parameters]

#params-box("note",
  ("body", ("content",)),
  returns: "content",
)

=== `label`

弱化的结构说明文字。比 `note` 更偏结构说明、比正文更轻，常用于 "(heap)"、
"Memory"、"Only on eviction" 这类简短标注。

#section-label[Example]

#example-pair(
  ```typ
  #label[Memory]
  #label[(heap)]
  #label[Only on eviction]
  ```,
  [
    #label[Memory]
    #h(10pt)
    #label[(heap)]
    #h(10pt)
    #label[Only on eviction]
  ],
)

#section-label[Parameters]

#params-box("label",
  ("body", ("content",)),
  returns: "content",
)

=== `badge`

紧凑的状态徽章。最常用的入口是 `status` 参数 —— 直接取 `palettes.status` 的
五个语义键之一，免去手写 `fill` / `stroke`。

#section-label[Example]

#example-pair(
  ```typ
  #badge[STALLED]
  #badge(status: "success")[HIT]
  #badge(status: "danger")[MISS]
  ```,
  [
    #badge[STALLED]
    #h(6pt)
    #badge(status: "success")[HIT]
    #h(6pt)
    #badge(status: "danger")[MISS]
  ],
)

#section-label[Parameters]

#params-box("badge",
  ("body",   ("content",)),
  ("status", ("none", "str")),
  ("fill",   ("color",)),
  ("stroke", ("color",)),
  returns: "content",
)

#param-detail("status", ("none", "str"), default: raw("none", lang: none))[
  五个语义状态之一：`"success"` / `"warning"` / `"danger"` / `"info"` /
  `"neutral"`。设置后自动展开 `palettes.status.<key>` 的 `(fill, stroke)` 对，
  覆盖显式 `fill` / `stroke`。
]

#param-detail("fill", ("color",), default: raw("rgb(\"#FFECB3\")", lang: none))[
  未指定 `status` 时使用的背景色。
]

#param-detail("stroke", ("color",), default: raw("rgb(\"#FF8F00\")", lang: none))[
  未指定 `status` 时使用的边框色。
]

#section-label[More]

完全控制时，`badge` 同样接受显式 `fill` / `stroke`：

#example-pair(
  ```typ
  #badge(fill: rgb("#C8E6C9"),
         stroke: rgb("#2E7D32"))[HIT]
  #badge(fill: rgb("#FFCDD2"),
         stroke: rgb("#C62828"))[MISS]
  ```,
  [
    #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
    #h(6pt)
    #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
  ],
)

=== `sub-label`

下标式的小号注释，一般紧跟在 `cell` 里的字段名之后，用于标注字段大小
（`2/4/8`、`2B` 等）。

#section-label[Example]

#example-pair(
  ```typ
  #cell(fill: rgb("#87CEFA"))[
    `ptr`#sub-label[2/4/8]
  ]
  #cell(fill: rgb("#FFF9C4"))[
    `Length`#sub-label[2B]
  ]
  ```,
  [
    #cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]]
    #h(6pt)
    #cell(fill: rgb("#FFF9C4"))[`Length`#sub-label[2B]]
  ],
)

#section-label[Parameters]

#params-box("sub-label",
  ("body", ("content",)),
  returns: "content",
)

=== `span-label`

水平跨度指示 `← label →`，用在一组 `cell` 之下标注"capacity"、"padding"
之类的范围含义。

#section-label[Example]

#example-pair(
  ```typ
  #cell(fill: rgb("#FA8072"))[T]
  #cell(fill: rgb("#FA8072"))[T]
  #note[…]
  #span-label[capacity]
  ```,
  [
    #box(width: 130pt)[
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
      #note[…]
      #span-label[capacity]
    ]
  ],
)

#section-label[Parameters]

#params-box("span-label",
  ("body",  ("content",)),
  ("width", ("auto", "length", "ratio")),
  returns: "content",
)

#param-detail("width", ("auto", "length", "ratio"),
  default: raw("100%", lang: none))[
  跨度宽度。默认 `100%` 让它占满父容器；可以换成 `auto`（跟随前一个兄弟元素）
  或具体长度。
]

=== `wrap`

装饰性外层边框。典型用途是"双层边框"效果 —— Rust `Cell<T>` 的 `.celled`
CSS 样式就是"内层单元格黑色细边 + 外层金色粗边"。

#section-label[Example]

#example-pair(
  ```typ
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: rgb("#FA8072"))[T]
  ]
  ```,
  [
    #wrap(stroke: 3pt + rgb("#FFD700"))[
      #cell(fill: rgb("#FA8072"))[`T`]
    ]
  ],
)

#section-label[Parameters]

#params-box("wrap",
  ("body",   ("content",)),
  ("stroke", ("stroke",)),
  ("radius", ("length",)),
  ("inset",  ("length",)),
  returns: "content",
)

#param-detail("stroke", ("stroke",),
  default: raw("3pt + palettes.base.border", lang: none))[
  外层边框样式。默认黑色 3pt，通常改成高对比颜色以区分内外两层。
]

=== `edge`

带可选标签和箭头的有向连接线。横向（`"right"` / `"left"`）是 inline 元素，
夹在一行 `cell` 之间；纵向（`"down"` / `"up"`）是块级元素，用在 `flow-col`
的节点之间。跨容器路由请用 `cetz` / `fletcher`。

#section-label[Example]

#wide-example(
  ```typ
  #cell[Controller] #edge(label: [HTTP]) #cell[Business]
  #edge(label: [SQL], style: "dashed") #cell[MySQL]
  ```,
  [
    #cell(fill: palettes.pastel.blue)[Controller]
    #edge(label: [HTTP])
    #cell(fill: palettes.pastel.cyan)[Business]
    #edge(label: [SQL], style: "dashed")
    #cell(fill: palettes.pastel.teal)[MySQL]
  ],
)

#section-label[Parameters]

#params-box("edge",
  ("label",     ("none", "content")),
  ("direction", ("str",)),
  ("style",     ("str",)),
  ("head",      ("str",)),
  ("stroke",    ("stroke",)),
  ("length",    ("auto", "length")),
  returns: "content",
)

#param-detail("direction", ("str",),
  default: raw("\"right\"", lang: none))[
  箭头方向：`"right"` / `"left"` 为 inline 横向；`"down"` / `"up"` 为块级纵向。
]

#param-detail("style", ("str",),
  default: raw("\"solid\"", lang: none))[
  线形：`"solid"` / `"dashed"` / `"dotted"`。
]

#param-detail("head", ("str",),
  default: raw("\"arrow\"", lang: none))[
  箭头样式：`"arrow"` 为实心三角，`"none"` 无箭头（纯线段）。
]

#section-label[More]

用 stroke 颜色编码"成功 / 失败"语义：

#wide-example(
  ```typ
  #region(fill: palettes.pastel.yellow)[WAIT_BUYER_PAY]
  #edge(label: [支付成功], stroke: 1pt + green)
  #region(fill: palettes.pastel.orange)[WAIT_SELLER_SEND]
  ```,
  [
    #region(fill: palettes.pastel.yellow)[WAIT_BUYER_PAY]
    #edge(label: [支付成功], stroke: 1pt + green)
    #region(fill: palettes.pastel.orange)[WAIT_SELLER_SEND]
  ],
)

=== `brace`

在一组元素下方画水平花括号 `⌣`，并在中间标注文字。适合标记"这段是
capacity"、"这段是 padding"之类的范围。

#section-label[Example]

#example-pair(
  ```typ
  #cell(fill: rgb("#FA8072"))[T]
  #cell(fill: rgb("#FA8072"))[T]
  #cell(fill: rgb("#FA8072"))[T]
  #note[…]
  #brace(width: 160pt)[capacity]
  ```,
  [
    #box(width: 160pt)[
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
      #note[…]
      #brace(width: 160pt)[capacity]
    ]
  ],
)

#section-label[Parameters]

#params-box("brace",
  ("body",  ("content",)),
  ("width", ("length",)),
  returns: "content",
)
