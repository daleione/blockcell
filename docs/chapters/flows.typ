#import "../../lib.typ": *
#import "../style.typ": *

= 流程图

*blockcell* 内置一套完整的流程图工具，覆盖线性流程、条件分支、N 路分发、
循环回流等常见结构。本章自底向上依次介绍 *节点 → 容器 → 分支 → 循环*，
每节配有可直接复制的代码与渲染效果。

适用范围：*自顶向下*、以树形嵌套表达的结构化流程图（业务流程、API 调用链、
状态转移等）。非树形 2D 拓扑（对角线箭头、跨层连线、自由 DAG）请使用
`fletcher` / `cetz`。

#v(6pt)

#align(center)[
  #region(fill: rgb("#FFECB3"), width: 100%)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (84pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[节点],
      text(size: 0.85em)[`process` / `decision` / `terminal` / `junction`
        （别名，带默认色）· `flow-node`（底层）],
      text(size: 0.85em, weight: "bold")[纵向容器],
      text(size: 0.85em)[`flow-col` 自动插入下行箭头；节点上加
        `edge-label:` 标注进入它的那条箭头],
      text(size: 0.85em, weight: "bold")[分支],
      text(size: 0.85em)[`branch`（不汇合）· `branch-merge`（汇合）·
        `switch` + `case(label, body)`（N 路）],
      text(size: 0.85em, weight: "bold")[循环],
      text(size: 0.85em)[`flow-loop` 带左侧回边],
    )
  ]
]

== 节点

=== `flow-node`

流程图节点的底层构造函数。通过 `shape` 参数切换矩形 / 菱形 / 胶囊 / 圆形，
或用下面的四个语义别名省去手写 `shape:` 和 `fill:`。

#section-label[Example]

#example-pair(
  ```typ
  #flow-node(shape: "rect")[A]
  #flow-node(shape: "diamond",
             width: 70pt)[B?]
  #flow-node(shape: "stadium")[C]
  #flow-node(shape: "circle")[D]
  ```,
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

#section-label[Parameters]

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

#param-detail("shape", ("str",), default: raw("\"rect\"", lang: none))[
  `"rect"` / `"diamond"` / `"stadium"` / `"circle"`。`diamond` 宽度不足时自动
  放大以容纳文字，建议显式传 `width:`。
]

#param-detail("status", ("none", "str"), default: raw("none", lang: none))[
  取 `palettes.status` 的五个键之一，一键切成语义状态色（同时覆盖 `fill`
  和 `stroke`）。典型用法是错误出口 `terminal(status: "danger")`。
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  在 `flow-col` 内部时，这个节点上加 `edge-label:` 会被外层用作 *进入它
  的那条箭头* 的标签。不依赖下标，插入/移动节点不会错位。
]

=== `process`

矩形执行步骤；`flow-node(shape: "rect", fill: palettes.pastel.blue)` 的别名。

#section-label[Example]

#example-pair(
  ```typ
  #process[Load config]
  ```,
  [#process[Load config]],
)

#section-label[Parameters]

#params-box("process",
  ("body",    ("content",)),
  ("fill",    ("color",)),
  ("..args",  ("any",)),
  returns: "content",
)

=== `decision`

菱形条件判断；`flow-node(shape: "diamond", fill: palettes.pastel.yellow)`
的别名。宽度自动适配文字，但建议显式传 `width:` 避免过宽。

#section-label[Example]

#example-pair(
  ```typ
  #decision(width: 90pt)[Config ok?]
  ```,
  [#decision(width: 90pt)[Config ok?]],
)

=== `terminal`

胶囊形开始/结束标记；`flow-node(shape: "stadium", fill: palettes.pastel.green)`
的别名。

#section-label[Example]

#example-pair(
  ```typ
  #terminal[Start]
  #terminal(status: "danger")[Exit]
  ```,
  [
    #terminal[Start]
    #h(4pt)
    #terminal(status: "danger")[Exit]
  ],
)

=== `junction`

