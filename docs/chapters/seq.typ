#import "../../lib.typ": *
#import "../style.typ": *

= 时序图 <seq>

*blockcell* 内置一套覆盖 UML 词汇的时序图工具 —— #api-ref("layer3-seq-lane", "seq-lane")（声明式 API）
与 `seq-puml`（PlantUML 兼容层）。两者共用同一套渲染引擎，所以行为完全
一致：能用 PlantUML 表达的，几乎都能用 Typst API 直接写出来。

适用范围：*参与者之间互相调用*的交互流程（API 调用链、协议握手、登录流程、
微服务编排……）。如果想表达"单一对象在时间上的状态变化"，请用 #api-ref("layer3-lane", "lane")
（在"组合"章节），或用"状态转换图"章节里的 #api-ref("states-state-chain", "state-chain")。

#v(6pt)

#align(center)[
  #region(fill: rgb("#E0F2F1"), width: 100%)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (84pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[消息],
      text(size: 0.85em)[#api-ref("seq-seq-call", "seq-call") `(from, to)[..]` 同步调用 ·
        #api-ref("seq-seq-ret", "seq-ret") `(from, to)[..]` 返回 · `from == to` 自动渲染为#doc-link("seq-self-call")[自调用]回环],
      text(size: 0.85em, weight: "bold")[便签],
      text(size: 0.85em)[#api-ref("seq-seq-note", "seq-note") `(over)[..]` 折角便签 · #api-ref("seq-seq-act", "seq-act") `(who)[..]`
        单列工作块 · #api-ref("seq-seq-ref", "seq-ref") `(over)[..]` 外部引用框],
      text(size: 0.85em, weight: "bold")[片段],
      text(size: 0.85em)[#doc-link("seq-fragments")[`seq-alt` + `seq-else` · `seq-opt` · `seq-loop` ·
        `seq-par`] · 还有 `group` / `break` / `critical`（详见对应小节）],
      text(size: 0.85em, weight: "bold")[节奏],
      text(size: 0.85em)[#doc-link("seq-structure")[`seq-divider[..]` 阶段分隔 · `seq-delay[..]`
        时间流逝 · `seq-space()` 纯空行]],
      text(size: 0.85em, weight: "bold")[生命周期],
      text(size: 0.85em)[#doc-link("seq-lifecycle")[`seq-create(who)` 内联头部 · `seq-destroy(who)`
        × 标记并截断生命线]],
      text(size: 0.85em, weight: "bold")[边界],
      text(size: 0.85em)[#doc-link("seq-boundary-arrows")[消息端点用 `"["` / `"]"` 表示图左 / 右边缘，箭头
        从外部进入或离开]],
      text(size: 0.85em, weight: "bold")[编号],
      text(size: 0.85em)[#doc-link("seq-autonumber")[`autonumber:` 参数（顶层）·
        `seq-autonumber()` / `seq-autonumber-stop()` /
        `seq-autonumber-resume()`（内嵌）]],
      text(size: 0.85em, weight: "bold")[分组],
      text(size: 0.85em)[#doc-link("seq-boxes")[`boxes:` 参数定义连续参与者的 swim lane 框]],
      text(size: 0.85em, weight: "bold")[兼容层],
      text(size: 0.85em)[`seq-puml(body)` 把 PlantUML 语法直接当字符串传入,
        参数透传给 #api-ref("layer3-seq-lane", "seq-lane")],
    )
  ]
]

== 快速上手 <seq-quick-start>

最基础的"客户端 → 业务 → 数据库"调用：

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "biz")[POST /order],
    seq-note("biz")[校验库存],
    seq-alt([ok],
      seq-call("biz", "db")[INSERT],
      seq-ret("db", "biz")[OK],
    ),
    seq-ret("biz", "client")[201],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "biz")[POST /order],
      seq-note("biz")[校验库存],
      seq-alt([ok],
        seq-call("biz", "db")[INSERT],
        seq-ret("db", "biz")[OK],
      ),
      seq-ret("biz", "client")[201],
    )
  ],
)

#v(4pt)

读法：参与者按 step 中 id 首次出现顺序自动从左到右排列；颜色循环取自
`palettes.categorical`。`seq-call` 默认开"激活矩形"（参与者正在执行的
窄竖条），匹配的 `seq-ret` 闭合它。`seq-alt` 的首参为方括号条件，其余
是嵌套 step。所有 step 函数的"语义参数"都通过末尾 content block 传入
（`seq-call("a", "b")[label]`）。

