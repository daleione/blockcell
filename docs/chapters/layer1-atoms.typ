#import "../../lib.typ": *
#import "../style.typ": *

#metadata("layer1") <layer1>

== Layer 1 — 原子

这一章介绍最基础的图元。它们通常是你写图时最先接触的组件：

- #api-ref("layer1-cell", "cell")：单个方块
- #api-ref("layer1-tag", "tag") / #api-ref("layer1-badge", "badge")：紧凑标记
- #api-ref("layer1-note", "note") / #api-ref("layer1-label", "label")：补充说明
- #api-ref("layer1-sub-label", "sub-label") / #api-ref("layer1-span-label", "span-label")：字段注释
- #api-ref("layer1-wrap", "wrap")：额外边框强调
- #api-ref("layer1-edge", "edge")：简单连接
- #api-ref("layer1-brace", "brace")：范围标注
- #api-ref("layer1-flow-node", "flow-node")：流程图节点基础形状
- #api-ref("layer1-pill", "pill")：填色小标签（类型 tag / 角色标记），与 #api-ref("layer1-badge", "badge")（描边 + 状态语义）互补
- #api-ref("layer1-field-cell", "field-cell")：四角注解卡片，用于字段 / 类型条目文档

如果你是第一次使用，建议先掌握：

1. #api-ref("layer1-cell", "cell")
2. #api-ref("layer1-badge", "badge")
3. #api-ref("layer1-sub-label", "sub-label")
4. #api-ref("layer1-edge", "edge")

#metadata("layer1-cell") <layer1-cell>
=== `cell`

最基础的方块。大多数结构图都从 `cell` 开始。

通常用来放：

- 字段
- 状态块
- 小型模块块
- 单个节点
- 需要颜色和边框的标签块

#section-label[最基本的写法]

#example-pair(
  ```typst
  #cell[A]
  #cell(fill: palettes.pastel.blue)[B]
  #cell(fill: palettes.pastel.orange)[C]
  ```
,
  [
    #cell[A]
    #h(4pt)
    #cell(fill: palettes.pastel.blue)[B]
    #h(4pt)
    #cell(fill: palettes.pastel.orange)[C]
  ],
)

#section-label[常用参数]

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
  ("subtitle",   ("none", "content")),
  ("baseline",   ("ratio",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface-strong", lang: none))[
  方块背景色。大多数情况下，只需要改这个参数就能区分不同字段或模块。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  宽度。需要固定字段宽度时显式设置，例如字节格、寄存器字段、小型状态块。
]

#param-detail("height", ("auto", "length"),
  default: raw("auto", lang: none))[
  高度。多块并排时，如果希望视觉上更整齐，通常会统一设置高度。
]

#param-detail("stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  边框样式。可以直接传 Typst 的 stroke，例如 `2pt + red`。
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  边框线型。常用值是 `none`、`"dashed"`、`"dotted"`。
]

#param-detail("expandable", ("bool",),
  default: raw("false", lang: none))[
  在内容两侧显示可扩展标记。适合表示“长度可变”或“数量不固定”的字段。
]

#param-detail("phantom", ("bool",),
  default: raw("false", lang: none))[
  用更弱的视觉样式表示“缺失”“零大小”或“占位”。
]

#param-detail("overlay", ("none", "content"),
  default: raw("none", lang: none))[
  在右上角叠加一个小标记。适合缓存状态、附加标签或简短状态字母。
]

#param-detail("subtitle", ("none", "content"),
  default: raw("none", lang: none))[
  在主标题下方增加一行较小的副标题。适合“主名称 + 限定词”的块。
]

#section-label[常用写法]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.blue)[Users]
  #cell(fill: palettes.pastel.green, width: 56pt)[Ready]
  #cell(fill: palettes.pastel.orange, expandable: true)[Payload]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[Users]
    #h(4pt)
    #cell(fill: palettes.pastel.green, width: 56pt)[Ready]
    #h(4pt)
    #cell(fill: palettes.pastel.orange, expandable: true)[Payload]
  ],
)

