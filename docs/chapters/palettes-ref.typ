#import "../../lib.typ": *
#import "../style.typ": *

= 调色板 <palettes>

`blockcell` 提供一组开箱即用的调色板，帮助你快速给图表建立稳定、清晰的视觉层次。

推荐用法很简单：

- 需要“成功 / 警告 / 错误”这类语义颜色时，用 `palettes.status`
- 需要一组柔和、通用的颜色时，用 `palettes.pastel`
- 需要给多个类别分配不同颜色时，用 `palettes.categorical`
- 需要表达强弱、等级、深浅时，用 `palettes.sequential`
- 需要直接复用示例里的领域配色时，用 `palettes.rust`、`palettes.network`、`palettes.cache`

== 先看怎么选 <palettes-choose>

#align(center)[
  #region(fill: rgb("#F8FAFC"), width: 100%)[
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 5pt,
      text(weight: "bold")[想表达什么], text(weight: "bold")[推荐调色板],
      [状态], [`palettes.status` —— 成功、警告、错误、信息、中性],
      [通用配色], [`palettes.pastel` —— 柔和、稳定、适合大多数结构图],
      [多个类别], [`palettes.categorical` —— 给不同组分配不同颜色],
      [强度 / 等级], [`palettes.sequential` —— 同色系由浅到深],
      [领域示例], [`palettes.rust` / `palettes.network` / `palettes.cache`],
    )
  ]
]

== `palettes.status` <palettes-status>

用于表达语义状态。最适合：

- 成功 / 失败
- 命中 / 未命中
- 正常 / 警告 / 错误
- 已完成 / 等待 / 跳过

如果组件支持 `status:` 参数，优先直接用 `status:`。
如果你想把同一组颜色用于 `cell`、`region` 等组件，也可以展开使用。

