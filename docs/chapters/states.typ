#import "../../lib.typ": *
#import "../style.typ": *

= 状态转换图

*blockcell* 内置一层状态机专用图元 —— `state-chain`。两种模式共用同一个渲染器：

- *线性模式*：状态不带 `pos:`，按出现顺序自动左→右排列，相邻状态之间自动画
  箭头。适合链式流程（文件 I/O、连接握手、订单阶段……）。
- *2D 模式*：任一状态带上 `pos: (col, row)`，立刻切换为坐标网格 —— 所有边都要
  用 `jump` 显式声明，`bend:` 参数控制曲率，可画任意拓扑（订阅状态流转、
  复杂协议状态机……）。

两种模式下 `loop` / `jump` 都用 id 交叉引用，顺序随写随放。

#v(6pt)

#align(center)[
  #region(fill: rgb("#FCE4EC"), width: 100%)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (84pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[状态节点],
      text(size: 0.85em)[`state(id)` —— 圆形自适应；`initial` / `accept`
        着色 + 双边框；可选 `pos: (col, row)` 切 2D],
      text(size: 0.85em, weight: "bold")[链上转移],
      text(size: 0.85em)[线性模式下，目标节点的 `edge-label:` 给相邻自动
        箭头加标],
      text(size: 0.85em, weight: "bold")[自环],
      text(size: 0.85em)[`loop(id)[label]` —— 四向任选：`above` / `below` /
        `left` / `right`],
      text(size: 0.85em, weight: "bold")[单向转移],
      text(size: 0.85em)[`jump(from, to)[label]` —— 线性模式用 `route:`，
        2D 模式用 `bend:` 控制曲率],
      text(size: 0.85em, weight: "bold")[双向转移],
      text(size: 0.85em)[`bi-jump(from, to, forward:, back:)` —— 一条线两头
        箭头，两端各一标签（2D 专用）],
      text(size: 0.85em, weight: "bold")[容器],
      text(size: 0.85em)[`state-chain(..items)` 把所有节点和覆盖层混排
        传入即可],
    )
  ]
]

== 快速上手

经典的文件 I/O 状态机：`reading → eof → closed`，`reading` 可自环读下一块，
也可直接 `close()` 跳到 `closed`：

#wide-example(
  ```typ
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof",    edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],
    loop("reading")[`read()`],
    jump("reading", "closed", route: "below")[`close()`],
  )
  ```,
  [
    #state-chain(
      state("reading", initial: true)[reading],
      state("eof", edge-label: [`read()`])[eof],
      state("closed", edge-label: [`close()`], accept: true)[closed],
      loop("reading")[`read()`],
      jump("reading", "closed", route: "below")[`close()`],
    )
  ],
)

#v(4pt)

读法：链上的状态按出现顺序左→右排；相邻两状态之间自动画前向箭头，箭头标签
由 *后一个状态* 的 `edge-label:` 提供。`loop` / `jump` 按 id 引用状态，顺序不
重要，写在 `state-chain` 里哪都行。

== 核心构造函数

=== `state`

一个圆形状态节点。自动按 body 尺寸调大（下限 44pt）。`initial` / `accept`
是两个布尔标志，分别对应 UML 的"初始态"和"接受态"，各自带默认配色和视觉
装饰。

#section-label[Example]

