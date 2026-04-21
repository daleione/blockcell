#import "../../lib.typ": *
#import "../style.typ": *

= 使用模式

本章讲的是"如何把 blockcell 用得更顺手"—— 调色板复用、`.with()` 建辅助
函数、图表水平排列这几个场景的典型写法。

== 使用调色板

首选：直接用内置 `palettes.xxx`。用 `#let C = ...` 给常用调色板起个短别名：

#example-pair(
  ```typ
  #let C = palettes.pastel
  #cell(fill: C.blue)[Inbox]
  #cell(fill: C.green)[Approved]
  ```,
  [
    #let C = palettes.pastel
    #cell(fill: C.blue)[Inbox]
    #h(4pt)
    #cell(fill: C.green)[Approved]
  ],
)

要在已有调色板上增/改几个键，用展开运算符：

```typ
#let C = (..palettes.pastel, accent: rgb("#FF6F00"))
#cell(fill: C.accent)[Highlight]
```

内置不够用时，定义自己的字典：

```typ
#let C = (
  header: rgb("#BBDEFB"), addr: rgb("#B2DFDB"),
  flag:   rgb("#E1BEE7"), data: rgb("#DCEDC8"),
)
```

== 用 `.with()` 创建辅助函数

避免重复传参。Typst 的 `.with()` 把参数柯里化到新的函数名下：

```typ
#let mc = cell.with(width: 28pt, height: 20pt, inset: 2pt)
#let tc(body, ..args) = cell(body, fill: C.any, ..args)
#let celled(body, fill: C.any) = wrap(
  stroke: 3pt + C.cell, cell(body, fill: fill),
)
#let ptr-field(l: [ptr]) = cell(fill: C.ptr)[#l#sub-label[2/4/8]]
```

`.with()` 适合锁定 *布局尺寸*（`mc`），自定义函数适合封装 *带语义的组合*
（`celled`、`ptr-field`）。两种模式都避免了各处重写同一串 cell 参数，
尺寸要改时只有一个地方动。

== 让图表水平排列

`schema` / `linked-schema` 的根节点是 *内联盒子*（Typst `box`）。将多个
`schema` 紧邻书写（不留空行），即可像内联文本一样水平排列：

```typ
#schema(title: [A])[...
]#schema(title: [B])[...    // ← 紧贴前一个 ]
]#schema(title: [C])[...
]
```

关键是 *闭合的 `]` 和下一个 `#schema` 之间不能有换行*。一旦出现空行，
Typst 当成段落分隔，图表就会换行。

若描述文字过宽导致图表被撑大，用 `width:` 约束：

```typ
#linked-schema(
  width: 160pt,
  desc: [较长的描述文字会在此宽度内自动换行],
  // ...其余参数
)
```

内部会把 `title` / `desc` 和图表主体一起限制在 160pt 宽内，避免单个 schema
独占一整行。