== 基础消息 <seq-basic-messages>

[#metadata("seq-seq-ret") <seq-seq-ret>]
=== `seq-call` / `seq-ret` <seq-seq-call>

`seq-call` 是同步调用（实线 + 实心三角箭头）；`seq-ret` 是返回（虚线 +
开口 V 形箭头）。两者共用 `(from, to)[label]` 形式，第三个参数（content
block）是消息上方的小字标注。

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[req],
    seq-call("b", "c")[forward],
    seq-ret("c", "b")[ack],
    seq-ret("b", "a")[done],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[req],
      seq-call("b", "c")[forward],
      seq-ret("c", "b")[ack],
      seq-ret("b", "a")[done],
    )
  ],
)

#v(4pt)

激活矩形是自动跟踪的：每次 `seq-call(A, B)` 把 A、B 都"激活"（如果还没
激活的话），匹配的 `seq-ret` 关闭。多个 call 嵌套、跨片段，都按调用栈
正常工作。如果不想要激活，给 `seq-lane` 传 `activate: false`。

可以用 `stroke:` 给单条消息线染色：

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[normal],
    seq-call("a", "b", stroke: red)[error],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[normal],
      seq-call("a", "b", stroke: red)[error],
    )
  ],
)

#v(4pt)

=== 自调用与嵌套 <seq-self-call>

当 `from == to` 时，`seq-call` 自动渲染为右侧的 U 形回环，激活区会展开
出一段右移的子矩形（可嵌套）：

#wide-example(
  ```typ
  #seq-lane(
    seq-call("svc", "svc")[outer],
    seq-call("svc", "svc")[inner],
    seq-ret("svc", "svc")[inner ok],
    seq-ret("svc", "svc")[outer ok],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("svc", "svc")[outer],
      seq-call("svc", "svc")[inner],
      seq-ret("svc", "svc")[inner ok],
      seq-ret("svc", "svc")[outer ok],
    )
  ],
)

#v(4pt)

省略 `seq-ret` 时引擎也会自动收拢：当一个参与者的下一个动作是发送消息
给*别人*，他自己未完成的自调用会自动闭合。这让简单的 "validate input"
之类的自调用可以只写一行 `seq-call("svc", "svc")[validate]`，无需手写
对应的 `seq-ret`。

== 便签与注解 <seq-notes>

=== `seq-note` <seq-seq-note>

折角便签，置于一个或多个参与者上方。`over` 接受单个 id 或 `("a", "b")`
跨列。

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[req],
    seq-note("b")[单参与者便签],
    seq-call("b", "c")[forward],
    seq-note(("b", "c"))[跨两列的备注],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[req],
      seq-note("b")[单参与者便签],
      seq-call("b", "c")[forward],
      seq-note(("b", "c"))[跨两列的备注],
    )
  ],
)

#v(4pt)

=== `seq-act` <seq-seq-act>

`seq-act(who)[..]` 在单一列内画一个着色的工作块，比便签更醒目，适合表达
"这个参与者本地做了一件事"。

注意：`seq-act` 不能落在该参与者*已经被激活*的行上 —— 一个宽框压在窄
激活竖条上视觉很乱。引擎会 panic 给提示，让你改用 `seq-note` 标注。

=== `seq-ref` <seq-seq-ref>

UML 的"引用框"，表达"这一段交互的细节见另一张图"。矩形边框 + 左上角 `ref`
角标，跨指定参与者：

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "auth")[login],
    seq-ref(("auth", "db"))[
      详细凭证校验流程 (auth-flow)
    ],
    seq-ret("auth", "client")[token],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "auth")[login],
      seq-ref(("auth", "db"))[
        详细凭证校验流程 (auth-flow)
      ],
      seq-ret("auth", "client")[token],
    )
  ],
)

#v(4pt)

== 片段 <seq-fragments>

UML 把"分支 / 循环 / 可选 / 并行"等结构封装为*组合片段*（combined
fragment）—— 一个虚线框，左上角带操作子名。`seq-lane` 提供了完整集合，
全都用相同的"`seq-X(condition, ..steps)`"形式：

#grid(
  columns: (170pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-alt(cond, ..)`],
  [可选分支；首参是方括号条件。],
  text(weight: "bold")[`seq-else(label)`],
  [`seq-alt` 内部的*分支分隔符* —— 后续 sibling 渲染在新分支下，框上
   多一条虚线 + `[else: ..]` 标签。],
  text(weight: "bold")[`seq-opt(cond, ..)`],
  [可选执行（"如果条件满足才走"）。],
  text(weight: "bold")[`seq-loop(cond, ..)`],
  [循环。],
  text(weight: "bold")[`seq-par(label, ..)`],
  [并行；约定俗成把不同分支并列。],
)