#wide-example(
  ```typ
  #state-chain(
    state("a", initial: true)[a],
    state("b")[b],
    state("c", accept: true)[c],
  )
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      state("c", accept: true)[c],
    )
  ],
)

#section-label[Parameters]

#params-box("state",
  ("id",         ("str",)),
  ("body",       ("content",)),
  ("pos",        ("none", "array")),
  ("initial",    ("bool",)),
  ("accept",     ("bool",)),
  ("edge-label", ("none", "content")),
  ("fill",       ("none", "color")),
  ("size",       ("auto", "length")),
  returns: "content",
)

#param-detail("id", ("str",))[
  字符串 id，供 `loop` / `jump` 交叉引用（*位置参数*）。
]

#param-detail("pos", ("none", "array"), default: raw("none", lang: none))[
  `(col, row)` 二元组（支持浮点）。任意一个状态带上 `pos:`，`state-chain`
  立刻切到 2D 模式。
]

#param-detail("initial", ("bool",), default: raw("false", lang: none))[
  设为 `true` → 默认绿底 + 自动画灰色入口小圆点 + 指向本状态的进入箭头。
]

#param-detail("accept", ("bool",), default: raw("false", lang: none))[
  设为 `true` → 默认黄底 + 双边框（UML 的"接受状态"）。与 `initial` 可同时
  设置（初始化且也是终止态），填充色取 `initial` 的绿色，双边框来自 `accept`。
]

#param-detail("edge-label", ("none", "content"),
  default: raw("none", lang: none))[
  线性模式下，*进入* 本状态的自动箭头的标签。2D 模式忽略（所有边都要
  显式 `jump` / `bi-jump`）。
]

#section-label[Color convention]

#align(center)[
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.green, stroke: 0.8pt + black)
    #h(4pt) `initial` 绿色
  ]
  #h(10pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.yellow, stroke: 0.8pt + black)
    #h(4pt) `accept` 黄色 + 双边框
  ]
  #h(10pt)
  #box(baseline: 30%, inset: 4pt)[
    #circle(width: 28pt, fill: palettes.pastel.blue, stroke: 0.8pt + black)
    #h(4pt) 普通 蓝色
  ]
]

=== `loop`

在指定 id 的状态上画一段回到自身的小弧。2D 模式下四向都有意义；线性模式下
一般用上/下，避免和主链箭头冲突。

#section-label[Example]

#wide-example(
  ```typ
  // 默认在状态上方
  #loop("a")[retry]
  #loop("a", route: "below")[retry]
  #loop("a", route: "left", style: "dashed")[retry]
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      loop("a")[retry],
    )
  ],
)

#section-label[Parameters]

#params-box("loop",
  ("id",    ("str",)),
  ("body",  ("content",)),
  ("route", ("str",)),
  ("style", ("str",)),
  returns: "content",
)

#param-detail("route", ("str",), default: raw("\"above\"", lang: none))[
  弧的走向：`"above"` / `"below"` / `"left"` / `"right"`。
]

#param-detail("style", ("str",), default: raw("\"solid\"", lang: none))[
  `"dashed"` 画虚线弧（表示可选/条件转移）。
]

=== `jump`

从 `from` 到 `to` 画一条*单向*连线。线性模式下用 `route:` 走链上/下的大弧；
2D 模式下用 `bend:` 控制曲率。

#section-label[Example]

#wide-example(
  ```typ
  #jump("a", "c", route: "below")[skip]
  #jump("a", "c", bend: 0.15)[skip]
  #jump("a", "c")   // 直线，无标签
  ```,
  [
    #state-chain(
      state("a", initial: true)[a],
      state("b")[b],
      state("c")[c],
      jump("a", "c", route: "below")[skip],
    )
  ],
)

#section-label[Parameters]

#params-box("jump",
  ("from",       ("str",)),
  ("to",         ("str",)),
  ("body",       ("none", "content")),
  ("route",      ("str",)),
  ("height",     ("auto", "length")),
  ("bend",       ("float",)),
  ("label-pos",  ("ratio", "float")),
  ("label-side", ("int",)),
  ("style",      ("str",)),
  returns: "content",
)

#param-detail("route", ("str",), default: raw("\"above\"", lang: none))[
  *线性模式专用。* `"above"` / `"below"` 决定弧往链的哪一边走；算法对正向
  （from 在左）和反向（from 在右）两种写法对称。
]

#param-detail("height", ("auto", "length"), default: raw("auto", lang: none))[
  *线性模式专用。* 弧的峰深。默认取 `state-chain.jump-height`；多条同侧
  jump 嵌套时，给短的那条传更小的 `height:` 让它收在长弧内侧。
]

#param-detail("bend", ("float",), default: raw("0.0", lang: none))[
  *2D 模式专用。* 有符号曲率比（典型 `0.1`–`0.3`）。正值把曲线向"直线方向的
  视觉左侧"偏，用于绕开中间状态或分离重叠的平行边。
]

#param-detail("label-pos", ("ratio", "float"),
  default: raw("0.5", lang: none))[
  标签沿线位置（0 = 起点，1 = 终点）。用于避让。
]

#param-detail("label-side", ("int",), default: raw("1", lang: none))[
  `±1`：翻到另一侧。默认 `+perp` 指向"直线方向的视觉左侧"；若默认一侧正好
  指向邻近状态，改成 `-1` 让标签回到本线对面。
]

#section-label[Notes]

双向转移（A ↔ B）用 *`bi-jump`* 而不是写两条相反方向的 `jump` —— 后者画出来
是两条平行箭头，前者只画一条线、两头加箭头，更符合状态图惯例。