圆形跨页锚点；`flow-node(shape: "circle", fill: palettes.pastel.cyan)` 的
别名。`size:` 控制直径。

#section-label[Example]

#example-pair(
  ```typ
  #junction[1]   #junction[A]
  ```,
  [
    #junction[1]
    #h(4pt)
    #junction[A]
  ],
)

== 线性容器

=== `flow-col`

把节点竖排为一条流水线，相邻节点之间自动插入向下箭头。要给某条箭头加标签，
给 *目标节点* 传 `edge-label:` —— 即"标注那条指向我的箭头"。这种写法
不依赖下标，插入/移动节点不会错位。

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    terminal[Start],
    process[Load config],
    decision[Config valid?],
    process(edge-label: [Yes])[Start server],
    terminal(status: "danger")[Exit],
  )
  ```,
  [
    #flow-col(
      terminal[Start],
      process[Load config],
      decision[Config valid?],
      process(edge-label: [Yes])[Start server],
      terminal(status: "danger")[Exit],
    )
  ],
)

#section-label[Parameters]

#params-box("flow-col",
  ("..nodes",    ("content",)),
  ("edge-style", ("str",)),
  ("gap",        ("length",)),
  returns: "content",
)

#section-label[Notes]

`flow-col` 是流程图的 *纵向骨架* —— 后面介绍的 `branch` / `branch-merge` /
`switch` / `flow-loop` 都被设计为直接塞进 `flow-col` 当作"加胖了的一节"。

== 条件分支

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

=== `branch`

Yes 分支向下继续，No 分支向右散出。两条路不汇合 —— 适合主流程 + 异常/
快速返回这种"一出去就不回来了"的结构。

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Load config],
    branch([Config valid?],
      yes: process[Start server],
      no:  process(status: "danger")[Log error + exit],
    ),
    terminal[Ready],
  )
  ```,
  [
    #flow-col(
      process[Load config],
      branch([Config valid?],
        yes: process[Start server],
        no:  process(status: "danger")[Log + exit],
      ),
      terminal[Ready],
    )
  ],
)

#section-label[Parameters]

#params-box("branch",
  ("cond",          ("content",)),
  ("yes",           ("none", "content")),
  ("no",            ("none", "content")),
  ("yes-label",     ("content",)),
  ("no-label",      ("content",)),
  ("diamond-width", ("length",)),
  returns: "content",
)

#param-detail("cond", ("content",))[
  菱形内的说明文字（位置参数）。
]

#param-detail("yes", ("none", "content"), default: raw("none", lang: none))[
  Yes 分支（向下继续）。`none` 时止于菱形本身，后续由外层 `flow-col` 接续。
]

#param-detail("no", ("none", "content"), default: raw("none", lang: none))[
  No 分支（向右散出）。`none` 则不渲染替代分支。
]

#section-label[Nesting]

`yes` / `no` 接受任意内容，可以嵌套 `flow-col` 或再套 `branch` 表达子流程。

=== `branch-merge`

