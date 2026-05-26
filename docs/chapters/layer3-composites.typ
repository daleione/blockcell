#import "../../lib.typ": *
#import "../style.typ": *

== Layer 3 — 组合 <layer3>

这一章介绍可以直接生成常见图表结构的组合组件。

如果前两章的重点是“单个元素”和“如何组织元素”，那么这一章的重点是：

- 直接搭出一个完整图块
- 用更少代码表达常见结构
- 把重复出现的布局模式写成稳定、可复用的组件

如果你是第一次使用，建议先掌握：

1. #api-ref("layer3-schema", "schema")
2. #api-ref("layer3-linked-schema", "linked-schema")
3. #api-ref("layer3-grid-row", "grid-row")
4. #api-ref("layer3-section", "section")
5. #api-ref("layer3-legend", "legend")
6. #api-ref("layer3-bit-row", "bit-row")

=== `schema` <layer3-schema>

用于展示一个独立的图块，通常带标题和可选说明。

适合：

- 单独展示一个结构
- 并排比较多个结构
- 给图加标题和简短描述
- 把一段结构内容包装成可复用的展示单元

#section-label[最基本的写法]

#example-pair(
  ```typst
  #schema(title: [User])[
    #region[
      #cell[id]
      #cell[name]
      #cell[email]
    ]
  ]
  ```
,
  [
    #schema(title: [User])[
      #region[
        #cell[id]
        #cell[name]
        #cell[email]
      ]
    ]
  ],
)

#section-label[常用参数]

#params-box("schema",
  ("body",  ("content",)),
  ("title", ("none", "content")),
  ("desc",  ("none", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("title", ("none", "content"),
  default: raw("none", lang: none))[
  图块标题。适合写类型名、模块名、结构名。
]

#param-detail("desc", ("none", "content"),
  default: raw("none", lang: none))[
  标题下方的简短说明。适合补一句用途说明，不适合放长段正文。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  图块宽度。需要多个图块并排对齐，或限制说明文字宽度时可以显式设置。
]

#section-label[并排放的时候]

#wide-example(
  ```typst
  #schema(title: [A])[
    #region[#cell[x]]
  ]#schema(title: [B])[
    #region[#cell[y]]
  ]#schema(title: [C])[
    #region[#cell[z]]
  ]
  ```
,
  [
    #schema(title: [A])[
      #region[#cell[x]]
    ]#schema(title: [B])[
      #region[#cell[y]]
    ]#schema(title: [C])[
      #region[#cell[z]]
    ]
  ],
)

#section-label[适合在这些情况下用]

- 你想把一段结构作为独立图块展示
- 你需要标题和简短说明
- 你想并排比较多个结构
- 你希望图块在文档中更容易复用

#section-label[常和这些一起用]

- 和 `region` 一起展示结构主体
- 和 `cell` 一起展示字段
- 和 `divider` 一起展示互斥布局
- 和 `target`、`connector` 一起展示上下层结构

=== `linked-schema` <layer3-linked-schema>

用于表达“上方字段区 + 下方目标区”的常见结构。

适合：

- 指针与目标对象
- 引用关系
- 堆对象
- 上层结构指向下层存储
- 需要把“字段区”和“目标区”一起展示的图

如果你的图正好是这种模式，优先使用 `linked-schema`，通常会比手工拼 `schema + region + connector + target` 更直接。

#section-label[最基本的写法]

#example-pair(
  ```typst
  #linked-schema(
    title: [Box<T>],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
    ),
    target-label: "(heap)",
    cell(fill: palettes.rust.any)[T],
  )
  ```
,
  [
    #linked-schema(
      title: [Box<T>],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
      ),
      target-label: "(heap)",
      cell(fill: palettes.rust.any)[T],
    )
  ],
)

#section-label[常用参数]

#params-box("linked-schema",
  ("body",          ("content",)),
  ("title",         ("none", "content")),
  ("desc",          ("none", "content")),
  ("width",         ("auto", "length")),
  ("fields",        ("array",)),
  ("target-fill",   ("color",)),
  ("target-label",  ("none", "str")),
  ("target-width",  ("auto", "length")),
  ("danger",        ("bool",)),
  returns: "content",
)

#param-detail("title", ("none", "content"),
  default: raw("none", lang: none))[
  图块标题。
]

#param-detail("desc", ("none", "content"),
  default: raw("none", lang: none))[
  图块说明文字。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  整个图块宽度。说明文字较长或需要多块并排时，通常会显式设置。
]

#param-detail("fields", ("array",))[
  上方字段区的内容数组。数组顺序就是视觉顺序。
]

