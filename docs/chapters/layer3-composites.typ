#import "../../lib.typ": *
#import "../style.typ": *

== Layer 3 — 组合

=== `schema`

顶层内联容器：一个带标题 + 描述的图表块。多个 `schema` 紧邻写会自动水平排列
（inline box 的副作用），方便做"并列三种类型长这样"的对比图。

#section-label[Example]

#example-pair(
  ```typ
  #schema(title: raw("u8"),
          desc: [8-bit unsigned.])[
    #region[
      #cell(fill: red, width: 40pt)[u8]
    ]
  ]
  ```,
  [
    #schema(title: raw("u8"), desc: [8-bit unsigned.])[
      #region[#cell(fill: rgb("#FA8072"), width: 40pt)[`u8`]]
    ]
  ],
)

#section-label[Parameters]

#params-box("schema",
  ("body",  ("content",)),
  ("title", ("none", "content")),
  ("desc",  ("none", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

#section-label[More]

并列三个 schema：

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
    #region(fill: rgb("#FAFAD2"))[
      #tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 50pt)[`T`]
    ]
  ]
]

=== `linked-schema`

最常用的模式："顶部字段区 → 连接线 → 底部目标区"。是 `schema` + `region`
+ `connector` + `target` 的组合封装。

#section-label[Example]

#example-pair(
  ```typ
  #linked-schema(
    title: raw("Box<T>"),
    desc: [Heap-allocated.],
    fields: (
      cell(fill: rgb("#87CEFA"))[
        ptr#sub-label[2/4/8]
      ],
    ),
    target-fill: rgb("#C6DBE7"),
    target-label: "(heap)",
    cell(fill: rgb("#FA8072"),
         expandable: true)[T],
  )
  ```,
  [
    #linked-schema(
      title: raw("Box<T>"),
      desc: [Heap-allocated.],
      fields: (cell(fill: rgb("#87CEFA"))[`ptr`#sub-label[2/4/8]],),
      target-fill: rgb("#C6DBE7"),
      target-label: "(heap)",
      cell(fill: rgb("#FA8072"), expandable: true)[`T`],
    )
  ],
)

#section-label[Parameters]

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

#param-detail("fields", ("array",))[
  顶部字段区里水平铺开的 cell 数组。数组顺序即视觉顺序。
]

#param-detail("target-fill", ("color",))[
  底部 target 的背景色；通常用比 field 更浅的同色系，暗示"这是被指向的
  存储区"。
]

=== `grid-row`

带左侧标签的单元格行。标签和右侧内容按基线对齐，适合寄存器映射、内存/缓存
并列这类"每行一个主题"的图。

#section-label[Example]

#example-pair(
  ```typ
  #grid-row(label: [Main Memory])[
    #cell(width: 28pt, height: 20pt,
          fill: rgb("#FFE0B2"))[03]
    #cell(width: 28pt, height: 20pt,
          fill: rgb("#FFE0B2"))[21]
  ]
  ```,
  [
    #grid-row(label: [Main Memory])[
      #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`03`]
      #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`21`]
      #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`7F`]
      #cell(fill: rgb("#FFE0B2"), width: 28pt, height: 20pt, inset: 2pt)[`A0`]
    ]
  ],
)

#section-label[Parameters]

#params-box("grid-row",
  ("body",        ("content",)),
  ("label",       ("none", "content")),
  ("label-width", ("auto", "length")),
  ("label-align", ("alignment",)),
  returns: "content",
)

#param-detail("label-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  label 列宽度。`auto` 按 label 自然宽度贴身（+2pt 呼吸空间），单行用时
  label 和 body 之间不会有多余留白。多行堆叠需要 *label 列对齐* 时（不同
  长度的 label 要顶格对齐），显式传相同的 length，或者用 `.with()` 封一个
  共享 helper。
]

#param-detail("label-align", ("alignment",),
  default: raw("right", lang: none))[
  label 在其列内的水平对齐。默认 `right` —— 多行堆叠时 label 末尾贴齐
  body 左边缘，最整齐。显式传 `left` 能让 label 靠左（少数场景如
  "label 列更像一栏标题"用得到）。
]

