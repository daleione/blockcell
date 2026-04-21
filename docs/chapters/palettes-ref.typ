#import "../../lib.typ": *
#import "../style.typ": *

== 调色板

包通过 `palettes` 命名空间提供一组按 *视觉角色* 分类的内置调色板，开箱即用。
无需手写 RGB 字典。

#entry-title("palettes.status", kind: "Constant")

五个语义状态的配色字典。每个状态都是一个 `(fill, stroke)` 对，可用 `..`
展开直接传给 `cell` / `region` / `badge` 等接受这两个参数的函数；`badge`
还提供更短的 `status` 入口。

#section-label[Example]

#example-pair(
  ```typ
  #badge(status: "success")[OK]
  #cell(..palettes.status.danger)[Error]
  ```,
  [
    #badge(status: "success")[OK]
    #h(6pt)
    #cell(..palettes.status.danger)[Error]
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
  text(weight: "bold")[`success`],  [成功 / 通过 / 命中],
  text(weight: "bold")[`warning`],  [警告 / 降级 / 稍后],
  text(weight: "bold")[`danger`],   [失败 / 错误 / miss],
  text(weight: "bold")[`info`],     [提示 / 一般信息],
  text(weight: "bold")[`neutral`],  [中性 / 跳过 / 未决],
)

#section-label[More]

深色 stroke 可单独取用作文字颜色：

```typ
#text(fill: palettes.status.info.stroke)[note]
```

#entry-title("palettes.pastel", kind: "Constant")

通用柔和色字典，13 个命名键。需要"一个好看的蓝"时直接点名，不用自己调色。

#section-label[Example]

#example-pair(
  ```typ
  #cell(fill: palettes.pastel.blue)[Inbox]
  #cell(fill: palettes.pastel.green)[Done]
  ```,
  [
    #cell(fill: palettes.pastel.blue)[Inbox]
    #h(4pt)
    #cell(fill: palettes.pastel.green)[Done]
  ],
)

#section-label[Keys]

#align(center)[
  #let swatch(name) = cell(
    fill: palettes.pastel.at(name), width: 38pt, height: 24pt)[
    #text(size: 0.72em)[#name]
  ]
  #swatch("red")    #swatch("pink")  #swatch("purple") #swatch("indigo")
  #swatch("blue")   #swatch("cyan")  #swatch("teal")   #swatch("green")
  #swatch("lime")   #swatch("yellow") #swatch("orange") #swatch("brown")
  #swatch("gray")
]

#entry-title("palettes.categorical", kind: "Constant")

8 种彼此可区分的颜色组成的 *数组*。按索引 `.at(i)` 取色 —— 适合图例、N 分组、
数据系列这类"给我下一个不同的颜色"场景。

#section-label[Example]

#example-pair(
  ```typ
  #for (i, label) in
    ([Alpha], [Beta], [Gamma]).enumerate() {
    cell(fill: palettes.categorical.at(i))[
      #label
    ]
  }
  ```,
  [
    #for (i, label) in ([Alpha], [Beta], [Gamma]).enumerate() {
      cell(fill: palettes.categorical.at(i))[#label]
    }
  ],
)

#section-label[Swatches]

#align(center)[
  #for (i, label) in (
    [Design], [Engineering], [Marketing], [Sales],
    [Support], [Finance], [Legal], [Ops],
  ).enumerate() {
    cell(fill: palettes.categorical.at(i), width: 52pt, height: 22pt)[
      #text(size: 0.8em)[#label]
    ]
  }
]

#entry-title("palettes.sequential", kind: "Constant")

5 组单色梯度字典（`blue` / `green` / `orange` / `purple` / `gray`），每组 5
阶（浅 → 深）。适合等级、强度、热力图式编码。

#section-label[Example]

#example-pair(
  ```typ
  #for lvl in range(5) {
    cell(fill: palettes.sequential
      .blue.at(lvl))[L#lvl]
  }
  ```,
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
            cell(fill: palettes.sequential.at(hue).at(lvl),
                 width: 38pt, height: 22pt)[
              #text(size: 0.78em,
                fill: if lvl < 2 { black } else { white },
                weight: "bold")[L#lvl]
            ]
          }
        },
      )
    })
  )
]

#entry-title("palettes.rust / network / cache", kind: "Constant")

官方示例文档所用的域调色板。直接用、复制改键、或完全忽略皆可。

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[`palettes.rust`],
  text(weight: "bold", size: 0.9em)[`palettes.network`],
  text(weight: "bold", size: 0.9em)[`palettes.cache`],
  text(size: 0.8em)[Rust 内存布局\
    （any / ptr / sized / heap ...）],
  text(size: 0.8em)[TCP/IP 协议头\
    （link / addr / flag / meta ...）],
  text(size: 0.8em)[CPU 缓存 + MESI\
    （l1 / l2 / l3 / ram / modified ...）],
)