Yes / No 并列两列展开，底部通过水平汇合线汇入单一出口。两条路归一 ——
适合都回到主流程的 if-else。

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Parse request],
    branch-merge([Cached?],
      yes: process(fill: palettes.pastel.green)[Return cached],
      no:  process(fill: palettes.pastel.orange)[Compute + cache],
    ),
    process[Respond],
  )
  ```,
  [
    #flow-col(
      process[Parse request],
      branch-merge([Cached?],
        yes: process(fill: palettes.pastel.green)[Return cached],
        no:  process(fill: palettes.pastel.orange)[Compute + cache],
      ),
      process[Respond],
    )
  ],
)

#section-label[Parameters]

#params-box("branch-merge",
  ("cond",          ("content",)),
  ("yes",           ("none", "content")),
  ("no",            ("none", "content")),
  ("yes-label",     ("content",)),
  ("no-label",      ("content",)),
  ("merge",         ("bool",)),
  ("diamond-width", ("length",)),
  ("col-gap",       ("length",)),
  returns: "content",
)

#param-detail("merge", ("bool",), default: raw("true", lang: none))[
  `false` 关闭底部汇合线，退化为两列并列（语义上等于 N=2 的 `switch(merge: false)`）。
]

#param-detail("col-gap", ("length",), default: raw("40pt", lang: none))[
  两列之间的水平间距。
]

== N 路分支

=== `switch`

`branch-merge` 的泛化 —— 任意数量分支从菱形分发、底部汇合。case 用
`case(label, body)` 构造器声明（位置参数），`label` 作为从菱形下行的箭头
注释。

#section-label[Example]

#wide-example(
  ```typ
  #flow-col(
    process[Receive event],
    switch([event.kind],
      case([order],  process(fill: palettes.pastel.green)[Place order]),
      case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
      case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
    ),
    process[Emit audit log],
  )
  ```,
  [
    #flow-col(
      process[Receive event],
      switch([event.kind],
        case([order],  process(fill: palettes.pastel.green)[Place order]),
        case([refund], process(fill: palettes.pastel.yellow)[Issue refund]),
        case([cancel], process(fill: palettes.pastel.orange)[Cancel order]),
      ),
      process[Emit audit log],
    )
  ],
)

#section-label[Parameters]

#params-box("switch",
  ("cond",          ("content",)),
  ("..cases",       ("array",)),
  ("merge",         ("bool",)),
  ("diamond-width", ("length",)),
  ("col-gap",       ("length",)),
  returns: "content",
)

#param-detail("..cases", ("array",))[
  每个 case 用 `case(label, body)` 构造。列宽统一取所有 case body 的最大宽度
  以保证对称；奇数 case 时中列落在菱形主轴上。
]

#section-label[Defaults]

`diamond-width: 140pt`、`col-gap: 24pt`（比 `branch-merge` 更紧凑，以容纳
更多分支）。

=== `case`

`switch` 的 case 构造器。返回一个内部字典；不直接渲染，必须嵌在 `switch`
里使用。

#section-label[Example]

```typ
case([order], process[Place order])
// 等价于 (label: [order], body: process[Place order])
```

== 循环

=== `flow-loop`

把一段流程包成"循环体"，左侧自动画一条回边：*body 底部中心 → 向左 → 向上 →
向右，以向下箭头重新插入 body 顶部中心*。

典型搭配：body 放一个 `flow-col`，内含一个 `branch` —— 一路是循环出口，另一路
由回边回到顶部。

#section-label[Example]

#wide-example(
  ```typ
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
  ```,
  [
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
  ],
)

#section-label[Parameters]

#params-box("flow-loop",
  ("body",       ("content",)),
  ("back-label", ("none", "content")),
  ("arm",        ("length",)),
  returns: "content",
)

#param-detail("back-label", ("none", "content"),
  default: raw("[retry]", lang: none))[
  回边标签。`none` 隐藏标签。
]

#param-detail("arm", ("length",), default: raw("80pt", lang: none))[
  回边到 body 主列（中心）的横向距离。按主列度量 —— 即使 body 含侧出分支
  导致宽度很大，回边也始终贴近主列。
]

== 选型速查

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[`flow-col`],
        [纯线性：Start → A → B → End],
      text(weight: "bold")[`branch`],
        [主线 + 一路侧出不汇合（异常/快速返回/终止）],
      text(weight: "bold")[`branch-merge`],
        [Yes/No 都属于主流程，最终汇回同一出口],
      text(weight: "bold")[`switch`],
        [3 路及以上分支（`event.kind`、`status` 枚举等）],
      text(weight: "bold")[`flow-loop`],
        [循环/重试；通常包一个含出口 `branch` 的 `flow-col`],
    )
  ]
]

#v(6pt)

这几个组合都是块级图元，可以 *自由嵌套*：`branch-merge` 的某一臂里再塞
`switch`、`flow-loop` 里包 `branch-merge` 都是合法的。复杂流程通过树状嵌套即可
描述，无需手动摆放坐标。