#param-detail("target-fill", ("color",),
  default: raw("rgb(\"#FDECDC\")", lang: none))[
  下方目标区背景色。
]

#param-detail("target-label", ("none", "str"),
  default: raw("none", lang: none))[
  目标区标签，例如 `(heap)`、`(static)`。
]

#param-detail("target-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  目标区宽度。
]

#param-detail("danger", ("bool",),
  default: raw("false", lang: none))[
  用更强的危险样式强调上方字段区。
]

#section-label[稍微完整一点的写法]

#example-pair(
  ```typst
  #linked-schema(
    width: 160pt,
    title: raw("Vec<T>"),
    desc: [Pointer, length, and capacity.],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
      cell(fill: palettes.rust.sized)[len],
      cell(fill: palettes.rust.sized)[cap],
    ),
    target-fill: palettes.rust.heap,
    target-label: "(heap)",
  )[
    #cell(fill: palettes.rust.any)[T]
    #cell(fill: palettes.rust.any)[T]
    #note[… len]
  ]
  ```
,
  [
    #linked-schema(
      width: 160pt,
      title: raw("Vec<T>"),
      desc: [Pointer, length, and capacity.],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
        cell(fill: palettes.rust.sized)[len],
        cell(fill: palettes.rust.sized)[cap],
      ),
      target-fill: palettes.rust.heap,
      target-label: "(heap)",
    )[
      #cell(fill: palettes.rust.any)[T]
      #cell(fill: palettes.rust.any)[T]
      #note[… len]
    ]
  ],
)

#section-label[适合在这些情况下用]

- 你想表达“字段区指向目标区”
- 你在画堆对象、引用关系、上下层结构
- 你不想手工拼多个基础组件
- 你的图正好符合这种常见模式

=== `grid-row` <layer3-grid-row>

用于显示“左侧标签 + 右侧一行内容”的结构。

适合：

- 多行对齐的结构图
- 缓存 / 内存行
- 寄存器或表格式布局
- 每行一个主题的图

#section-label[最基本的写法]

#example-pair(
  ```typst
  #grid-row(label: [Memory])[
    #cell(width: 28pt, height: 20pt)[03]
    #cell(width: 28pt, height: 20pt)[21]
    #cell(width: 28pt, height: 20pt)[7F]
  ]
  ```
,
  [
    #grid-row(label: [Memory])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[03]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[21]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[7F]
    ]
  ],
)

#section-label[常用参数]

#params-box("grid-row",
  ("body",        ("content",)),
  ("label",       ("none", "content")),
  ("label-width", ("auto", "length")),
  ("label-align", ("alignment",)),
  returns: "content",
)

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  左侧标签。
]

#param-detail("label-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  标签列宽度。多行堆叠时，如果希望标签列整齐对齐，通常会显式设置相同宽度。
]

#param-detail("label-align", ("alignment",),
  default: raw("right", lang: none))[
  标签在标签列中的对齐方式。默认右对齐，适合多行并列时保持整齐。
]

#section-label[多行放在一起时]

#example-pair(
  ```typst
  #let row = grid-row.with(label-width: 52pt)
  #row(label: [Memory])[#cell[03] #cell[21]]
  #row(label: [CPU 0])[#cell[S] #cell[S]]
  #row(label: [CPU 1])[#cell[S] #cell[S]]
  ```
,
  [
    #let row = grid-row.with(label-width: 52pt)
    #row(label: [Memory])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[03]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[21]
    ]
    #row(label: [CPU 0])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
    ]
    #row(label: [CPU 1])[
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
      #cell(width: 28pt, height: 20pt, inset: 2pt)[S]
    ]
  ],
)

#section-label[适合在这些情况下用]

- 你需要多行整齐对齐
- 每一行都有一个明确标签
- 你在画缓存、内存、寄存器、表格式结构
- 你不想手工对齐标签列

=== `lane` <layer3-lane>

用于显示一条横向轨道上的多个阶段或状态块。

适合：

- 线程或流水线阶段
- 横向状态变化
- 一条时间线上的分段状态
- 简单的“名称 + 多段色块”展示

#section-label[最基本的写法]

#example-pair(
  ```typst
  #lane(
    name: [Thread 1],
    items: (
      (label: [Parse], fill: palettes.pastel.blue),
      (label: [Run], fill: palettes.pastel.green),
      (label: [Wait], fill: palettes.pastel.yellow),
    ),
  )
  ```