`group` / `break` / `critical` 当前以"通用 fragment kind"形式存在，主要
通过 `seq-puml` 的 PlantUML 输入产生（详见兼容层小节）。直接用 API 时
固定的 `seq-alt` / `seq-opt` / `seq-loop` / `seq-par` 已覆盖 95% 用例。

#section-label[alt + else]

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "server")[GET],
    seq-alt([cache hit],
      seq-call("server", "cache")[lookup],
      seq-ret("cache", "server")[value],
      seq-else([cache miss]),
      seq-call("server", "cache")[lookup],
      seq-ret("cache", "server")[nil],
      seq-call("server", "server")[compute],
    ),
    seq-ret("server", "client")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET],
      seq-alt([cache hit],
        seq-call("server", "cache")[lookup],
        seq-ret("cache", "server")[value],
        seq-else([cache miss]),
        seq-call("server", "cache")[lookup],
        seq-ret("cache", "server")[nil],
        seq-call("server", "server")[compute],
      ),
      seq-ret("server", "client")[200],
    )
  ],
)

#v(4pt)

`seq-else` 是一个 step 标记，放在 `seq-alt` 的 children 里就行；可以放
任意多个，每个开启一个新分支。

#section-label[opt / loop / par]

#wide-example(
  ```typ
  #seq-lane(
    seq-loop([每 5s],
      seq-call("agent", "server")[heartbeat],
      seq-ret("server", "agent")[ack],
    ),
    seq-opt([配置变更],
      seq-call("server", "agent")[reload],
    ),
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-loop([每 5s],
        seq-call("agent", "server")[heartbeat],
        seq-ret("server", "agent")[ack],
      ),
      seq-opt([配置变更],
        seq-call("server", "agent")[reload],
      ),
    )
  ],
)

#v(4pt)

== 节奏与结构 <seq-structure>

把交互流分段、留白、表达"一段时间过去了"的工具：

#grid(
  columns: (170pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-divider[label]`],
  [全宽双横线 + 居中粗体标签。划分逻辑阶段（"初始化 / 主循环 / 收尾"）。],
  text(weight: "bold")[`seq-delay[label]`],
  ["时间过去了"。每条生命线在该行画一组垂直省略号，可选居中 pill 标签
   （如 "5 minutes later"）。],
  text(weight: "bold")[`seq-space()`],
  [纯空白行。撑高布局。],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-call("c", "s")[POST /job],
    seq-divider[handshake],
    seq-call("s", "w")[enqueue],
    seq-ret("w", "s")[job-id],
    seq-ret("s", "c")[202],
    seq-delay[5 minutes later],
    seq-call("c", "s")[GET /job/42],
    seq-ret("s", "c")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("c", "s")[POST /job],
      seq-divider[handshake],
      seq-call("s", "w")[enqueue],
      seq-ret("w", "s")[job-id],
      seq-ret("s", "c")[202],
      seq-delay[5 minutes later],
      seq-call("c", "s")[GET /job/42],
      seq-ret("s", "c")[200],
    )
  ],
)

#v(4pt)

== 生命周期 <seq-lifecycle>

UML 区分*静态参与者*（图开始就在）和*动态创建*（在某次调用中诞生），
后者还可能被显式销毁。`seq-create` 与 `seq-destroy` 各自对应：

