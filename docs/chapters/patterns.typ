#import "../../lib.typ": *
#import "../style.typ": *

= 常用写法速查 <patterns>

这一章不按 API 分层展开，而是按“你现在想完成什么”来组织。
如果你已经知道要画什么图，但不确定该从哪个组件开始，可以先看这里。

== 推荐学习顺序 <patterns-learning-path>

如果你是第一次使用 *blockcell*，建议按下面的顺序学习：

1. `cell`：先学会画单个方块
2. `region`：再学会把多个方块组合成一个结构
3. `schema`：给结构加标题和说明
4. `linked-schema`：表达“字段区 + 指向目标区”
5. 按场景进入专题章节：
   - 流程图：看“流程图”
   - 状态机：看“状态转换图”
   - 层级结构：看“层级树图”
   - 参与者交互：看“时序图”

== 先选对组件 <patterns-choose-components>

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (120pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[只画一个方块],
      [用 #api-ref("layer1-cell", "cell")。适合字段、状态块、标签块、单个节点。],
      text(weight: "bold")[把多个方块包成一个整体],
      [用 #api-ref("layer2-region", "region")。适合结构体、字段组、逻辑区域。],
      text(weight: "bold")[给图加标题和说明],
      [用 #api-ref("layer3-schema", "schema")。适合把一个结构作为独立图块展示。],
      text(weight: "bold")[表达“指针 / 引用 → 目标区”],
      [用 #api-ref("layer3-linked-schema", "linked-schema")。适合堆对象、引用关系、上下层结构。],
      text(weight: "bold")[画固定宽度字段],
      [用 #api-ref("layer3-bit-row", "bit-row")。适合协议头、寄存器、位字段布局。],
      text(weight: "bold")[画线性流程],
      [用 #api-ref("flows-flow-col", "flow-col")。需要分支时再配合 #api-ref("flows-branch", "branch")、#api-ref("flows-switch", "switch")、#api-ref("flows-flow-loop", "flow-loop")。],
      text(weight: "bold")[画状态流转],
      [用 #api-ref("states-state-chain", "state-chain")。简单链式和复杂状态机都从这里开始。],
      text(weight: "bold")[画层级结构],
      [用 #api-ref("tree-tree", "tree")。适合目录树、组织结构、JSON 层级。],
      text(weight: "bold")[画参与者交互],
      [用 #api-ref("layer3-seq-lane", "seq-lane")。适合请求链路、协议交互、服务调用。],
    )
  ]
]

== 从最小组合开始 <patterns-start-small>

很多图都可以从下面这三个层次开始搭起来：

- `cell`：单个元素
- `region`：一组元素
- `schema`：一个完整图块

#section-label[最小结构图]

#example-pair(
  ```typst
  #schema(title: [User])[
    #region[
      #cell[id]
      #cell[name]
      #cell[email]
    ]
  ]
  ```,
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

这个组合适合大多数“结构说明图”：

- 数据结构
- 配置块
- 模块边界
- 简单表意图块

== 复用颜色 <patterns-colors>

优先使用内置调色板，而不是在文档里反复手写颜色。

#section-label[直接使用内置调色板]

#example-pair(
  ```typst
  #let C = palettes.pastel

  #cell(fill: C.blue)[Inbox]
  #cell(fill: C.green)[Done]
  #cell(fill: C.yellow)[Pending]
  ```,
  [
    #let C = palettes.pastel
    #cell(fill: C.blue)[Inbox]
    #h(4pt)
    #cell(fill: C.green)[Done]
    #h(4pt)
    #cell(fill: C.yellow)[Pending]
  ],
)

适合的做法：

- 用 `palettes.pastel` 做通用配色
- 用 `palettes.status` 表达成功 / 警告 / 错误
- 用 `palettes.categorical` 给多个分组分配不同颜色
- 用领域调色板快速开始真实场景图

#section-label[语义状态色]

#example-pair(
  ```typst
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]
  ```,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
  ],
)

如果你想把同一套状态色用于别的组件，也可以直接展开：

#example-pair(
  ```typst
  #cell(..palettes.status.info)[Queued]
  #cell(..palettes.status.danger)[Failed]
  ```,
  [
    #cell(..palettes.status.info)[Queued]
    #h(6pt)
    #cell(..palettes.status.danger)[Failed]
  ],
)

== 定义自己的颜色别名 <patterns-custom-colors>

当一张图里会重复使用同一组颜色时，先起一个短别名，代码会更短，也更容易统一调整。

#example-pair(
  ```typst
  #let C = (
    header: rgb("#BBDEFB"),
    meta: rgb("#B2DFDB"),
    flag: rgb("#FFE082"),
    data: rgb("#FFCCBC"),
  )

  #cell(fill: C.header)[Header]
  #cell(fill: C.meta)[Length]
  #cell(fill: C.flag)[Flags]
  ```,
  [
    #let C = (
      header: rgb("#BBDEFB"),
      meta: rgb("#B2DFDB"),
      flag: rgb("#FFE082"),
      data: rgb("#FFCCBC"),
    )

    #cell(fill: C.header)[Header]
    #h(4pt)
    #cell(fill: C.meta)[Length]
    #h(4pt)
    #cell(fill: C.flag)[Flags]
  ],
)

建议：

- 在单张图里用 `#let C = ...`
- 颜色名按语义命名，而不是按视觉命名
- 先让颜色服务于结构，再考虑装饰性

== 用 `.with()` 减少重复 <patterns-with>

当你反复写同一组参数时，用 `.with()` 固定它们。

#section-label[固定尺寸]

#example-pair(
  ```typst
  #let mc = cell.with(
    width: 28pt,
    height: 20pt,
    inset: 2pt,
  )

  #mc[03] #mc[21] #mc[7F] #mc[A0]
  ```,
  [
    #let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
    #mc[03] #mc[21] #mc[7F] #mc[A0]
  ],
)