,
  [
    #box(width: 100%)[
      #lane(
        name: [Thread 1],
        items: (
          (label: [Parse], fill: palettes.pastel.blue),
          (label: [Run], fill: palettes.pastel.green),
          (label: [Wait], fill: palettes.pastel.yellow),
        ),
      )
    ]
  ],
)

#section-label[常用参数]

#params-box("lane",
  ("name",  ("none", "content")),
  ("items", ("array",)),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("name", ("none", "content"),
  default: raw("none", lang: none))[
  轨道名称，通常显示在左侧。
]

#param-detail("items", ("array",))[
  轨道中的分段项。每项通常包含 `label` 和 `fill`。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  轨道总宽度。
]

#section-label[适合在这些情况下用]

- 你想表达一条横向轨道上的多个阶段
- 你在画线程、流水线、阶段变化
- 你需要比 `grid-row` 更偏“横向阶段”的表达

=== `section` <layer3-section>

用于把一组相关内容包成一个带标题的卡片。

适合：

- 一个完整的小节图示
- 一组相关图块
- 需要标题和边界的说明区域
- 在文档中把多个图组织成更清晰的块

#section-label[最基本的写法]

#example-pair(
  ```typst
  #section[Cache hierarchy][
    #region[CPU]
    #v(4pt)
    #region[Memory]
  ]
  ```
,
  [
    #section[Cache hierarchy][
      #region[CPU]
      #v(4pt)
      #region[Memory]
    ]
  ],
)

#section-label[常用参数]

#params-box("section",
  ("title", ("content",)),
  ("body",  ("content",)),
  ("fill",  ("color",)),
  ("stroke", ("stroke",)),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("title", ("content",))[
  卡片标题。
]

#param-detail("body", ("content",))[
  卡片内容。
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  卡片背景色。
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  卡片边框样式。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  卡片宽度。
]

#section-label[适合在这些情况下用]

- 你想把一组图作为一个完整单元展示
- 你需要一个更明显的标题卡片
- 你在写教程、手册、说明文档中的完整示例

=== `legend` <layer3-legend>

用于显示颜色与含义的对应关系。

适合：

- 状态说明
- 字段颜色说明
- 分类颜色说明
- 图中颜色较多时的辅助解释

#section-label[最基本的写法]

#example-pair(
  ```typst
  #legend(
    (label: [Modified], fill: palettes.cache.modified),
    (label: [Shared], fill: palettes.cache.shared),
    (label: [Invalid], fill: palettes.cache.invalid),
  )
  ```
,
  [
    #legend(
      (label: [Modified], fill: palettes.cache.modified),
      (label: [Shared], fill: palettes.cache.shared),
      (label: [Invalid], fill: palettes.cache.invalid),
    )
  ],
)

#section-label[常用参数]

#params-box("legend",
  ("..items", ("array",)),
  ("gap", ("length",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  图例项。每项通常包含 `label` 和 `fill`。
]

#param-detail("gap", ("length",),
  default: raw("8pt", lang: none))[
  图例项之间的间距。
]

#section-label[适合在这些情况下用]

- 图中颜色已经承担语义
- 你希望读者快速理解颜色含义
- 你在画协议头、缓存状态、分类结构图

=== `bit-row` <layer3-bit-row>

用于按比例显示位字段。

适合：

- 协议头
- 寄存器布局
- 固定宽度字段图
- 需要按 bit 数分配宽度的结构

这是画协议头和寄存器图时最常用的入口。

#section-label[最基本的写法]

#wide-example(
  ```typst
  #bit-row(total: 16, width: 220pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [Flags], fill: palettes.network.flag),
  ))
  ```
,
  [
    #bit-row(total: 16, width: 220pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [Flags], fill: palettes.network.flag),
    ))
  ],
)

#section-label[常用参数]

#params-box("bit-row",
  ("fields",    ("array",)),
  ("total",     ("int",)),
  ("width",     ("length",)),
  ("show-bits", ("bool",)),
  returns: "content",
)

#param-detail("fields", ("array",))[
  字段数组。每项通常包含 `bits`、`label`、`fill`，也可以带 `stroke`、`dash`。
]

#param-detail("total", ("int",))[
  这一行的总 bit 数，例如 `16`、`32`、`64`。
]

#param-detail("width", ("length",))[
  这一行的总显示宽度。
]

#param-detail("show-bits", ("bool",),
  default: raw("true", lang: none))[
  是否显示字段 bit 数标注。
]

#section-label[多行一起写的时候]

