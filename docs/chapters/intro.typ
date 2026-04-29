#import "../../lib.typ": *
#import "../style.typ": *

= 简介 <intro>

*blockcell* 是一个用于 Typst 的块状图表库。你可以用它快速画出结构清晰、风格统一的图，例如：

- 数据结构与内存布局
- 协议头与位字段
- 分层架构与模块关系
- 流程图与状态图
- 时序图与层级树

它的重点不是自由绘图，而是用一组可组合的组件，把常见的技术图示写成稳定、可复用的 Typst 代码。

== 适合什么场景 <intro-fit>

如果你希望图表满足下面这些特点，`blockcell` 会很合适：

- 以方块、容器、分组、连接为主
- 结构清楚，便于在文档中长期维护
- 希望多个图保持统一视觉风格
- 希望通过组合小组件，而不是手工摆坐标来出图

常见用法包括：

- 用 #doc-link("layer1-cell")[`cell`]、#doc-link("layer2-region")[`region`]、#doc-link("layer3-schema")[`schema`] 画内存布局和结构图
- 用 #doc-link("layer3-bit-row")[`bit-row`] 画协议头、寄存器和位字段
- 用 #doc-link("flows-flow-col")[`flow-col`] 画业务流程和处理流程
- 用 #doc-link("states-state-chain")[`state-chain`] 画状态流转
- 用 #doc-link("tree-tree")[`tree`] 画目录树、组织结构和层级关系
- 用 #doc-link("layer3-seq-lane")[`seq-lane`] 画参与者之间的交互过程

== 不适合什么场景 <intro-not-fit>

`blockcell` 更擅长结构化图示，不适合所有绘图任务。

如果你需要的是：

- 任意坐标摆放
- 复杂自由连线
- 大量跨区域路由
- 更偏“画布式”的二维拓扑

那么更适合使用专门的绘图库。
把 `blockcell` 理解为“结构化图示组件库”，而不是通用绘图引擎，会更容易选对工具。

== 安装 <intro-install>

如果你使用已发布的包，在文档中导入：

```typst
#import "@preview/blockcell:0.1.0": *
```

如果你在仓库内查看示例，示例文件通常使用相对路径导入本地源码。

#section-label[导入后的最小效果]

#example-pair(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #cell[Loaded]
  ```
,
  [
    #cell[Loaded]
  ],
)

== 第一个例子 <intro-first-example>

先从最小例子开始。下面这段代码可以直接生成一组最基础的块状元素：

#example-pair(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #cell[A]
  #cell(fill: palettes.pastel.blue)[B]
  #badge(status: "success")[OK]
  #tag[x]
  ```
,
  [
    #cell[A]
    #h(4pt)
    #cell(fill: palettes.pastel.blue)[B]
    #h(6pt)
    #badge(status: "success")[OK]
    #h(6pt)
    #tag[x]
  ],
)

这几个组件已经覆盖了最常见的起点：

- `cell`：最基础的方块
- `badge`：紧凑的状态标记
- `tag`：用于标签、判别字段等小块

== 一个更真实的例子 <intro-real-example>

当你需要表达“字段区 + 指向目标区”的结构时，可以从 `schema`、`region`、`target` 这组组合开始：

#wide-example(
  ```typst
  #import "@preview/blockcell:0.1.0": *

  #let C = palettes.rust

  #schema(title: raw("Vec<T>"))[
    #region[
      #cell(fill: C.ptr)[`ptr`#sub-label[2/4/8]]
      #cell(fill: C.sized)[`len`#sub-label[2/4/8]]
      #cell(fill: C.sized)[`cap`#sub-label[2/4/8]]
    ]
    #connector()
    #target(fill: C.heap, label: "(heap)", width: 130pt)[
      #cell(fill: C.any)[`T`]
      #cell(fill: C.any)[`T`]
      #note[… len]
    ]
  ]
  ```
,
  [
    #let C = palettes.rust

    #schema(title: raw("Vec<T>"))[
      #region[
        #cell(fill: C.ptr)[`ptr`#sub-label[2/4/8]]
        #cell(fill: C.sized)[`len`#sub-label[2/4/8]]
        #cell(fill: C.sized)[`cap`#sub-label[2/4/8]]
      ]
      #connector()
      #target(fill: C.heap, label: "(heap)", width: 130pt)[
        #cell(fill: C.any)[`T`]
        #cell(fill: C.any)[`T`]
        #note[… len]
      ]
    ]
  ],
)

这个例子展示了 `blockcell` 的典型用法：先用小组件表达局部，再把它们组合成完整图示。

== 推荐学习顺序 <intro-learning-path>

如果你是第一次使用，建议按下面的顺序阅读手册：

1. 先看 #doc-link("api-overview")[*API 概览*]，了解有哪些能力
2. 再看 #doc-link("patterns")[*使用模式*]，先学最常见的写法
3. 然后阅读：
   - #doc-link("layer1-cell")[`cell` 所在的基础章节]
   - #doc-link("layer2-region")[`region` 所在的容器章节]
   - #doc-link("layer3-schema")[`schema` 和 `linked-schema` 所在的组合章节]
4. 最后按场景进入专题章节：
   - #doc-link("flows")[流程图]
   - #doc-link("states")[状态转换图]
   - #doc-link("tree")[层级树图]
   - #doc-link("seq")[时序图]

这样会比从头逐个读完整 API 更容易上手。

== 如何选择入口 <intro-choose-entry>

如果你已经知道自己要画什么，可以直接按任务进入：

- 画内存布局、结构图：先看 #doc-link("layer1-cell")[`cell`]、#doc-link("layer2-region")[`region`]、#doc-link("layer3-schema")[`schema`]
- 画协议头、寄存器、位字段：先看 #doc-link("layer3-bit-row")[`bit-row`]
- 画流程图：先看 #doc-link("flows")[“流程图”章节]
- 画状态机：先看 #doc-link("states")[“状态转换图”章节]
- 画层级结构：先看 #doc-link("tree")[“层级树图”章节]
- 画服务交互、调用链：先看 #doc-link("seq")[“时序图”章节]

== 文档如何使用 <intro-how-to-use>

这份手册分成两部分：

- 前半部分帮助你快速上手、按任务选组件
- 后半部分提供完整参考，方便查参数和示例

如果你只是想尽快开始，先看：

- #doc-link("intro")[简介]
- #doc-link("api-overview")[API 概览]
- #doc-link("patterns")[使用模式]
- #doc-link("examples")[完整示例]

如果你已经在写图，想查某个组件的参数和用法，再进入对应参考章节即可。

== 核心亮点 <intro-highlights>

BlockCell 不是要把 Typst 变成自由画布，而是为技术文档中常见的结构图，提供一套稳定、可组合、可复用的组件。

- *结构化表达*：无需手摆坐标，按“字段、容器、分组、连接、流程”描述图表，代码与结构一一对应。
- *清晰组合层次*：从 #doc-link("layer1-cell")[`cell`]、#doc-link("layer2-region")[`region`] 基础组件，逐步组合成 #doc-link("layer3-schema")[`schema`]、#doc-link("layer3-bit-row")[`bit-row`]、#doc-link("layer3-seq-lane")[`seq-lane`] 等复杂图形。
- *面向文档维护*：同类型图复用写法、颜色与辅助函数，修改字段、增删节点、调整样式无需重绘。
- *适配技术场景*：直接支持内存布局、协议头、流程图、状态图、时序图、层级树等常见需求，而非零散图元。
- *风格统一*：内置调色板、分层 API 与组合模式，保障文档中多张图视觉一致。