#section-label[Idioms]

*多行对齐：* 几行 `grid-row` 竖着堆，label 长短不一时用 `.with(label-width: N)`
固定宽度：

```typ
#let mrow = grid-row.with(label-width: 52pt)

#mrow(label: [Memory])[...]
#mrow(label: [CPU 0 L1])[...]
#mrow(label: [CPU 1 L1])[...]
```

不传 `label-width` 时每行各自贴身，适合 *单行独立出现* 的场景。

=== `lane`

水平色带轨道。每个 item 是一个 `(label, fill)` 字典，适合"线程 / 流水线
随时间的状态变化"这类横向时序图。

#section-label[Example]

#example-pair(
  ```typ
  #lane(
    name: [Thread 1],
    items: (
      (label: [Mutex<u32>],
       fill: rgb("#B4E9A9")),
      (label: [Cell<u32>],
       fill: rgb("#FBF7BD")),
      (label: [Rc<u32>],
       fill: rgb("#F37142")),
    ),
  )
  ```,
  [
    #box(width: 100%)[
      #lane(
        name: [Thread 1],
        items: (
          (label: [`Mutex<u32>`], fill: rgb("#B4E9A9")),
          (label: [`Cell<u32>`],  fill: rgb("#FBF7BD")),
          (label: [`Rc<u32>`],    fill: rgb("#F37142")),
        ),
      )
    ]
  ],
)

#section-label[Parameters]

#params-box("lane",
  ("name",  ("none", "content")),
  ("items", ("array",)),
  returns: "content",
)

#param-detail("items", ("array",))[
  每项必须是 `(label: content, fill: color)` 字典，按顺序在轨道上水平平铺。
]

=== `seq-lane`

声明式 UML 时序图。与 `lane`（状态随时间走）互补 —— `seq-lane` 表达
"参与者之间互相调用"。覆盖完整 UML 词汇：跨列消息、自调用、控制焦点、
组合片段（alt / opt / loop / par）、便签。

#section-label[Example]

#example-pair(
  ```typ
  #seq-lane(
    seq-call("c", "biz")[POST /order],
    seq-note("biz")[校验库存],
    seq-alt([ok],
      seq-call("biz", "db")[INSERT],
      seq-ret("db", "biz")[OK],
    ),
    seq-ret("biz", "c")[201],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("c", "biz")[POST /order],
      seq-note("biz")[校验库存],
      seq-alt([ok],
        seq-call("biz", "db")[INSERT],
        seq-ret("db", "biz")[OK],
      ),
      seq-ret("biz", "c")[201],
    )
  ],
)

#section-label[Step 构造函数]

#grid(
  columns: (170pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-call(from, to)[..]`],
  [同步消息（实线 + 实心三角箭头）；`from == to` 时自动渲染为自调用 U 形回环。],
  text(weight: "bold")[`seq-ret(from, to)[..]`],
  [回调（虚线 + 开口 V 形箭头）。],
  text(weight: "bold")[`seq-note(over)[..]`],
  [便签（折角矩形）；`over` 取单个 id 或 `("a","b")` 跨多列。],
  text(weight: "bold")[`seq-act(who)[..]`],
  [单参与者列内的工作块；`who` 不能正处于激活区间内 —— 否则 panic
   （改用 `seq-note` 作注解）。],
  text(weight: "bold")[`seq-alt(cond, ..)`],
  [可选分支组合片段；首参为条件（方括号内容），其余为嵌套 step。],
  text(weight: "bold")[`seq-opt` / `seq-loop` / `seq-par`],
  [同上，分别对应 opt / loop / par 片段语义。],
)

#section-label[Parameters]

#params-box("seq-lane",
  ("..steps",          ("content",)),
  ("width",            ("auto", "length")),
  ("step-height",      ("length",)),
  ("header-height",    ("length",)),
  ("column-gap",       ("length",)),
  ("row-gap",          ("length",)),
  ("activate",         ("bool",)),
  ("activation-width", ("length",)),
  ("participants",     ("none", "array")),
  returns: "content",
)