#wide-example(
  ```typst
  #bit-row(total: 32, width: 320pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [DSCP], fill: palettes.network.flag),
    (bits: 16, label: [Total Length], fill: palettes.network.addr),
  ))
  #bit-row(total: 32, width: 320pt, fields: (
    (bits: 16, label: [ID], fill: palettes.network.meta),
    (bits: 16, label: [Flags + Offset], fill: palettes.network.flag),
  ))
  ```
,
  [
    #bit-row(total: 32, width: 320pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [DSCP], fill: palettes.network.flag),
      (bits: 16, label: [Total Length], fill: palettes.network.addr),
    ))
    #bit-row(total: 32, width: 320pt, fields: (
      (bits: 16, label: [ID], fill: palettes.network.meta),
      (bits: 16, label: [Flags + Offset], fill: palettes.network.flag),
    ))
  ],
)

#section-label[适合在这些情况下用]

- 你在画协议头或寄存器
- 字段宽度由 bit 数决定
- 你希望字段比例自动正确
- 你不想手工计算每个字段的显示宽度

=== `flex-row` <layer3-flex-row>

用于按比例分配一行中的宽度。

适合：

- 一行中多个块按比例分宽
- 不想手工给每个块写固定宽度
- 需要“1:1:2”这类布局
- 在有限宽度内做更稳定的横向分配

#section-label[最基本的写法]

#example-pair(
  ```typst
  #flex-row(
    (flex: 1, body: cell(fill: palettes.pastel.blue, width: 100%)[A]),
    (flex: 1, body: cell(fill: palettes.pastel.green, width: 100%)[B]),
    (flex: 2, body: cell(fill: palettes.pastel.orange, width: 100%)[C]),
  )
  ```
,
  [
    #box(width: 220pt)[
      #flex-row(
        (flex: 1, body: cell(fill: palettes.pastel.blue, width: 100%)[A]),
        (flex: 1, body: cell(fill: palettes.pastel.green, width: 100%)[B]),
        (flex: 2, body: cell(fill: palettes.pastel.orange, width: 100%)[C]),
      )
    ]
  ],
)

#section-label[常用参数]

#params-box("flex-row",
  ("..items", ("array",)),
  ("width",   ("auto", "length")),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  行内项目。每项通常包含 `flex` 和 `body`。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  整行宽度。
]

#param-detail("gap", ("length",),
  default: raw("0pt", lang: none))[
  各列之间的间距。
]

#param-detail("align", ("alignment",),
  default: raw("horizon", lang: none))[
  行内对齐方式。
]

#section-label[适合在这些情况下用]

- 你想按比例分配横向空间
- 你不想手工计算每列宽度
- 你在做一行多块的结构图
- 你希望布局在宽度变化时更稳定

=== `timeline` <layer3-timeline>

按比例的时间轴 / 单轨甘特：把一条横轨按时长切成若干段，段宽即时长，日期自动钉在分段边界上。

适合：

- 会员 / 订阅有效期、消耗顺序
- 项目阶段、路线图
- 请求延迟分解、流水线耗时
- 任何“按时长成比例 + 边界打日期”的横向时间结构

#section-label[日期模式：直接给日期]

每段写 `to:`（该段的绝对结束日），顶层给一个 `start:`，段宽与日期标签全部自动算出。

#example-pair(
  ```typst
  #timeline(
    width: 300pt, axis: "above",
    start: datetime(year: 2026, month: 5, day: 26),
    (to: datetime(year: 2027, month: 5, day: 26),
     fill: rgb("#f7d774"), label: [专家版]),
    (to: datetime(year: 2031, month: 10, day: 30),
     fill: palettes.sequential.green.at(2), label: [普通版]),
  )
  ```
,
  [
    #box(width: 300pt)[
      #timeline(
        width: 300pt, axis: "above",
        start: datetime(year: 2026, month: 5, day: 26),
        (to: datetime(year: 2027, month: 5, day: 26),
         fill: rgb("#f7d774"), label: [专家版]),
        (to: datetime(year: 2031, month: 10, day: 30),
         fill: palettes.sequential.green.at(2), label: [普通版]),
      )
    ]
  ],
)

#section-label[权重模式：给相对长度]

没有日期时，每段写 `span:`（数字或 `duration`）；省略 `fill` 时按 `palette` 自动取色。

#example-pair(
  ```typst
  #timeline(width: 300pt, axis: none,
    (span: 2, label: [设计]),
    (span: 5, label: [开发]),
    (span: 1, label: [上线]),
  )
  ```
,
  [
    #box(width: 300pt)[
      #timeline(width: 300pt, axis: none,
        (span: 2, label: [设计]),
        (span: 5, label: [开发]),
        (span: 1, label: [上线]),
      )
    ]
  ],
)