#section-label[带副标题]

#example-pair(
  ```typst
  #cell(
    fill: palettes.pastel.blue,
    width: 72pt,
    height: 36pt,
    subtitle: [(MySQL)],
  )[Orders]
  ```
,
  [
    #cell(
      fill: palettes.pastel.blue,
      width: 72pt,
      height: 36pt,
      subtitle: [(MySQL)],
    )[Orders]
  ],
)

#section-label[适合在这些情况下用]

- 你只需要一个最基础的方块
- 你在画字段、模块、状态块
- 你想先把结构搭出来，再逐步加容器和说明

#section-label[常见搭配]

- 和 `sub-label` 一起标字段大小
- 和 `region` 一起组成结构块
- 和 `schema` 一起组成完整图块
- 和 `wrap` 一起做强调边框

#metadata("layer1-tag") <layer1-tag>
=== `tag`

用于标签、判别字段或小型标记块。

它更适合那些“看起来像字段，但语义上更像标签”的内容，例如：

- 枚举判别字段
- 类型标签
- 小型分类标记

#section-label[最基本的写法]

#example-pair(
  ```typst
  #tag[Tag]
  #tag(fill: palettes.pastel.yellow)[Kind]
  ```
,
  [
    #tag[Tag]
    #h(6pt)
    #tag(fill: palettes.pastel.yellow)[Kind]
  ],
)

#section-label[常用参数]

#params-box("tag",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  标签块背景色。通常只需要改颜色，不需要额外控制尺寸。
]

#section-label[适合在这些情况下用]

- 你想表达“标签”而不是普通字段
- 你在画枚举、判别字段、分类标记
- 你希望它和普通 `cell` 在视觉上有所区分

#metadata("layer1-note") <layer1-note>
=== `note`

用于简短的内联说明。

通常用来写：

- `…`
- `… n times`
- 简短补充说明
- 紧跟在字段序列后的提示

#section-label[最基本的写法]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.red)[T]
  #cell(fill: palettes.pastel.red)[T]
  #note[… n times]
  ```
,
  [
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[… n times]
  ],
)

#section-label[常用参数]

#params-box("note",
  ("body", ("content",)),
  returns: "content",
)

#section-label[适合在这些情况下用]

- 你只需要一小段补充说明
- 说明应该跟在图元旁边，而不是单独占一块
- 你不想让说明抢走视觉重点

#metadata("layer1-label") <layer1-label>
=== `label`

用于较弱的结构说明文字。

通常用来写：

- `(heap)`
- `Memory`
- `Only on eviction`
- 简短位置或语义提示

#section-label[最基本的写法]

#example-pair(
  ```typst
  #label[Memory]
  #label[(heap)]
  #label[Only on eviction]
  ```
,
  [
    #label[Memory]
    #h(10pt)
    #label[(heap)]
    #h(10pt)
    #label[Only on eviction]
  ],
)

#section-label[常用参数]

#params-box("label",
  ("body", ("content",)),
  returns: "content",
)

#section-label[适合在这些情况下用]

- 你需要比正文更弱的说明文字
- 你想给图加位置、层次或语义提示
- 你不希望说明像 `badge` 那样有强烈视觉强调

#metadata("layer1-badge") <layer1-badge>
=== `badge`

紧凑的状态标记。

最常见的用法是直接使用 `status:`，让颜色表达语义，例如：

- 成功
- 警告
- 错误
- 信息
- 中性状态

#section-label[最基本的写法]

#example-pair(
  ```typst
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
  ],
)

#section-label[常用参数]

#params-box("badge",
  ("body",   ("content",)),
  ("status", ("none", "str")),
  ("fill",   ("color",)),
  ("stroke", ("color",)),
  returns: "content",
)

#param-detail("status", ("none", "str"),
  default: raw("none", lang: none))[
  语义状态。常用值是 `success`、`warning`、`danger`、`info`、`neutral`。
  如果组件支持 `status:`，优先用它，而不是手写颜色。
]