#grid(
  columns: (170pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-create(who)`],
  [把这个参与者的*头部框延迟到此行*渲染，生命线从这行开始往下走。顶部
   header 行为它留出空槽。常配合发起创建的 `seq-call` 使用。],
  text(weight: "bold")[`seq-destroy(who)`],
  [在此行画 ×；该参与者的生命线截断，已开的激活全部关闭，之后不应再
   有消息引用这个 id。],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "factory")[new product],
    seq-create("worker"),
    seq-call("factory", "worker")[spawn],
    seq-ret("worker", "factory")[ready],
    seq-ret("factory", "client")[product],
    seq-call("client", "worker")[use],
    seq-ret("worker", "client")[result],
    seq-destroy("worker"),
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "factory")[new product],
      seq-create("worker"),
      seq-call("factory", "worker")[spawn],
      seq-ret("worker", "factory")[ready],
      seq-ret("factory", "client")[product],
      seq-call("client", "worker")[use],
      seq-ret("worker", "client")[result],
      seq-destroy("worker"),
    )
  ],
)

#v(4pt)

== 边界箭头 <seq-boundary-arrows>

UML 用图的左右边缘表达"系统外部"。把消息的 `from` 或 `to` 设成字符串
`"["`（左边缘）或 `"]"`（右边缘），箭头就从图边进入 / 离开，不需要
真实的"外部参与者"占用一列。

#wide-example(
  ```typ
  #seq-lane(
    seq-call("[", "browser")[page request],
    seq-call("browser", "api")[POST /op],
    seq-call("api", "]")[publish metric],
    seq-ret("api", "browser")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("[", "browser")[page request],
      seq-call("browser", "api")[POST /op],
      seq-call("api", "]")[publish metric],
      seq-ret("api", "browser")[200],
    )
  ],
)

#v(4pt)

边界端点不参与"自动 id 收集"，也不会被画成参与者头部 / 生命线 —— 它们
只是渲染锚点。

== 自动编号 <seq-autonumber>

PlantUML 的 `autonumber` 在 `seq-lane` 里有两条等价路径：

#section-label[顶层参数]

`seq-lane(autonumber: ..)` 一参数搞定常见用法：

#grid(
  columns: (170pt, 1fr),
  row-gutter: 5pt,
  raw("false", lang: none),
  [关闭（默认）。],
  raw("true", lang: none),
  [从 1 开始，步长 1。],
  raw("(start: int, step: int)", lang: none),
  [自定义起始值与步长。],
)

#wide-example(
  ```typ
  #seq-lane(
    autonumber: (start: 100, step: 5),
    seq-call("a", "b")[hi],
    seq-call("b", "c")[forward],
    seq-ret("c", "a")[done],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      autonumber: (start: 100, step: 5),
      seq-call("a", "b")[hi],
      seq-call("b", "c")[forward],
      seq-ret("c", "a")[done],
    )
  ],
)

#v(4pt)

#section-label[内嵌控制]

需要在中间暂停 / 恢复 / 重新设定起点时，用三个控制 step：

#grid(
  columns: (200pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-autonumber(start, step)`],
  [启动或重置计数器。命名参数 `start:` / `step:` 都有默认值（1, 1）。],
  text(weight: "bold")[`seq-autonumber-stop()`],
  [暂停。中间的 call / ret 不会被编号。],
  text(weight: "bold")[`seq-autonumber-resume(step:)`],
  [从上次暂停处恢复。可选 `step:` 改步长。],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-autonumber(),
    seq-call("a", "b")[step 1],
    seq-call("b", "c")[step 2],
    seq-autonumber-stop(),
    seq-call("a", "b")[(unnumbered)],
    seq-autonumber-resume(),
    seq-call("a", "b")[step 3],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-autonumber(),
      seq-call("a", "b")[step 1],
      seq-call("b", "c")[step 2],
      seq-autonumber-stop(),
      seq-call("a", "b")[(unnumbered)],
      seq-autonumber-resume(),
      seq-call("a", "b")[step 3],
    )
  ],
)

#v(4pt)

数字以粗体 `*N.*` 格式贴在原 label 前面。

== 参与者 <seq-participants>

=== `participants` 参数 <seq-participants-arg>

不传时，引擎按 step id 首次出现顺序自动收集，配色循环 `palettes.categorical`。
传入时显式锁定顺序与显示名：

```typ
#seq-lane(
  participants: (
    (id: "browser", name: [Browser]),
    (id: "api",     name: [API], fill: rgb("#FFE0B2")),
    (id: "auth",    name: [Auth]),
    (id: "db",      name: [DB]),
  ),
  seq-call("browser", "api")[POST /login],
  // ...
)
```

每项至少 `id:`；`name:` 缺省取 `raw(id)`，`fill:` 缺省取调色板循环色。
*没在任何 step 中出现*的 id 会被拒绝（panic）—— 与其留个孤立的列，
不如告诉作者删掉。