#param-detail("participants", ("none", "array"),
  default: raw("none", lang: none))[
  显式锁定参与者顺序与显示名。每项是 `(id: "biz", name: [Business],
  fill: color)` 字典。未传时按 step id 首次出现顺序自动推导，颜色循环使用
  `palettes.categorical`。
]

#param-detail("activate", ("bool",), default: raw("true", lang: none))[
  是否自动绘制激活矩形（"正在执行"的窄竖条）。`seq-call` 开启，匹配的
  `seq-ret` 关闭。
]

#section-label[More]

完整登录流程示例：

#align(center)[
  #seq-lane(
    width: 100%,
    participants: (
      (id: "browser", name: [Browser]),
      (id: "api",     name: [API]),
      (id: "auth",    name: [Auth]),
      (id: "db",      name: [DB]),
    ),
    seq-call("browser", "api")[POST /login],
    seq-call("api", "api")[validate input],
    seq-alt([credentials provided],
      seq-call("api", "auth")[authenticate],
      seq-call("auth", "db")[SELECT user],
      seq-ret("db", "auth")[user row],
      seq-note("auth")[bcrypt compare],
      seq-ret("auth", "api")[session token],
    ),
    seq-ret("api", "browser")[200 + Set-Cookie],
  )
]

=== `section`

带顶部大标题的文档级卡片容器。适合"一章一个主题"的布局（与 Markdown 的
一级标题 + 有底色区块类似）。

#section-label[Example]

#example-pair(
  ```typ
  #section[缓存一致性][
    MESI 协议通过 4 种状态协调
    缓存行的一致性。
    ...
  ]
  ```,
  [
    #section[MESI][
      协议通过 4 种状态协调缓存行。
      #v(2pt)
      #legend(
        (label: [M], fill: rgb("#FFCC80")),
        (label: [S], fill: rgb("#C8E6C9")),
      )
    ]
  ],
)

#section-label[Parameters]

#params-box("section",
  ("title",  ("content",)),
  ("body",   ("content",)),
  ("fill",   ("color",)),
  ("stroke", ("stroke",)),
  returns: "content",
)

=== `legend`

一行代码生成色彩图例。替代手写 `grid` + 小色块 + 标签的样板代码。

#section-label[Example]

#example-pair(
  ```typ
  #legend(
    (label: [Modified], fill: orange),
    (label: [Shared],   fill: green),
    (label: [Invalid],  fill: gray),
  )
  ```,
  [
    #legend(
      (label: [Modified],  fill: rgb("#FFCC80")),
      (label: [Shared],    fill: rgb("#C8E6C9")),
      (label: [Invalid],   fill: luma(220)),
    )
  ],
)

#section-label[Parameters]

#params-box("legend",
  ("..items",      ("array",)),
  ("columns",      ("auto", "int")),
  ("swatch-size",  ("length",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  每项 `(label: content, fill: color)` 字典。排列方式由 `columns` 决定。
]

=== `bit-row`

按比特数等比缩放字段宽度，专为协议头部和寄存器映射设计。告别手算
`width: NNpt`。

#section-label[Example]

#example-pair(
  ```typ
  #bit-row(total: 32, width: 400pt,
    fields: (
      (bits: 4,  label: [Ver],  fill: yellow),
      (bits: 4,  label: [IHL],  fill: yellow),
      (bits: 8,  label: [DSCP], fill: purple),
      (bits: 16, label: [Total Length],
                 fill: aqua),
    ),
  )
  ```,
  [
    #bit-row(total: 32, width: 100%, fields: (
      (bits: 4,  label: [Ver],         fill: rgb("#FFF9C4")),
      (bits: 4,  label: [IHL],         fill: rgb("#FFF9C4")),
      (bits: 8,  label: [DSCP],        fill: rgb("#E1BEE7")),
      (bits: 16, label: [Total Length], fill: rgb("#B2DFDB")),
    ))
  ],
)