#param-detail("fill", ("color",),
  default: raw("rgb(\"#FFECB3\")", lang: none))[
  自定义背景色。只有在你不使用 `status:` 时才需要显式设置。
]

#param-detail("stroke", ("color",),
  default: raw("rgb
(\"#FF8F00\")", lang: none))[
  自定义边框色。通常与 `fill` 一起使用。
]

#section-label[显式颜色]

#example-pair(
  ```typst
  #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
  #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
  ```
,
  [
    #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
    #h(6pt)
    #badge(fill: rgb("#FFCDD2"), stroke: rgb("#C62828"))[MISS]
  ],
)

#section-label[适合在这些情况下用]

- 你需要一个紧凑的状态标记
- 你想让颜色直接表达语义
- 你不想用完整 `cell` 去表示一个很小的状态块

#metadata("layer1-sub-label") <layer1-sub-label>
=== `sub-label`

用于字段名后面的短小注释。

最常见的用法，是拿来标字段大小，例如：

- `2/4/8`
- `2B`
- `32b`

#section-label[最基本的写法]

#example-pair(
  ```typst
  #cell(fill: palettes.pastel.blue)[
    ptr#sub-label[2/4/8]
  ]
  #cell(fill: palettes.pastel.yellow)[
    Length#sub-label[2B]
  ]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[ptr#sub-label[2/4/8]]
    #h(6pt)
    #cell(fill: palettes.pastel.yellow)[Length#sub-label[2B]]
  ],
)

#section-label[常用参数]

#params-box("sub-label",
  ("body", ("content",)),
  returns: "content",
)

#section-label[适合在这些情况下用]

- 你想在字段名后补一个很短的尺寸说明
- 你不想额外占一行或单独放说明块
- 你在画协议字段、内存字段、寄存器字段

#metadata("layer1-span-label") <layer1-span-label>
=== `span-label`

用于给一段横向范围加说明。

通常用来标：

- `capacity`
- `padding`
- `payload`
- 一段连续字段的共同含义

#section-label[最基本的写法]

#example-pair(
  ```typst
  #box(width: 130pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[…]
    #span-label[capacity]
  ]
  ```
,
  [
    #box(width: 130pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #note[…]
      #span-label[capacity]
    ]
  ],
)

#section-label[常用参数]

#params-box("span-label",
  ("body",  ("content",)),
  ("width", ("auto", "length", "ratio")),
  returns: "content",
)

#param-detail("width", ("auto", "length", "ratio"),
  default: raw("100%", lang: none))[
  范围标注的宽度。默认会占满父容器；如果你只想标一小段范围，可以显式设置长度。
]

#section-label[适合在这些情况下用]

- 你想给一段连续字段加统一说明
- 你需要表达“这一段属于同一个概念”
- 你在画数组容量、保留区、字段范围

#metadata("layer1-wrap") <layer1-wrap>
=== `wrap`

给内容再加一层外边框。

通常用来：

- 强调某个字段或区域
- 做双层边框效果
- 表示“这个块有额外语义”

#section-label[最基本的写法]

#example-pair(
  ```typst
  #wrap(stroke: 3pt + rgb("#FFD700"))[
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #wrap(stroke: 3pt + rgb("#FFD700"))[
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[常用参数]

#params-box("wrap",
  ("body",   ("content",)),
  ("stroke", ("stroke",)),
  ("radius", ("length",)),
  ("inset",  ("length",)),
  returns: "content",
)

#param-detail("stroke", ("stroke",),
  default: raw("3pt + palettes.base.border", lang: none))[
  外层边框样式。通常会用更粗、更醒目的边框来表达强调。
]

#param-detail("radius", ("length",),
  default: raw("0pt", lang: none))[
  外层边框圆角。
]

#param-detail("inset", ("length",),
  default: raw("2pt", lang: none))[
  外层边框与内部内容之间的间距。
]