=== `boxes` —— Swim lane 分组 <seq-boxes>

PlantUML 的 `box ... end box`：把*相邻*的若干参与者和它们的生命线一同
框起来，作为逻辑边界（"内部服务" / "存储层"……）。

#wide-example(
  ```typ
  #seq-lane(
    participants: (
      (id: "browser", name: [Browser]),
      (id: "api",     name: [API]),
      (id: "worker",  name: [Worker]),
    ),
    boxes: (
      (name: [Backend], ids: ("api", "worker"),
       fill: rgb("#B3E5FC")),
    ),
    seq-call("browser", "api")[POST /op],
    seq-call("api", "worker")[enqueue],
    seq-ret("worker", "api")[done],
    seq-ret("api", "browser")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      participants: (
        (id: "browser", name: [Browser]),
        (id: "api",     name: [API]),
        (id: "worker",  name: [Worker]),
      ),
      boxes: (
        (name: [Backend], ids: ("api", "worker"),
         fill: rgb("#B3E5FC")),
      ),
      seq-call("browser", "api")[POST /op],
      seq-call("api", "worker")[enqueue],
      seq-ret("worker", "api")[done],
      seq-ret("api", "browser")[200],
    )
  ],
)

#v(4pt)

每个 box 是 `(name:, ids: ("a", "b", ..), fill?:)`。`ids` 必须在最终
列序中*连续*，否则 panic。框背景从顶部标题栏一直延伸到图体底部，参与者
头部、生命线、激活、消息箭头都叠在它之上。

== `seq-puml` —— PlantUML 兼容层

把 PlantUML 序列图源码以字符串 / 反引号 raw block 直接喂给 `seq-puml`，
解析后转译为对应的 `seq-lane` + `seq-*` 调用。所有 `seq-lane` 的样式
参数都可透传。

#wide-example(
  ```typ
  #seq-puml(`
    participant Browser
    box "Backend" #LightBlue
      participant API
      participant Worker
    end box

    autonumber
    Browser -> API : POST /login
    alt cache hit
      API -> Worker : lookup
      Worker --> API : value
    else cache miss
      API -> Worker : compute
      Worker --> API : value
    end
    ...
    API --> Browser : 200
  `)
  ```,
  [
    #seq-puml(width: 100%, `
      participant Browser
      box "Backend" #LightBlue
        participant API
        participant Worker
      end box

      autonumber
      Browser -> API : POST /login
      alt cache hit
        API -> Worker : lookup
        Worker --> API : value
      else cache miss
        API -> Worker : compute
        Worker --> API : value
      end
      ...
      API --> Browser : 200
    `)
  ],
)

#v(4pt)

#section-label[支持的 PlantUML 子集]

#grid(
  columns: (180pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[参与者],
  text(size: 0.9em)[`participant` / `actor` / `boundary` / `control` /
    `entity` / `database` / `collections` / `queue`（统一渲染为矩形）·
    `"Long Name" as alias` · `#color`],
  text(weight: "bold", size: 0.9em)[消息],
  text(size: 0.9em)[`->` / `-->` / `->>` / `-->>` / `<-` / `<--` ·
    `-[#color]>` 染色 · `[->` / `[<-` / `->]` / `<-]` 边界箭头],
  text(weight: "bold", size: 0.9em)[后缀],
  text(size: 0.9em)[`!!` 销毁目标 · `**` 创建目标 ·
    `++` / `--` 由自动激活吸收],
  text(weight: "bold", size: 0.9em)[激活],
  text(size: 0.9em)[`activate` / `deactivate` 自动跟踪，显式语句也兼容],
  text(weight: "bold", size: 0.9em)[便签],
  text(size: 0.9em)[`note over A`（单 / 双参与者，单行 / 多行 +
    `end note`）· `note left/right` · `note across` · `ref over A, B`],
  text(weight: "bold", size: 0.9em)[片段],
  text(size: 0.9em)[`alt` / `else` / `end` · `opt` · `loop` · `par` ·
    `group <label>` · `break` · `critical`（嵌套任意层）],
  text(weight: "bold", size: 0.9em)[节奏],
  text(size: 0.9em)[`== text ==` 分隔线 · `...` / `...label...` 时间流逝 ·
    `\|\|\|` / `\|\|N\|\|` 空白行],
  text(weight: "bold", size: 0.9em)[生命周期],
  text(size: 0.9em)[`create X` / `destroy X` · `**` / `!!` 后缀],
  text(weight: "bold", size: 0.9em)[编号],
  text(size: 0.9em)[`autonumber [start [step]]` / `autonumber stop` /
    `autonumber resume [step]`],
  text(weight: "bold", size: 0.9em)[分组],
  text(size: 0.9em)[`box "Name" [#color] ... end box`],
  text(weight: "bold", size: 0.9em)[忽略],
  text(size: 0.9em)[`@startuml` / `@enduml` / `'` 单行注释 /
    `skinparam` / `hide` / `title` / `header` / `footer`],
)