#section-label[Parameters]

#params-box("bit-row",
  ("total",     ("int",)),
  ("width",     ("length", "ratio")),
  ("fields",    ("array",)),
  ("show-bits", ("bool",)),
  returns: "content",
)

#param-detail("fields", ("array",))[
  每项是 `(bits: int, label: content, fill: color)` 字典；可选键
  `stroke` / `dash`。字段宽度 = `width * bits / total`。
]

#param-detail("show-bits", ("bool",), default: raw("true", lang: none))[
  是否在字段标签后以下标形式显示比特宽度（如 `Ver`#sub-label[`4b`]）。
]

#section-label[More]

IPv4 头部前 3 行 —— 字段宽度按比特数自动等比分配：

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

=== `flex-row`

用 `flex` 权重（CSS `flex-grow` 语义）切分行内宽度。每项 `(flex, body)` 字典，
列宽 = `flex / sum(flex) * 行宽`。底层走 Typst `fr` 单元。

#section-label[Example]

#example-pair(
  ```typ
  #flex-row(
    (flex: 1, body:
      cell(fill: blue)[Category]),
    (flex: 1, body:
      cell(fill: aqua)[Product]),
    (flex: 2, body:
      cell(fill: teal)[Search]),
  )
  ```,
  [
    #flex-row(
      (flex: 1, body: cell(fill: palettes.sequential.blue.at(0), width: 100%)[Cat]),
      (flex: 1, body: cell(fill: palettes.sequential.blue.at(2), width: 100%)[Prod]),
      (flex: 2, body: cell(fill: palettes.sequential.blue.at(4), width: 100%)[Search]),
    )
  ],
)

#section-label[Parameters]

#params-box("flex-row",
  ("..items", ("array",)),
  ("width",   ("auto", "length")),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("array",))[
  每项 `(flex: int, body: content)` 字典；`flex` 必须 > 0，越大越宽。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  `auto` 让整行撑满父容器；传具体长度固定宽度。
]

#param-detail("gap", ("length",), default: raw("4pt", lang: none))[
  列间距。默认 4pt 保证相邻 tile 不贴边；需要无缝并排时显式传 `0pt`。
]

#section-label[Notes]

子元素默认 `width: auto`（保留自身宽度，不填满分得的列宽）。要让 cell 填满
所分列宽，显式传 `width: 100%`。

=== `tier`

"左边彩色粗体层名 + 右边面板"的一行。本身只负责排好 label 列 + body 列，
不做装饰；body 放什么都行（一个 `group`、一行 `cell`、`match-row` 嵌套、
grid …）。

典型用法是竖着堆几个 `tier` 拼出分层架构图（应用 → 服务 → 数据层），
每层一个 `accent` 色，对应 body 内 `group` / `cell` 同色系的浅 / 深 fill，
形成一致的视觉分层。

#section-label[Example]

#example-pair(
  ```typ
  #tier(label: [Client],
        accent: palettes.categorical.at(0).darken(30%))[
    #group(fill: palettes.categorical.at(0).lighten(55%),
           width: 100%, inset: 6pt)[
      #cell(fill: palettes.categorical.at(0).lighten(20%),
            width: 100%)[Web]
    ]
  ]
  ```,
  [
    #tier(label: [Client], accent: palettes.categorical.at(0).darken(30%))[
      #group(fill: palettes.categorical.at(0).lighten(55%),
             stroke: 0.6pt + palettes.categorical.at(0).darken(10%),
             width: 100%, inset: 6pt)[
        #cell(fill: palettes.categorical.at(0).lighten(20%), width: 100%)[Web]
      ]
    ]
  ],
)

#section-label[Parameters]

#params-box("tier",
  ("body",        ("content",)),
  ("label",       ("none", "content")),
  ("accent",      ("color",)),
  ("label-width", ("auto", "length")),
  ("label-align", ("alignment",)),
  ("gap",         ("length",)),
  returns: "content",
)

