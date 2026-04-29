#import "../../lib.typ": *
#import "../style.typ": *

= 从任务开始选择 API <api-overview>

这一章不是完整参考，而是一张导航图。
如果你是第一次使用 *blockcell*，先从这里判断“我想画什么”，再进入对应章节。

*blockcell* 适合绘制 *结构清晰、由块和容器组成的图*。你通常不需要先理解全部 API，只需要先选对入口。

== 先看这三个层级 <api-overview-layers>

#align(center)[
  #grid(
    columns: 3,
    column-gutter: 12pt,

    region(fill: rgb("#E3F2FD"), width: 155pt)[
      #text(weight: "bold")[Layer 1 — 原子]
      #v(3pt)
      #text(size: 0.9em)[
        先从单个视觉元素开始。\\
        适合：方块、标签、注释、箭头。
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `cell` `tag` `badge` `note`\\
        `label` `sub-label` `span-label`\\
        `wrap` `brace` `edge`
      ]
    ],

    region(fill: rgb("#E8F5E9"), width: 155pt)[
      #text(weight: "bold")[Layer 2 — 容器]
      #v(3pt)
      #text(size: 0.9em)[
        把多个元素组织成一个整体。\\
        适合：分组、包裹、连接、说明。
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `region` `target` `connector`\\
        `group` `stack` `divider`\\
        `detail` `entry-list`
      ]
    ],

    region(fill: rgb("#FFF3E0"), width: 155pt)[
      #text(weight: "bold")[Layer 3 — 组合]
      #v(3pt)
      #text(size: 0.9em)[
        直接生成常见图表结构。\\
        适合：带标题图块、位字段、图例、行布局。
      ]
      #v(4pt)
      #text(size: 0.82em)[
        `schema` `linked-schema`\\
        `grid-row` `lane` `section`\\
        `legend` `bit-row` `flex-row`\\
        `seq-lane`
      ]
    ],
  )
]

#v(8pt)

如果你只想快速开始，推荐顺序是：

#align(center)[
  #region(fill: rgb("#F5F5F5"), width: 100%)[
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[第 1 步], [先学 #doc-link("layer1-cell")[`cell`] —— 这是最基础的方块。],
      text(weight: "bold")[第 2 步], [再学 #doc-link("layer2-region")[`region`] —— 把多个方块包成一个结构。],
      text(weight: "bold")[第 3 步], [再学 #doc-link("layer3-schema")[`schema`] —— 给图加标题和说明。],
      text(weight: "bold")[第 4 步], [最后按场景进入 #doc-link("flows")[流程图]、#doc-link("states")[状态图]、#doc-link("tree")[树图] 或 #doc-link("seq")[时序图] 章节。],
    )
  ]
]

== 按你要画的内容选择入口 <api-overview-by-task>

=== 我想画内存布局、数据结构、字段块

这是 *blockcell* 最自然的使用场景。
推荐从以下组件开始：

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("layer1-cell", "cell") #api-ref("layer2-region", "region") #api-ref("layer3-schema", "schema")],
      text(weight: "bold")[常和这些一起用], [#api-ref("layer1-sub-label", "sub-label") #api-ref("layer1-tag", "tag") #api-ref("layer2-target", "target") #api-ref("layer2-connector", "connector") #api-ref("layer1-wrap", "wrap")],
      text(weight: "bold")[通常用来画], [字段布局、指针与目标区、枚举变体、容器内部结构],
    )
  ]
]

#section-label[最小组合]

#example-pair(
  ```typ
  #schema(title: raw("Vec<T>"))[
    #region[
      #cell[ptr]
      #cell[len]
      #cell[cap]
    ]
  ]
  ```,
  [
    #schema(title: raw("Vec<T>"))[
      #region[
        #cell[`ptr`]
        #cell[`len`]
        #cell[`cap`]
      ]
    ]
  ],
)

=== 我想画协议头、寄存器、位字段

推荐从 #api-ref("layer3-bit-row", "bit-row") 开始。
如果还需要标题、说明或多段组合，再配合 #api-ref("layer3-section", "section")、#api-ref("layer3-schema", "schema")、#api-ref("layer3-legend", "legend")。

#align(center)[
  #region(fill: rgb("#FFF3E0"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("layer3-bit-row", "bit-row")],
      text(weight: "bold")[常和这些一起用], [#api-ref("layer3-section", "section") #api-ref("layer3-legend", "legend") #api-ref("layer1-cell", "cell") #api-ref("layer2-region", "region")],
      text(weight: "bold")[通常用来画], [IPv4 / TCP 头、寄存器位图、固定宽度字段布局],
    )
  ]
]