=== `bi-jump`

一条线上同时画两头箭头，两端各一个标签。*2D 模式专用*。

#section-label[Example]

```typ
#bi-jump("a", "b",
  forward: [a→b 标签],
  back:    [b→a 标签],
  bend: 0,         // 默认直线
)

// 两标签默认镜像放在线两侧（forward=+perp, back=-perp）。
// 默认一侧若压到旁边某根线上，把两 side 设成同号即可并到一侧。
#bi-jump("active", "grace",
  forward: [...], back: [...],
  back-side: 1,
)
```

#section-label[Parameters]

#params-box("bi-jump",
  ("from",         ("str",)),
  ("to",           ("str",)),
  ("forward",      ("none", "content")),
  ("back",         ("none", "content")),
  ("bend",         ("float",)),
  ("forward-side", ("int",)),
  ("back-side",    ("int",)),
  ("style",        ("str",)),
  returns: "content",
)

#param-detail("forward", ("none", "content"),
  default: raw("none", lang: none))[
  标注 `from → to` 方向，显示在靠近 `to` 的一端，默认 `+perp` 侧。
]

#param-detail("back", ("none", "content"), default: raw("none", lang: none))[
  标注 `to → from` 方向，显示在靠近 `from` 的一端，默认 `-perp` 侧。
]

#param-detail("forward-side", ("int",), default: raw("1", lang: none))[
  `±1`。与 `back-side` 同号 ⇒ 两标签并到同一侧；异号 ⇒ 镜像分两侧（默认）。
]

== 容器

=== `state-chain`

容纳所有状态节点和转移覆盖层的顶层容器。把 `state` / `loop` / `jump` /
`bi-jump` 以任意顺序传入即可，内部按类型分层渲染（连线 → 状态 → 标签）。

#section-label[Parameters]

#params-box("state-chain",
  ("..items",     ("content",)),
  ("gap",         ("length",)),
  ("col-gap",     ("length",)),
  ("row-gap",     ("length",)),
  ("loop-height", ("length",)),
  ("jump-height", ("length",)),
  ("min-size",    ("length",)),
  returns: "content",
)

#param-detail("gap", ("length",), default: raw("60pt", lang: none))[
  *线性模式* 相邻状态圆的水平间距。
]

#param-detail("col-gap", ("length",), default: raw("90pt", lang: none))[
  *2D 模式* 每单位 `pos.x` 对应的像素距离。
]

#param-detail("row-gap", ("length",), default: raw("100pt", lang: none))[
  *2D 模式* 每单位 `pos.y` 对应的像素距离。
]

#param-detail("loop-height", ("length",), default: raw("28pt", lang: none))[
  自环弧的最高点相对状态边缘的距离。
]

#param-detail("jump-height", ("length",), default: raw("48pt", lang: none))[
  线性越级弧的最高点相对链上/下边缘的距离。
]

#param-detail("min-size", ("length",), default: raw("44pt", lang: none))[
  状态最小直径（下限）。实际直径按 body 自适应，但不小于此。
]

== 综合示例：TCP 连接生命周期

把 `state` / `edge-label` / `loop` / `jump` 组合在一个链上：TCP 从 `CLOSED`
开始，经 `LISTEN` / `SYN_RECVD` 到 `ESTABLISHED`，两条 `close()` 分别从
LISTEN（提前取消监听）和 ESTABLISHED（正常关闭）回到 `CLOSED`。

```typ
#state-chain(
  state("closed", initial: true, accept: true)[CLOSED],
  state("listen",    edge-label: [listen()])[LISTEN],
  state("syn-recvd", edge-label: [SYN recv])[SYN_RECVD],
  state("established", edge-label: [ACK])[ESTABLISHED],
  loop("listen")[SYN recv],
  jump("listen", "closed", route: "above", style: "dashed")[close()],
  jump("established", "closed", route: "below", style: "dashed")[close()],
)
```

#align(center)[
  #state-chain(
    state("closed", initial: true, accept: true)[CLOSED],
    state("listen",    edge-label: [listen()])[LISTEN],
    state("syn-recvd", edge-label: [SYN recv])[SYN_RECVD],
    state("established", edge-label: [ACK])[ESTABLISHED],
    loop("listen")[SYN recv],
    jump("listen", "closed", route: "above", style: "dashed")[close()],
    jump("established", "closed", route: "below", style: "dashed")[close()],
  )
]

#v(4pt)