#param-detail("label", ("none", "content"), default: raw("none", lang: none))[
  层名。传 `none` 时 label 列留空但仍占位，便于堆叠的多个 tier 共用等宽
  label 列、body 起始 x 对齐。
]

#param-detail("accent", ("color",),
  default: raw("palettes.base.text", lang: none))[
  label 的文字颜色。与 body 里容器的 fill 同色系（`.lighten()` / `.darken()`）
  能让每一层看起来自成色块。
]

#param-detail("label-width", ("auto", "length"),
  default: raw("auto", lang: none))[
  label 列宽度。`auto`（默认）测量 label 按需贴身，单个 tier 下紧凑且合
  理。多个 tier 堆叠时，若 label 长度不一 *且* 要保持 body 起始 x 对齐，
  显式传相同的 length（或用 `tier.with(label-width: N)` 封一个共享 helper）。
]

#param-detail("label-align", ("alignment",),
  default: raw("right", lang: none))[
  label 在其列内的水平对齐。只传水平分量（`left` / `right` / `center`），
  垂直部分由内部管理。与 `grid-row.label-align` 语义一致。
]

#section-label[Idioms]

*堆叠多个 tier：* 竖着放并用 `#v(...)` 控制层间距。颜色取 `palettes.categorical`
的不同 index，每层 `accent: C.at(i).darken(30%)` + `group fill: C.at(i).lighten(55%)`
自动得到协调的色调。

#wide-example(
  ```typ
  #let C = palettes.categorical
  #let layer(i, name, body) = tier(
    label: [#name], accent: C.at(i).darken(30%),
  )[
    #group(fill: C.at(i).lighten(55%),
           stroke: 0.6pt + C.at(i).darken(10%),
           width: 100%, inset: 6pt, body)
  ]
  #layer(0, [Client], [#cell(width: 100%)[Web] #cell(width: 100%)[Mobile]])
  #v(4pt)
  #layer(2, [Service], [#cell(width: 100%)[Auth] #cell(width: 100%)[Orders]])
  #v(4pt)
  #layer(4, [Data],    [#cell(width: 100%)[Users] #cell(width: 100%)[Events]])
  ```,
  [
    #{
      let C = palettes.categorical
      let layer(i, name, body) = tier(
        label: [#name], accent: C.at(i).darken(30%),
      )[
        #group(fill: C.at(i).lighten(55%),
               stroke: 0.6pt + C.at(i).darken(10%),
               width: 100%, inset: 6pt, body)
      ]
      layer(0, [Client], flex-row(
        (flex: 1, body: cell(fill: C.at(0).lighten(20%), width: 100%)[Web]),
        (flex: 1, body: cell(fill: C.at(0).lighten(20%), width: 100%)[Mobile]),
      ))
      v(4pt)
      layer(2, [Service], flex-row(
        (flex: 1, body: cell(fill: C.at(2).lighten(20%), width: 100%)[Auth]),
        (flex: 1, body: cell(fill: C.at(2).lighten(20%), width: 100%)[Orders]),
      ))
      v(4pt)
      layer(4, [Data], flex-row(
        (flex: 1, body: cell(fill: C.at(4).lighten(20%), width: 100%)[Users]),
        (flex: 1, body: cell(fill: C.at(4).lighten(20%), width: 100%)[Events]),
      ))
    }
  ],
)

*混搭 `match-row`：* 当某层需要并列的子面板等高（如 "三个服务域 + 一个只读
legacy 域"），把 `match-row` 直接塞进 `tier` 的 body 里即可。见 `match-row`
的示例。

=== `match-row`

把并列的几个子元素拉伸到最高那个的高度。典型场景：架构图里 "五项 + 五项 +
两项" 的三列面板，想让三列外框一样高、而不是最右边那列短一截。

*为什么不能直接用 `grid`：* Typst 的 grid 行高 = 子元素自然高度的最大值，
但子元素本身的高度仍然是各自的自然值。`height: 100%` 在 `height: auto` 的
行里不会被解析（会塌陷），所以没法让短的那列自动变长。`match-row` 用
`layout()` + `measure()` 先量出最高那个，再把 *需要被拉伸* 的子元素写成
工厂 `h => content`，把测得的高度传进去，通常透传成 `group(height: h)`。