#section-label[最小组合]

#wide-example(
  ```typ
  #bit-row(total: 16, width: 220pt, fields: (
    (bits: 4, label: [Ver], fill: palettes.network.meta),
    (bits: 4, label: [IHL], fill: palettes.network.meta),
    (bits: 8, label: [Flags], fill: palettes.network.flag),
  ))
  ```,
  [
    #bit-row(total: 16, width: 220pt, fields: (
      (bits: 4, label: [Ver], fill: palettes.network.meta),
      (bits: 4, label: [IHL], fill: palettes.network.meta),
      (bits: 8, label: [Flags], fill: palettes.network.flag),
    ))
  ],
)

=== 我想画流程图

如果你的流程是 *自顶向下、结构化分支*，请直接进入 #doc-link("flows")[“流程图”章节]。
这类图不需要手动摆坐标，按步骤写即可。

#align(center)[
  #region(fill: rgb("#FFECB3"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("flows-flow-col", "flow-col")],
      text(weight: "bold")[常和这些一起用], [#api-ref("flows-process", "process") #api-ref("flows-decision", "decision") #api-ref("flows-terminal", "terminal") #api-ref("flows-branch", "branch") #api-ref("flows-branch-merge", "branch-merge") #api-ref("flows-switch", "switch") #api-ref("flows-flow-loop", "flow-loop")],
      text(weight: "bold")[通常用来画], [业务流程、请求处理、判断分支、重试循环],
    )
  ]
]

#section-label[最小组合]

#wide-example(
  ```typ
  #flow-col(
    terminal[Start],
    process[Load config],
    decision[Valid?],
    terminal[Done],
  )
  ```,
  [
    #flow-col(
      terminal[Start],
      process[Load config],
      decision[Valid?],
      terminal[Done],
    )
  ],
)

#section-label[什么时候不适合]

如果你需要自由走线、跨区域连接、复杂二维拓扑，这一组 API 就不是最佳入口。

=== 我想画状态机

如果你要表达 *状态之间的转移*，请进入 #doc-link("states")[“状态转换图”章节]。
最常见的入口是 #api-ref("states-state-chain", "state-chain")。

#align(center)[
  #region(fill: rgb("#FCE4EC"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("states-state-chain", "state-chain") #api-ref("states-state", "state")],
      text(weight: "bold")[常和这些一起用], [#api-ref("states-loop", "loop") #api-ref("states-jump", "jump")],
      text(weight: "bold")[通常用来画], [生命周期、协议状态、资源状态流转、有限状态机],
    )
  ]
]

#section-label[最小组合]

#wide-example(
  ```typ
  #state-chain(
    state("idle", initial: true)[idle],
    state("running", edge-label: [start])[running],
    state("done", edge-label: [finish], accept: true)[done],
  )
  ```,
  [
    #state-chain(
      state("idle", initial: true)[idle],
      state("running", edge-label: [start])[running],
      state("done", edge-label: [finish], accept: true)[done],
    )
  ],
)

=== 我想画层级结构、目录树、组织树

如果你的图是 *父子层级关系*，请进入 #doc-link("tree")[“层级树图”章节]。
入口很简单：#api-ref("tree-tree", "tree") `(...)`。

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("tree-tree", "tree") #api-ref("tree-node", "node")],
      text(weight: "bold")[常和这些一起用], [#api-ref("layer1-cell", "cell") #api-ref("flows-process", "process") #api-ref("layer1-flow-node", "flow-node") 作为节点内容],
      text(weight: "bold")[通常用来画], [目录树、JSON 层级、BST、组织架构、分类结构],
    )
  ]
]

#section-label[最小组合]

#wide-example(
  ```typ
  #tree(
    node[root],
    tree(node[left], node[left.left], node[left.right]),
    tree(node[right], node[right.left], node[right.right]),
  )
  ```,
  [
    #tree(
      node[root],
      tree(node[left], node[left.left], node[left.right]),
      tree(node[right], node[right.left], node[right.right]),
    )
  ],
)

=== 我想画时序图、调用链、参与者交互

如果你的图关注的是 *谁调用谁、消息如何往返*，请进入 #doc-link("seq")[“时序图”章节]。
入口是 #api-ref("layer3-seq-lane", "seq-lane")。

#align(center)[
  #region(fill: rgb("#E0F2F1"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[先从这里看], [#api-ref("layer3-seq-lane", "seq-lane")],
      text(weight: "bold")[常和这些一起用], [#api-ref("seq-seq-call", "seq-call") #api-ref("seq-seq-ret", "seq-ret") #api-ref("seq-seq-note", "seq-note") #api-ref("seq-fragments", "seq-alt") #api-ref("seq-fragments", "seq-loop")],
      text(weight: "bold")[通常用来画], [服务调用链、协议握手、登录流程、系统交互],
    )
  ]
]