#section-label[适合在这些情况下用]

- 你想强调某个字段或块
- 你需要双层边框效果
- 你想在不改内部内容的情况下增加一层视觉语义

#metadata("layer1-edge") <layer1-edge>
=== `edge`

用于简单的方向连接。

通常用来表示：

- A 指向 B
- 调用关系
- 顺序关系
- 简单状态转移
- 相邻元素之间的连接

它最适合连接相邻内容；如果你需要复杂自由连线，应该使用更专门的绘图库。

#section-label[最基本的写法]

#wide-example(
  ```typst
  #cell[Controller]
  #edge(label: [HTTP])
  #cell[Service]
  #edge(label: [SQL], style: "dashed")
  #cell[DB]
  ```
,
  [
    #cell[Controller]
    #edge(label: [HTTP])
    #cell[Service]
    #edge(label: [SQL], style: "dashed")
    #cell[DB]
  ],
)

#section-label[常用参数]

#params-box("edge",
  ("label",     ("none", "content")),
  ("direction", ("str",)),
  ("style",     ("str",)),
  ("head",      ("str",)),
  ("stroke",    ("stroke",)),
  ("length",    ("auto", "length")),
  returns: "content",
)

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  连接线标签。适合写协议名、动作名、条件名等简短说明。
]

#param-detail("direction", ("str",),
  default: raw("\"right\"", lang: none))[
  方向。常用值是 `right`、`left`、`down`、`up`。
]

#param-detail("style", ("str",),
  default: raw("\"solid\"", lang: none))[
  线型。常用值是 `solid`、`dashed`、`dotted`。
]

#param-detail("head", ("str",),
  default: raw("\"arrow\"", lang: none))[
  箭头样式。`arrow` 表示带箭头，`none` 表示纯线段。
]

#param-detail("length", ("auto", "length"),
  default: raw("auto", lang: none))[
  连接长度。需要更紧凑或更宽松的布局时可以显式设置。
]

#section-label[适合在这些情况下用]

- 你只需要简单、直接的连接
- 连接对象彼此相邻
- 你想表达顺序、调用或指向关系

#section-label[何时不适合]

- 需要跨多个区域走线
- 需要复杂二维路由
- 需要自由布局的连接网络

#metadata("layer1-flow-node") <layer1-flow-node>
=== `flow-node`

流程图节点的基础形状。

如果你在画流程图，通常会更常直接使用：

- `process`
- `decision`
- `terminal`
- `junction`

但理解 `flow-node` 有助于你在需要时自定义节点形状。

#section-label[最基本的写法]

#example-pair(
  ```typst
  #flow-node(shape: "rect")[A]
  #flow-node(shape: "diamond", width: 70pt)[B?]
  #flow-node(shape: "stadium")[C]
  #flow-node(shape: "circle")[D]
  ```
,
  [
    #flow-node(shape: "rect")[A]
    #h(4pt)
    #flow-node(shape: "diamond", width: 70pt)[B?]
    #h(4pt)
    #flow-node(shape: "stadium")[C]
    #h(4pt)
    #flow-node(shape: "circle")[D]
  ],
)

#section-label[常用参数]

#params-box("flow-node",
  ("body",       ("content",)),
  ("shape",      ("str",)),
  ("fill",       ("color",)),
  ("stroke",     ("stroke",)),
  ("width",      ("auto", "length")),
  ("height",     ("auto", "length")),
  ("inset",      ("length", "dictionary")),
  ("status",     ("none", "str")),
  ("edge-label", ("none", "content")),
  returns: "content",
)

#param-detail("shape", ("str",),
  default: raw("\"rect\"", lang: none))[
  节点形状。常用值是 `rect`、`diamond`、`stadium`、`circle`。
]

#param-detail("status", ("none", "str"),
  default: raw("none", lang: none))[
  语义状态色。适合给错误出口、警告节点、成功节点快速上色。
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  在流程图容器中，为进入该节点的箭头添加标签。
]