要点：

- `CLOSED` 同时有 `initial` 和 `accept` —— 初始状态的语义胜出（填充取绿色），
  双边框仍画（来自 `accept`）。
- 两条 `close()` 用 `style: "dashed"` 表示"软关闭"，视觉上和主链实线区分。
- 所有状态圆按最长的 `ESTABLISHED` 统一大小 —— `state-chain` 自动把所有
  `size: auto` 的状态对齐到池里最大的自然直径，不会出现不规则大小。
- LISTEN 同时挂 `loop`（自环）和 `listen→closed`（跳转），两者默认都走
  "上方"也不撞：`loop` 锚在状态正上方（±6pt），`jump` 自动挪到朝向目标
  的 *45°* 位置，两者占据状态边上的不同扇区。
- 一条 `above` 一条 `below`，避免两条 `close()` 长弧在同一侧堆叠。多条同侧
  jump 嵌套时，给短的那条传 `height:` 让它收浅（比长的至少小一半）。

== 2D 模式：任意拓扑

当状态之间不是简单的线性顺序 —— 比如订阅/订单流转里 active 可以绕三角进到
billing retry、grace period、revoke、expired —— 给每个 `state` 加上
`pos: (col, row)`，其余 API 不变，`state-chain` 自动切到 2D。

```typ
#state-chain(
  col-gap: 95pt, row-gap: 100pt,
  state("active",  pos: (0, 0), initial: true)[active],
  state("billing", pos: (3, 0), fill: palettes.pastel.yellow)[billing retry],
  state("grace",   pos: (1, 0.8), fill: palettes.pastel.green)[grace period],
  state("revoke",  pos: (2, 0.8), fill: palettes.pastel.red)[revoke],
  state("expired", pos: (1.5, 2.3), fill: palettes.pastel.red)[expired],
  loop("active", route: "above")[正常续期],
  bi-jump("active", "billing",
    forward: [60天内扣款失败],
    back:    [60天内成功续期]),
  bi-jump("active", "grace",
    forward: [取消订阅], back: [开启订阅],
    back-side: 1),
  jump("grace", "revoke")[取消订阅],
  jump("billing", "revoke"),
  jump("grace", "expired")[宽限期未续订],
  jump("active", "expired", label-side: -1)[取消订阅],
  jump("billing", "expired")[取消订阅 or 60天后仍扣款失败],
)
```

#align(center)[
  #state-chain(
    col-gap: 95pt, row-gap: 100pt,

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

#v(4pt)

2D 模式的几个要点：

- `pos` 是逻辑网格坐标（浮点即可），实际像素由 `col-gap` / `row-gap` 放大。
  最左/最上的状态自动贴到画布边。
- 2D 模式下 *没有*"自动相邻箭头" —— 每条边都要自己 `jump` / `bi-jump` 出来。
  状态上的 `edge-label:` 被忽略。
- *双向对用 `bi-jump`*：画一条线、两端各一个箭头和一个标签，而不是两条单向
  箭头并排。
- 画面分三层：*连线 → 状态 → 标签*，顺序无需手动调。连线穿过无关状态时被
  圆形自动遮住；标签压到圆形上也依然在最上层可读。
- 单向 `jump` 直线穿过中间状态，要真正绕开就加 `bend:` 往对侧推；多数
  情况下先尝试 `label-side: -1`（把标签翻到对面），比弯曲线更省画面。
- `bi-jump` 的两个标签默认镜像分两侧；如果默认一侧正好落到另一根线上，
  把 `back-side` 改成与 `forward-side` 同号，两个标签就并到一起。
- 标签自动按文字宽度做最小垂直偏移，`bend = 0` 的直线也不会压线。

== 局限

- *不做自动路由/避障* —— 2D 模式下长对角可能穿过中间状态，需要手动写
  `bend` 让它绕开；密集标签也可能相互压字，同样靠手动调 `bend` 的符号/
  大小分开。
- *不做复合状态* —— UML 的 "state with substates" 要自己用嵌套 region +
  state-chain 模拟。
- *不做自动编号/转移表* —— 要生成文档索引得用 Typst 的 `locate` 配合自定义
  metadata，本章不涉及。

换句话说：*布局是你自己定的*。`state-chain` 负责把状态画圆、把边画弯、让箭头
对齐切线、让标签不压线 —— 但 `pos` 和 `bend` 的值是设计者自己拍板的。密集
拓扑需要先在纸上摆一遍再抄进来。