#v(6pt)

未实现的项：`hnote` / `rnote` 形状变体（识别为普通 note）；倾斜箭头
`->(N)`；Teoz 模式 `&` 并行；`mainframe`；Creole 富文本（Typst markup
本身已能处理 `*bold*` 与 `_italic_` 等基本标记，超出的不展开）。

#section-label[宽松解析]

无法识别的行*静默跳过*。这让从 PlantUML 复制粘贴时不至于因为细节差异
直接 panic，但代价是拼写错误也不会报警。如果手写 puml 源，建议复制后
对比一遍渲染结果再交付。

== `seq-lane` 完整参数

#params-box("seq-lane",
  ("..steps",          ("content",)),
  ("width",            ("auto", "length")),
  ("step-height",      ("length",)),
  ("header-height",    ("length",)),
  ("column-gap",       ("length",)),
  ("row-gap",          ("length",)),
  ("activate",         ("bool",)),
  ("activation-width", ("length",)),
  ("autonumber",       ("bool", "dictionary")),
  ("participants",     ("none", "array")),
  ("boxes",            ("none", "array")),
  returns: "content",
)

#param-detail("participants", ("none", "array"),
  default: raw("none", lang: none))[
  显式锁定参与者顺序与显示名。每项是 `(id: "biz", name: [Business],
  fill: color)` 字典。未传时按 step id 首次出现顺序自动推导，颜色循环
  使用 `palettes.categorical`。`id` 必须在 step 中出现过 —— 孤立的列
  会 panic。
]

#param-detail("boxes", ("none", "array"),
  default: raw("none", lang: none))[
  Swim lane 分组。每项 `(name: [..], ids: ("a", "b", ..), fill?: color)`。
  `ids` 必须在最终列序中*连续*。`name` 渲染为顶部居中粗体标题。框
  贯穿整个图体（headers + 生命线 + 消息），形成视觉容器。
]

#param-detail("autonumber", ("bool", "dictionary"),
  default: raw("false", lang: none))[
  顶层自动编号。`true` 等价于 `(start: 1, step: 1)`；传字典自定义。
  内嵌精细控制用 `seq-autonumber()` / `seq-autonumber-stop()` /
  `seq-autonumber-resume(step:)` 这三个 step 函数。两条路径共用同一
  实现，可以混用。
]

#param-detail("activate", ("bool",), default: raw("true", lang: none))[
  是否自动绘制激活矩形（"focus of control"，参与者正在执行的窄竖条）。
  `seq-call` 开启，匹配的 `seq-ret` 关闭；自调用展开为右移子矩形（可
  嵌套）。关闭时所有消息直接连在生命线上，没有矩形。
]

#param-detail("activation-width", ("length",),
  default: raw("0.8em", lang: none))[
  激活矩形的宽度。会同时影响嵌套自调用矩形的偏移量（嵌套子矩形偏移
  =`activation-width / 2`，与父矩形重叠一半）。
]

#param-detail("step-height", ("length",), default: raw("3em", lang: none))[
  每个 step 行的高度（不含行间距）。把图压扁就调小，需要更多说明空间
  就调大。便签 / 引用框等会自适应到这个高度。
]

#param-detail("column-gap", ("length",), default: raw("1em", lang: none))[
  参与者列之间的水平间距。影响消息箭头长度与便签宽度。
]

#param-detail("row-gap", ("length",), default: raw("0.4em", lang: none))[
  行间距，仅影响相邻 step 行之间的留白；fragment 边框默认与行底对齐。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  整张图的宽度。`auto` 取所在容器的 `100%`。在文档级别一般固定一个
  pt 值（例如 `380pt`）以保证多张图水平对齐。
]