#section-label[适合在这些情况下用]

- 你想自定义流程图节点形状
- 你需要比 `process` / `decision` 更底层一点的入口
- 你想统一控制节点样式

#section-label[更常见的入口]

- 普通步骤：`process`
- 条件判断：`decision`
- 开始 / 结束：`terminal`
- 小型连接点：`junction`

#metadata("layer1-field-cell") <layer1-field-cell>
=== `field-cell`

用来描述一个"字段 / 属性 / 类型条目"——在四个角分别承载 *主名*、*角标*、*描述*、*元信息 chip*。
最常见的用途是数据库 schema、API 字段表、类型/配置文档。

布局：

```text
┌───────────────────────────────┐
│ body                  [badge] │  body  · 左上主名
│ desc                  [chip]  │  badge · 右上小角标（如 ★ / ! / ?）
└───────────────────────────────┘  desc  · 左下描述
                                   chip  · 右下元信息（常用 #raw("pill"))
```

四个槽位都可省略，没填的不会留出空行。

#section-label[最基本的写法]

#example-pair(
  ```typst
  #let blue = palettes.categorical.at(0)

  #field-cell(raw("user_id"),
    desc:  [用户 ID — 内部账户标识],
    chip:  pill("string", accent: blue),
    accent: blue,
  )
  ```
,
  [
    #let blue = palettes.categorical.at(0)
    #field-cell(raw("user_id"),
      desc:  [用户 ID — 内部账户标识],
      chip:  pill("string", accent: blue),
      accent: blue,
    )
  ],
)

#section-label[加角标 + 强调边]

把字段挂到外部参考时，加一个 `★` 角标并让 `emphasized: true` 把边框加粗：

#example-pair(
  ```typst
  #let orange = palettes.categorical.at(5)

  #field-cell(raw("product_type"),
    desc:  [商品类型],
    badge: text(fill: orange.darken(35%), weight: "bold")[★],
    chip:  pill("ProductType", accent: orange),
    accent: orange,
    emphasized: true,
  )
  ```
,
  [
    #let orange = palettes.categorical.at(5)
    #field-cell(raw("product_type"),
      desc:  [商品类型],
      badge: text(fill: orange.darken(35%), weight: "bold")[★],
      chip:  pill("ProductType", accent: orange),
      accent: orange,
      emphasized: true,
    )
  ],
)

#section-label[常用参数]

#params-box("field-cell",
  ("body",       ("content",)),
  ("desc",       ("none", "content")),
  ("badge",      ("none", "content")),
  ("chip",       ("none", "content")),
  ("accent",     ("color",)),
  ("emphasized", ("bool",)),
  ("fill",       ("auto", "color")),
  ("stroke",     ("auto", "stroke")),
  ("body-fill",  ("auto", "color")),
  ("desc-size",  ("length", "ratio")),
  ("radius",     ("length",)),
  ("inset",      ("length", "dictionary")),
  ("width",      ("auto", "length", "ratio")),
  ("height",     ("auto", "length", "ratio")),
  ("gutter",     ("length",)),
  returns: "content",
)

#param-detail("accent", ("color",),
  default: raw("palettes.base.border-soft", lang: none))[
  主题色，用来推导 fill (`accent.lighten(78%)`)、stroke
  (`0.5pt + accent.darken(8%)`) 与正文颜色 (`accent.darken(45%)`)。
  传入 `fill:` / `stroke:` / `body-fill:` 可单独覆盖任一推导项。
]

#param-detail("emphasized", ("bool",),
  default: raw("false", lang: none))[
  开启后边框变重 (`0.9pt + accent.darken(25%)`)。适合"该字段链到别处"
  这类需要视觉强调的卡片。
]

#section-label[适合在这些情况下用]

- 数据库 collection / 表结构图
- API 字段、类型成员、配置项一览
- 任何"主名 + 元信息 + 描述"的卡片矩阵

#metadata("layer1-pill") <layer1-pill>
=== `pill`