#section-label[Example]

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #badge(status: "warning")[WAIT]
  #badge(status: "danger")[ERROR]

  #cell(..palettes.status.info)[Info]
  ```
  ,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #badge(status: "warning")[WAIT]
    #h(6pt)
    #badge(status: "danger")[ERROR]
    #h(10pt)
    #cell(..palettes.status.info)[Info]
  ],
)

#section-label[Keys]

#align(center)[
  #badge(status: "success")[SUCCESS]
  #h(4pt)
  #badge(status: "warning")[WARNING]
  #h(4pt)
  #badge(status: "danger")[DANGER]
  #h(4pt)
  #badge(status: "info")[INFO]
  #h(4pt)
  #badge(status: "neutral")[NEUTRAL]
]

#grid(
  columns: (80pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold")[`success`], [成功、通过、命中、完成],
  text(weight: "bold")[`warning`], [警告、等待、降级、稍后处理],
  text(weight: "bold")[`danger`], [失败、错误、拒绝、未命中],
  text(weight: "bold")[`info`], [提示、说明、一般信息],
  text(weight: "bold")[`neutral`], [中性、跳过、未决、占位],
)

#section-label[When to use]

- 想让颜色直接表达语义，而不是只做装饰
- 想在不同图里保持一致的状态颜色
- 想减少手写 `fill` / `stroke`

#entry-title("palettes.pastel", kind: "Constant", anchor: "palettes-pastel")

一组通用的柔和颜色。适合大多数结构图、说明图和示意图。

如果你只是想“给不同块一个舒服、稳定的颜色”，通常从这里开始就够了。

#section-label[Example]

#example-pair(
  ```typ
  #let C = palettes.pastel

  #cell(fill: C.blue)[API]
  #cell(fill: C.green)[Worker]
  #cell(fill: C.orange)[Queue]
  ```
  ,
  [
    #let C = palettes.pastel
    #cell(fill: C.blue)[API]
    #h(4pt)
    #cell(fill: C.green)[Worker]
    #h(4pt)
    #cell(fill: C.orange)[Queue]
  ],
)

#section-label[Keys]

#align(center)[
  #let swatch(name) = cell(
    fill: palettes.pastel.at(name),
    width: 38pt,
    height: 24pt,
  )[
    #text(size: 0.72em)[#name]
  ]
  #swatch("red")
  #swatch("pink")
  #swatch("purple")
  #swatch("indigo")
  #swatch("blue")
  #swatch("cyan")
  #swatch("teal")
  #swatch("green")
  #swatch("lime")
  #swatch("yellow")
  #swatch("orange")
  #swatch("brown")
  #swatch("gray")
]

#section-label[When to use]

- 画内存布局、结构图、模块图、说明图
- 需要多种颜色，但不想让颜色过于刺眼
- 还没有自己的领域配色，想先快速出图

#entry-title("palettes.categorical", kind: "Constant", anchor: "palettes-categorical")

一组彼此容易区分的颜色，适合给多个类别、角色或分组分配颜色。

它是一个数组，通常用 `.at(i)` 取色。

#section-label[Example]

#example-pair(
  ```typ
  #for (i, label) in
    ([API], [DB], [Cache], [Queue]).enumerate() {
    cell(fill: palettes.categorical.at(i))[#label]
  }
  ```
  ,
  [
    #for (i, label) in ([API], [DB], [Cache], [Queue]).enumerate() {
      cell(fill: palettes.categorical.at(i))[#label]
    }
  ],
)

#section-label[Swatches]

#align(center)[
  #for (i, label) in (
    [A], [B], [C], [D], [E], [F], [G], [H],
  ).enumerate() {
    cell(fill: palettes.categorical.at(i), width: 34pt, height: 22pt)[
      #text(size: 0.8em)[#label]
    ]
  }
]

#section-label[When to use]

- 图例
- 多个服务 / 模块 / 角色
- 多个分支或类别并列展示
- 需要“每组一个不同颜色”

#section-label[Tip]

如果类别数量不多，`categorical` 往往比手工挑色更稳定。

#entry-title("palettes.sequential", kind: "Constant", anchor: "palettes-sequential")

同色系的深浅梯度，适合表达：

- 等级
- 强度
- 热度
- 优先级
- 数值由低到高

每组颜色都按“浅 → 深”排列。

#section-label[Example]

#example-pair(
  ```typ
  #for lvl in range(5) {
    cell(fill: palettes.sequential.blue.at(lvl))[L#lvl]
  }
  ```
  ,
  [
    #for lvl in range(5) {
      cell(fill: palettes.sequential.blue.at(lvl))[L#lvl]
    }
  ],
)

#section-label[Ramps]

#align(center)[
  #grid(
    columns: (auto, auto),
    column-gutter: 8pt,
    row-gutter: 4pt,
    align: (right + horizon, left + horizon),
    ..(for hue in ("blue", "green", "orange", "purple", "gray") {
      (
        text(size: 0.85em, weight: "bold")[#hue],
        {
          for lvl in range(5) {
            cell(
              fill: palettes.sequential.at(hue).at(lvl),
              width: 38pt,
              height: 22pt,
            )[
              #text(
                size: 0.78em,
                fill: if lvl < 2 { black } else { white },
                weight: "bold",
              )[L#lvl]
            ]
          }
        },
      )
    })
  )
]

#section-label[When to use]

- 协议字段的重要性分层
- 风险等级、优先级、热度
- 同一类对象的轻重区分
- 想表达“这是同一组，但程度不同”

#entry-title("palettes.rust / network / cache", kind: "Constant", anchor: "palettes-domain")

这三组是示例中使用的领域配色。
如果你的图和这些场景接近，可以直接复用；如果只是借鉴配色，也可以复制后自行调整。

#section-label[Overview]

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[`palettes.rust`],
  text(weight: "bold", size: 0.9em)[`palettes.network`],
  text(weight: "bold", size: 0.9em)[`palettes.cache`],
  text(size: 0.8em)[Rust 内存布局、指针、堆对象、枚举等],
  text(size: 0.8em)[协议头、网络分层、地址、标志位、校验等],
  text(size: 0.8em)[缓存层次、内存、MESI 状态、数据块等],
)

#section-label[Example]

#example-pair(
  ```typ
  #let R = palettes.rust
  #let N = palettes.network
  #let K = palettes.cache

  #cell(fill: R.ptr)[ptr]
  #cell(fill: N.flag)[Flags]
  #cell(fill: K.shared)[Shared]
  ```
  ,
  [
    #let R = palettes.rust
    #let N = palettes.network
    #let K = palettes.cache
    #cell(fill: R.ptr)[ptr]
    #h(4pt)
    #cell(fill: N.flag)[Flags]
    #h(4pt)
    #cell(fill: K.shared)[Shared]
  ],
)

#section-label[When to use]

- 你的图和官方示例场景接近
- 你想快速得到一套已经验证过的领域配色
- 你希望同类图在项目中保持一致风格

== 常见用法 <palettes-common-usage>

== 1. 直接给组件传 `fill`

#example-pair(
  ```typ
  #cell(fill: palettes.pastel.blue)[API]
  #region(fill: palettes.pastel.green)[...]
  ```
,
  [
    #cell(fill: palettes.pastel.blue)[API]
    #h(6pt)
    #region(fill: palettes.pastel.green)[...]
  ],
)

== 2. 用短别名减少重复

#example-pair(
  ```typ
  #let C = palettes.pastel

  #cell(fill: C.blue)[A]
  #cell(fill: C.green)[B]
  #cell(fill: C.orange)[C]
  ```
,
  [
    #let C = palettes.pastel

    #cell(fill: C.blue)[A]
    #h(4pt)
    #cell(fill: C.green)[B]
    #h(4pt)
    #cell(fill: C.orange)[C]
  ],
)

== 3. 用 `status:` 表达语义状态

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #terminal(status: "danger")[Exit]
  ```
,
  [
    #badge(status: "success")[OK]
    #h(8pt)
    #terminal(status: "danger")[Exit]
  ],
)

== 4. 展开状态色到其他组件

#example-pair(
  ```typ
  #cell(..palettes.status.warning)[Retry]
  #region(..palettes.status.info)[Pending]
  ```
,
  [
    #cell(..palettes.status.warning)[Retry]
    #h(8pt)
    #region(..palettes.status.info)[Pending]
  ],
)

== 5. 在现有调色板上补一个自定义颜色

#example-pair(
  ```typ
  #let C = (..palettes.pastel, accent: rgb("#FF6F00"))

  #cell(fill: C.accent)[Highlight]
  ```
,
  [
    #let C = (..palettes.pastel, accent: rgb("#FF6F00"))

    #cell(fill: C.accent)[Highlight]
  ],
)

== 建议 <palettes-tips>

- 优先保持同一张图里的颜色语义一致
- 不要为了“好看”给每个块都换一种颜色
- 如果颜色已经表达了状态，就不要再让颜色同时表达无关含义
- 不确定怎么选时，先用 `pastel`；需要明确语义时，再用 `status`

== 下一步 <palettes-next>

- 想看如何复用调色板和 `.with()`：继续看“使用模式”
- 想看完整场景示例：继续看“完整示例”