#section-label[最小组合]

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "server")[GET /users],
    seq-ret("server", "client")[200 OK],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET /users],
      seq-ret("server", "client")[200 OK],
    )
  ],
)

== 最常用组件速查 <api-overview-quick-picks>

如果你不想先看完整章节，可以先记住下面这些高频入口：

#align(center)[
  #region(width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 6pt,
      text(weight: "bold")[#api-ref("layer1-cell", "cell")], [单个方块。几乎所有结构图都从这里开始。],
      text(weight: "bold")[#api-ref("layer2-region", "region")], [把多个方块包成一个整体。],
      text(weight: "bold")[#api-ref("layer3-schema", "schema")], [给图加标题和说明。],
      text(weight: "bold")[#api-ref("layer3-linked-schema", "linked-schema")], [表达“字段区 + 指向目标区”的常见结构。],
      text(weight: "bold")[#api-ref("layer3-bit-row", "bit-row")], [画协议头和位字段。],
      text(weight: "bold")[#api-ref("flows-flow-col", "flow-col")], [画自顶向下流程图。],
      text(weight: "bold")[#api-ref("states-state-chain", "state-chain")], [画状态机。],
      text(weight: "bold")[#api-ref("tree-tree", "tree")], [画层级树。],
      text(weight: "bold")[#api-ref("layer3-seq-lane", "seq-lane")], [画时序图。],
    )
  ]
]

== 调色板怎么选 <api-overview-palettes>

颜色不需要一开始就自定义。
大多数情况下，先用内置调色板就够了。

#align(center)[
  #region(fill: rgb("#F3E5F5"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[#api-ref("palettes-status", "palettes.status")], [语义状态色：成功、警告、错误、信息、中性。],
      text(weight: "bold")[#api-ref("palettes-pastel", "palettes.pastel")], [通用柔和色，适合大多数结构图。],
      text(weight: "bold")[#api-ref("palettes-categorical", "palettes.categorical")], [多组分类颜色，适合图例和分组。],
      text(weight: "bold")[#api-ref("palettes-sequential", "palettes.sequential")], [同色深浅梯度，适合等级和强度。],
      text(weight: "bold")[域调色板], [#api-ref("palettes-domain", "palettes.rust") #api-ref("palettes-domain", "palettes.network") #api-ref("palettes-domain", "palettes.cache") 适合直接复用示例风格。],
    )
  ]
]

#section-label[最短示例]

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #cell(fill: palettes.pastel.blue)[Users]
  #cell(fill: palettes.categorical.at(1))[Worker]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #cell(fill: palettes.pastel.blue)[Users]
    #h(6pt)
    #cell(fill: palettes.categorical.at(1))[Worker]
  ],
)

== 推荐阅读顺序 <api-overview-reading-order>

如果你准备系统学习，建议按这个顺序阅读：

#align(center)[
  #region(fill: rgb("#F5F5F5"), width: 100%)[
    #grid(
      columns: (90pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[第 1 章], [#doc-link("intro")[简介]：了解这个库适合什么、不适合什么。],
      text(weight: "bold")[第 2 章], [本章：先按任务找到入口。],
      text(weight: "bold")[第 3 章], [#doc-link("patterns")[使用模式]：学习调色板、辅助函数和常见组合。],
      text(weight: "bold")[第 4 章], [#doc-link("examples")[完整示例]：先复制最接近你场景的例子。],
      text(weight: "bold")[第 5 章], [#doc-link("layer1")[Layer 1] / #doc-link("layer2")[Layer 2] / #doc-link("layer3")[Layer 3]：按需查完整参考。],
      text(weight: "bold")[第 6 章], [专题章节：#doc-link("flows")[流程图]、#doc-link("states")[状态图]、#doc-link("tree")[树图]、#doc-link("seq")[时序图]。],
    )
  ]
]

== 下一步看哪里 <api-overview-next>

- 想尽快画出第一个结构图：去看 #doc-link("patterns")[“使用模式”] 和 #doc-link("layer1")[“Layer 1 — 原子”]
- 想直接复制真实案例：去看 #doc-link("examples")[“完整示例”]
- 想画流程图：去看 #doc-link("flows")[“流程图”]
- 想画状态机：去看 #doc-link("states")[“状态转换图”]
- 想画树：去看 #doc-link("tree")[“层级树图”]
- 想画时序图：去看 #doc-link("seq")[“时序图”]