填色风格的小标签——`badge` 的另一种形态。

- *用 `pill`*：表达"类型 tag / 角色标记 / 内联关键字"，颜色由单一 `accent` 派生
- *用 `badge`*：表达"语义状态"（success / warning / danger / info / neutral），描边 + 浅底深字

视觉差异：

- `pill`：深色填充 + 白色文字 + 无描边，看起来像 *标签*
- `badge`：浅色填充 + 深色文字 + 有描边，看起来像 *状态指示器*

两者最常见的搭档是 `field-cell`：把语义指示（状态）用 `badge` 放进 `chip:` 槽，
把类型/分类标记（无状态语义）用 `pill` 放进 `chip:` 槽。

默认 `size: 0.78em`，比正文小一号以呈现"次要元信息"的视觉层级。

#section-label[单独使用]

#example-pair(
  ```typst
  #pill("string")
  #pill("uint64", accent: rgb("#3b82f6"))
  ```
,
  [
    #pill("string")
    #h(4pt)
    #pill("uint64", accent: rgb("#3b82f6"))
  ],
)

#section-label[搭配 `field-cell` 使用（典型用法）]

#example-pair(
  ```typst
  #let blue = palettes.categorical.at(0)

  #field-cell(raw("price"),
    desc:  [价格 × 1000],
    chip:  pill("int", accent: blue),
    accent: blue,
  )
  ```
,
  [
    #let blue = palettes.categorical.at(0)
    #field-cell(raw("price"),
      desc:  [价格 × 1000],
      chip:  pill("int", accent: blue),
      accent: blue,
    )
  ],
)

#section-label[常用参数]

#params-box("pill",
  ("body",   ("content",)),
  ("accent", ("color",)),
  ("size",   ("length", "ratio")),
  returns: "content",
)

#metadata("layer1-brace") <layer1-brace>
=== `brace`

用于给一段内容加花括号范围标注。

通常用来表示：

- 这一段字段属于同一部分
- 这一组内容共同组成某个结构
- 一段空间表示容量、保留区或元数据

#section-label[最基本的写法]

#example-pair(
  ```typst
  #box(width: 160pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
    #note[…]
    #brace(span: 160pt)[capacity]
  ]
  ```
,
  [
    #box(width: 160pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
      #note[…]
      #brace(span: 160pt)[capacity]
    ]
  ],
)

#section-label[常用参数]

#params-box("brace",
  ("body",      ("content",)),
  ("span",      ("length",)),
  ("direction", ("str",)),
  returns: "content",
)

#param-detail("span", ("length",),
  default: raw("10em", lang: none))[
  花括号跨度。横向时表示宽度，纵向时表示高度。
]

#param-detail("direction", ("str",),
  default: raw("\"down\"", lang: none))[
  花括号方向。常用值：
  - `down`：横向，标签在下
  - `up`：横向，标签在上
  - `right`：纵向，标签在右
  - `left`：纵向，标签在左
]

#section-label[更多方向]

#example-pair(
  ```typst
  #brace(span: 120pt)[payload]
  #brace(direction: "up", span: 120pt)[header]
  #brace(direction: "right", span: 60pt)[body]
  ```
,
  [
    #brace(span: 120pt)[payload]
    #h(10pt)
    #brace(direction: "up", span: 120pt)[header]
    #h(10pt)
    #brace(direction: "right", span: 60pt)[body]
  ],
)

#section-label[适合在这些情况下用]

- 你想标出一整段范围
- 你需要比 `span-label` 更强的范围提示
- 你在画协议头、数组容量、字段分组

== 本章小结

如果你只想先记住最常用的几个原子组件，可以先记这几个：

- `cell`：最基础的方块
- `badge`：紧凑状态标记
- `sub-label`：字段尺寸注释
- `edge`：简单连接
- `wrap`：额外强调边框

接下来如果你想把多个原子组件组织成一个整体，请继续看下一章：*Layer 2 — 容器*。
