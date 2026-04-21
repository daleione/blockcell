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
  ("label-width", ("length",)),
  returns: "content",
)

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
    #flex-row(gap: 4pt,
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

#section-label[Notes]

子元素默认 `width: auto`（保留自身宽度，不填满分得的列宽）。要让 cell 填满
所分列宽，显式传 `width: 100%`。