这类写法适合：

- 内存字节格
- 缓存行
- 寄存器字段
- 固定尺寸的小单元格

#section-label[固定一组常用参数]

#example-pair(
  ```typst
  #let field = cell.with(
    width: 44pt,
    height: 24pt,
    fill: palettes.pastel.blue,
  )

  #field[id] #field[len] #field[cap]
  ```,
  [
    #let field = cell.with(
      width: 44pt,
      height: 24pt,
      fill: palettes.pastel.blue,
    )
    #field[id] #field[len] #field[cap]
  ],
)

经验上：

- `.with()` 适合固定尺寸、间距、默认颜色
- 如果你要表达更明确的业务语义，可以再包一层自己的函数名

== 给常见结构起名字 <patterns-helpers>

当一个组合会在文档里反复出现时，建议直接定义一个小 helper。

#example-pair(
  ```typst
  #let ptr-field(body) = cell(
    fill: palettes.rust.ptr,
  )[#body#sub-label[2/4/8]]

  #ptr-field[ptr]
  ```,
  [
    #let ptr-field(body) = cell(
      fill: palettes.rust.ptr,
    )[#body#sub-label[2/4/8]]

    #ptr-field[ptr]
  ],
)

这样做的好处是：

- 语义更清楚
- 代码更短
- 后续统一改样式更容易

== 让多个图并排展示 <patterns-side-by-side>

当你想比较多个结构时，可以把多个 `schema` 紧挨着写。

#section-label[并排对比]

#wide-example(
  ```typst
  #schema(title: [A])[
    #region[#cell[x]]
  ]#schema(title: [B])[
    #region[#cell[y]]
  ]#schema(title: [C])[
    #region[#cell[z]]
  ]
  ```,
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

如果你发现某个图块太宽，可以给它加 `width:`，让标题、说明和主体一起控制在合适宽度内。

#section-label[限制图块宽度]