#section-label[Example]

刚性子元素（常规 content）参与测量；需要被拉伸的子元素写成 `h => ...`
工厂：

#wide-example(
  ```typ
  #match-row(
    width-ratio: (1, 1),
    gap: 8pt,
    // 刚性：参与测量，贡献自然高度
    group(label: [Tall], width: 100%, inset: 6pt)[
      #stack(cell[A], cell[B], cell[C], cell[D])
    ],
    // 工厂：收到 h = 4 个 cell 的自然高度
    h => group(
      label: [Short], width: 100%, height: h, inset: 6pt,
    )[#cell[Only one]],
  )
  ```,
  [
    #match-row(
      width-ratio: (1, 1),
      gap: 8pt,
      group(label: [Tall], fill: palettes.pastel.blue.lighten(30%), width: 100%, inset: 6pt)[
        #stack(
          cell(fill: palettes.pastel.blue, width: 100%)[A],
          cell(fill: palettes.pastel.blue, width: 100%)[B],
          cell(fill: palettes.pastel.blue, width: 100%)[C],
          cell(fill: palettes.pastel.blue, width: 100%)[D],
        )
      ],
      h => group(label: [Short], fill: palettes.pastel.green.lighten(30%),
                 width: 100%, height: h, inset: 6pt)[
        #cell(fill: palettes.pastel.green, width: 100%)[Only one]
      ],
    )
  ],
)

#section-label[Parameters]

#params-box("match-row",
  ("..items",     ("content", "function")),
  ("width-ratio", ("none", "array")),
  ("gap",         ("length",)),
  ("align",       ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("content", "function"))[
  每个位置参数要么是 content（刚性，参与高度测量），要么是 `length -> content`
  的工厂（拉伸，收到测出的目标高度）。两者可混合、数量不限；至少要有一个
  刚性子元素来决定目标高度，不然工厂会收到 `0pt`。
]

#param-detail("width-ratio", ("none", "array"), default: raw("none", lang: none))[
  列宽比重数组，例如 `(3, 1)` 或 `(1, 1, 1)`。`none` 表示等宽。长度应等于
  `items` 数量。
]

#param-detail("gap", ("length",), default: raw("4pt", lang: none))[
  列间距。默认 `4pt`，和 `flex-row` 一致 —— 两个"横向并列子元素"的 composite
  行为统一。需要无缝并排时显式传 `0pt`，架构图里通常传 `8pt` / `10pt`。
]

#param-detail("align", ("alignment",), default: raw("top", lang: none))[
  每列内部内容的对齐方向。`top` 让短 body 的工厂子元素顶部对齐（外框已
  拉满高度，body 本身若不填满则空在下方）。
]

#section-label[Notes]

*测量开销*：`match-row` 对每个刚性子元素渲染一次 `measure()`，对页内复杂
图表几乎察觉不到；渲染千级别 row 时再考虑优化。

*什么时候不用*：

- 各列内容本来就等高（例如同结构的 tile 都用显式 `height`）——
  直接 `grid` 或 `flex-row` 就行。
- 只想让列宽按比例分，不关心高度 —— 用 `flex-row`。
- 需要测量外的布局能力（换行、动态列数）—— 用原生 `layout()` + `measure()`
  自己写，`match-row` 就是这种常见模式的封装。

#section-label[Idioms]

*多个工厂*：全部只读 / 次要的列都可以写成工厂，由剩下一个刚性列决定高度：

```typ
#match-row(
  width-ratio: (1, 1, 1),
  gap: 8pt,
  primary-panel,                    // 决定高度
  h => secondary-panel(height: h),  // 被拉伸
  h => archived-panel(height: h),   // 被拉伸
)
```

*搭 `tier`*：整条面板当作 `tier` 的 body，让层名和拉伸行在同一排。
