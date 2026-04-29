#import "../../lib.typ": *
#import "../style.typ": *

= 示例与场景指南 <examples>

这一章不再按组件罗列，而是按“你想画什么”来组织。
如果你是第一次使用 *blockcell*，建议先从最接近自己需求的场景开始，先跑通一个完整例子，再回到前面的参考章节查细节。

== 如何使用这些示例 <examples-how-to-use>

仓库中的示例文件使用本地导入：

```typst
#import "../lib.typ": *
```

如果你是在自己的文档中使用已发布的包，请改为：

```typst
#import "@preview/blockcell:0.1.0": *
```

编译任意示例：

```bash
typst compile --root . examples/http-handler-flow.typ
```

把文件名替换成你要查看的示例即可。

== 如果你是第一次使用 <examples-first-time>

推荐按下面的顺序阅读：

1. `rust-cells.typ`
   先理解 #api-ref("layer1-cell", "cell")、#api-ref("layer2-region", "region")、#api-ref("layer3-schema", "schema") 这些最基础的结构组件。
2. `network-layers.typ`
   再看 #api-ref("layer3-bit-row", "bit-row") 这类固定宽度布局。
3. `http-handler-flow.typ`
   需要流程图时，从这里开始。
4. `file-io-states.typ`
   需要状态机时，从这里开始。
5. `cache-hierarchy.typ`
   需要多行对齐、图例和结构化说明时，从这里开始。

== 按场景选择示例 <examples-by-scenario>

#grid(
  columns: (120pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[内存布局 / 数据结构],
  [看 `rust-cells.typ`],
  text(weight: "bold")[协议头 / 位字段],
  [看 `network-layers.typ`],
  text(weight: "bold")[业务流程 / 决策分支],
  [看 `http-handler-flow.typ`],
  text(weight: "bold")[状态流转],
  [看 `file-io-states.typ`],
  text(weight: "bold")[层级结构 / 多行对齐],
  [看 `cache-hierarchy.typ`],
)

== 场景 1：内存布局与结构图 <examples-structural>

=== `rust-cells.typ`

*适合你在画：*

- 指针 + 目标对象
- 栈上字段与堆上内容
- 枚举或 tagged layout
- Rust 所有权、内部可变性、容器结构

*你会看到：*

- `cell`
- `tag`
- `region`
- `target`
- `connector`
- `schema`
- `linked-schema`
- `wrap`
- `divider`
- `palettes.rust`

*建议先复制的模式：*

- 一个 `schema` 里放一个 `region`
- 用 `connector` + `target` 表示“指向的存储区”
- 用 `wrap` 给某个字段加额外边框强调
- 用 `divider` 表示互斥布局

*为什么先看它：*

这是最能体现 *blockcell* 基本思路的示例：
先用小组件搭结构，再把结构组合成完整图。

== 场景 2：协议头与位字段 <examples-bitfields>

=== `network-layers.typ`

*适合你在画：*

- IPv4 / TCP / UDP 头部
- 固定宽度字段布局
- 分层协议栈
- 寄存器或报文格式图

*你会看到：*

- #api-ref("layer3-bit-row", "bit-row")
- #api-ref("layer3-schema", "schema")
- #api-ref("layer3-section", "section")
- #api-ref("layer2-region", "region")
- #api-ref("layer1-cell", "cell")
- #api-ref("layer3-legend", "legend")
- #api-ref("palettes-domain", "palettes.network")

*建议先复制的模式：*

- 用多行 #api-ref("layer3-bit-row", "bit-row") 组成完整头部
- 用统一 `width:` 保持每行对齐
- 用 #api-ref("layer3-legend", "legend") 解释颜色含义
- 用 #api-ref("layer3-section", "section") 把相关内容包成一个完整卡片

*什么时候优先看这个示例：*

当你的图核心是“字段宽度”和“按位分段”，而不是自由连线或复杂容器时。

== 场景 3：流程图与业务分支 <examples-flows>

=== `http-handler-flow.typ`

*适合你在画：*

- 请求处理流程
- 后端业务分支
- 重试 / 循环 / 分发逻辑
- 运维或审批流程

*你会看到：*

- `flow-col`
- `branch`
- `branch-merge`
- `switch`
- `case`
- `flow-loop`
- `process`
- `terminal`
- `junction`
- `legend`
- `status:` 语义状态色

*建议先复制的模式：*

- 用 `flow-col` 搭主干
- 用 `branch` 表示“侧出后不回主线”的分支
- 用 `branch-merge` 表示“分支后重新汇合”
- 用 `switch` 表示多路分发
- 用 `flow-loop` 表示重试或轮询

*什么时候优先看这个示例：*

当你想表达“步骤之间的顺序和判断”，而不是对象结构或时间交互时。

== 场景 4：状态机与生命周期 <examples-states>

=== `file-io-states.typ`

*适合你在画：*

- 资源生命周期
- 协议状态
- 文件 / 连接 / 任务状态流转
- 紧凑的有限状态机

*你会看到：*

- `state-chain`
- `state`
- `loop`
- `jump`

*建议先复制的模式：*

- 先用线性模式画主状态链
- 用 `loop` 表示自环
- 用 `jump` 表示跨状态跳转
- 用 `initial` / `accept` 标出起点和终点

*什么时候优先看这个示例：*

当你的重点是“状态之间如何转移”，而不是“谁调用了谁”。

== 场景 5：层级结构与多行对齐 <examples-hierarchy>

=== `cache-hierarchy.typ`

*适合你在画：*

- 缓存层次
- 分层架构
- 多行并列结构
- 需要图例说明的结构图

*你会看到：*

- `section`
- `grid-row`
- `region`
- `connector`
- `legend`
- `cell`
- `palettes.cache`

*建议先复制的模式：*

- 用 `grid-row` 做多行对齐
- 用统一的 `label-width:` 保持标签列整齐
- 用 `legend` 解释状态或颜色
- 用 `section` 把整组内容包起来

*什么时候优先看这个示例：*

当你需要“多行整齐排列”的结构图，而不是单行字段图或流程图。

== 从示例回到手册 <examples-back-to-manual>

当你已经找到最接近自己需求的示例后，建议再回到对应章节查参考：

#grid(
  columns: (150pt, 1fr),
  row-gutter: 6pt,
  text(weight: "bold")[结构图 / 内存布局],
  [回看 #doc-link("layer1")[“Layer 1 — 原子”]、#doc-link("layer2")[“Layer 2 — 容器”]、#doc-link("layer3")[“Layer 3 — 组合”]],
  text(weight: "bold")[协议头 / 位字段],
  [回看 #doc-link("layer3-bit-row")[`bit-row`]、#doc-link("layer3-legend")[`legend`]、#doc-link("palettes")[调色板章节]],
  text(weight: "bold")[流程图],
  [回看 #doc-link("flows")[“流程图”章节]],
  text(weight: "bold")[状态机],
  [回看 #doc-link("states")[“状态转换图”章节]],
  text(weight: "bold")[颜色选择],
  [回看 #doc-link("palettes")[“调色板”章节]],
)

== 选择示例的一个简单原则 <examples-how-to-choose>

如果你不确定从哪里开始，可以用这个规则：

- 先看 *最像你目标图形* 的示例
- 先复制 *整体结构*，再替换文字和颜色
- 只有在需要时，再回到 API 参考查参数细节

这样通常比从头阅读全部 API 更快。