#example-pair(
  ```typst
  #linked-schema(
    width: 160pt,
    title: [Box<T>],
    desc: [较长说明会在这里自动换行。],
    fields: (
      cell(fill: palettes.rust.ptr)[ptr],
    ),
    cell(fill: palettes.rust.any)[T],
  )
  ```,
  [
    #linked-schema(
      width: 160pt,
      title: [Box<T>],
      desc: [较长说明会在这里自动换行。],
      fields: (
        cell(fill: palettes.rust.ptr)[ptr],
      ),
      cell(fill: palettes.rust.any)[T],
    )
  ],
)

== 画结构图时的常见组合 <patterns-common-combos>

下面这些组合最常见，也最值得优先掌握。

#section-label[`cell` + `region`]

适合：字段组、结构体、逻辑块

#example-pair(
  ```typst
  #region[
    #cell[id]
    #cell[len]
    #cell[cap]
  ]
  ```,
  [
    #region[
      #cell[id]
      #cell[len]
      #cell[cap]
    ]
  ],
)

#section-label[`schema` + `region`]

适合：独立展示一个结构

#example-pair(
  ```typst
  #schema(title: [Vec<T>])[
    #region[
      #cell[ptr]
      #cell[len]
      #cell[cap]
    ]
  ]
  ```,
  [
    #schema(title: [Vec<T>])[
      #region[
        #cell[ptr]
        #cell[len]
        #cell[cap]
      ]
    ]
  ],
)

#section-label[`linked-schema`]

适合：引用关系、堆对象、上下层结构

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
  ```,
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

== 按任务进入专题章节 <patterns-by-task>

如果你已经知道自己要画什么，可以直接按下面的路径走：

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (130pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[流程图],
      [从 #api-ref("flows-flow-col", "flow-col") 开始；需要条件分支时看 #api-ref("flows-branch", "branch") / #api-ref("flows-branch-merge", "branch-merge") / #api-ref("flows-switch", "switch")；需要回路时看 #api-ref("flows-flow-loop", "flow-loop")。],
      text(weight: "bold")[状态机],
      [从 #api-ref("states-state-chain", "state-chain") 开始；简单状态链先用自动布局，复杂拓扑再用 2D 模式。],
      text(weight: "bold")[层级树],
      [从 #api-ref("tree-tree", "tree") 开始；节点通常用 #api-ref("tree-node", "node")，也可以直接放 #api-ref("layer1-cell", "cell")、#api-ref("flows-process", "process") 等内容。],
      text(weight: "bold")[时序图],
      [从 #api-ref("layer3-seq-lane", "seq-lane") 开始；先掌握 #api-ref("seq-seq-call", "seq-call")、#api-ref("seq-seq-ret", "seq-ret")、#api-ref("seq-seq-note", "seq-note")，再看片段和自动编号。],
      text(weight: "bold")[协议头 / 位字段],
      [从 #api-ref("layer3-bit-row", "bit-row") 开始；先把一行画清楚，再组合成完整头部。],
    )
  ]
]

== 什么时候该拆成 helper <patterns-when-helper>

当你遇到下面任一情况时，就值得把写法提炼成 helper：

- 同一组参数重复出现 3 次以上
- 同一种颜色语义反复出现
- 同一种结构组合反复出现
- 你希望图里的命名更贴近业务语义

一个简单原则是：

- 重复的是“样式”时，用 `.with()`
- 重复的是“语义组合”时，定义自己的函数

== 保持图简单的建议 <patterns-keep-simple>

为了让图更稳定、也更容易维护，建议优先遵循这些做法：

- 先用最少的组件把结构表达清楚
- 一张图只强调一个重点
- 颜色优先表达分组和语义，不要一次引入太多颜色
- 复杂案例放到 `examples/`，正文里保留最小示例
- 先复用已有 helper，再考虑新增新的写法

== 下一步看哪里 <patterns-next>

- 想看完整组件参考：继续阅读后面的 Layer 1 / 2 / 3 章节
- 想找真实场景示例：看“完整示例”章节和 `examples/`
- 想画流程图、状态机、树图、时序图：直接跳到对应专题章节