#section-label[常用参数]

#params-box("timeline",
  ("..segments",  ("array",)),
  ("width",       ("auto", "length")),
  ("height",      ("length",)),
  ("gap",         ("length",)),
  ("axis",        ("str", "none")),
  ("start",       ("datetime", "none")),
  ("label-pos",   ("str",)),
  returns: "content",
)

#param-detail("..segments", ("array",))[
  段字典数组。每段用 `to:`（日期模式）或 `span:`（权重模式）给长度；可带
  `label` / `sub` / `fill` / `label-pos` / `tick` 及 `stroke` / `dash` 等覆盖。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  整轨宽度。`auto` 撑满父容器。
]

#param-detail("gap", ("length",),
  default: raw("0pt", lang: none))[
  段间间距。默认 `0pt`（紧贴，表示时间连续）。
]

#param-detail("axis", ("str", "none"),
  default: raw("\"below\"", lang: none))[
  日期轴位置：`"below"` / `"above"` / `"both"` / `none`。仅日期模式有效。
]

#param-detail("start", ("datetime", "none"),
  default: raw("none", lang: none))[
  起始日期。日期模式必填。
]

#param-detail("label-pos", ("str",),
  default: raw("\"inside\"", lang: none))[
  段标签位置：`inside` / `above` / `below`。窄段放不下时可移到轨外。
]

#section-label[适合在这些情况下用]

- 你在画有效期 / 消耗顺序 / 项目排期
- 你希望段宽按真实时长自动成比例
- 你不想手工算权重，也不想手摆日期标签

=== `seq-lane` <layer3-seq-lane>

用于绘制时序图。

适合：

- 服务调用链
- 协议交互
- 登录流程
- 多参与者之间的消息往返
- 需要表达“谁调用谁、何时返回”的图

如果你的重点是参与者之间的交互，而不是单个对象的状态变化，应该从 `seq-lane` 开始。

#section-label[最小示例]

#wide-example(
  ```typst
  #seq-lane(
    seq-call("client", "server")[GET /users],
    seq-ret("server", "client")[200 OK],
  )
  ```
,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET /users],
      seq-ret("server", "client")[200 OK],
    )
  ],
)

#section-label[参数]

#params-box("seq-lane",
  ("..steps", ("content",)),
  ("participants", ("none", "array")),
  ("width", ("auto", "length")),
  ("activate", ("bool",)),
  ("autonumber", ("none", "bool", "str")),
  ("boxes", ("none", "array")),
  returns: "content",
)

#param-detail("..steps", ("content",))[
  时序图中的步骤内容，例如 `seq-call`、`seq-ret`、`seq-note`、`seq-alt` 等。
]

#param-detail("participants", ("none", "array"),
  default: raw("none", lang: none))[
  参与者定义。省略时会根据步骤中首次出现的 id 自动推导。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  时序图总宽度。
]

#param-detail("activate", ("bool",),
  default: raw("true", lang: none))[
  是否显示激活条。
]

#param-detail("autonumber", ("none", "bool", "str"),
  default: raw("none", lang: none))[
  是否启用自动编号。
]

#param-detail("boxes", ("none", "array"),
  default: raw("none", lang: none))[
  参与者分组框定义。
]

#section-label[常见步骤]

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[`seq-call`], [同步调用消息],
      text(weight: "bold")[`seq-ret`], [返回消息],
      text(weight: "bold")[`seq-note`], [便签说明],
      text(weight: "bold")[`seq-act`], [单列动作块],
      text(weight: "bold")[`seq-alt`], [条件分支片段],
      text(weight: "bold")[`seq-loop`], [循环片段],
    )
  ]
]

#section-label[何时使用]

- 你想表达参与者之间的交互
- 你在画 API 调用链、协议握手、服务编排
- 你需要消息、返回、分支、循环这些时序语义
- 你不想手工摆放参与者和消息线

== 本章小结 <layer3-summary>

如果你只想先记住最常用的几个组合组件，可以先记这几个：

- `schema`：独立图块
- `linked-schema`：字段区 + 目标区
- `grid-row`：左标签 + 右内容
- `section`：带标题卡片
- `legend`：颜色说明
- `bit-row`：位字段行
- `timeline`：按比例时间轴 / 单轨甘特
- `seq-lane`：时序图入口

如果你接下来想按场景学习更完整的图法，建议继续阅读后面的专题章节：

- 流程图
- 状态转换图
- 层级树图
- 时序图
