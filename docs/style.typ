// blockcell 手册样式辅助：统一 API 条目的展示组件。

// 内置类型标签的背景色。
#let _type-color(name) = (
  "none":       rgb("#F8D8CF"),
  "auto":       rgb("#F8D8CF"),
  "bool":       rgb("#FFE8B5"),
  "int":        rgb("#D4F0B9"),
  "float":      rgb("#D4F0B9"),
  "length":     rgb("#FFE8B5"),
  "ratio":      rgb("#FFE8B5"),
  "relative":   rgb("#FFDAD8"),
  "angle":      rgb("#FFE8B5"),
  "fraction":   rgb("#FFE8B5"),
  "str":        rgb("#C6EBBA"),
  "label":      rgb("#C6EBBA"),
  "content":    rgb("#A8E8D0"),
  "array":      rgb("#FFDAE3"),
  "dictionary": rgb("#FFDAE3"),
  "function":   rgb("#F8D8FF"),
  "color":      rgb("#E5D8F8"),
  "gradient":   rgb("#E5D8F8"),
  "stroke":     rgb("#E5D8F8"),
  "tiling":     rgb("#FBCFE8"),
  "alignment":  rgb("#FFE8B5"),
  "direction":  rgb("#FFE8B5"),
).at(name, default: rgb("#E6E6E6"))

#let type-pill(name) = box(
  fill: _type-color(name),
  inset: (x: 5pt, y: 0pt),
  outset: (y: 3pt),
  radius: 3pt,
  raw(name, lang: none),
)

// API 条目内的小节标题，不进入目录。
#let section-label(body) = block(above: 10pt, below: 6pt,
  text(size: 12pt, weight: "bold", body))

// 左右并排的代码 / 渲染示例，整体尽量不跨页。
#let example-pair(code, rendered) = block(
  breakable: false,
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    box(width: 100%, fill: rgb("#F6F7F9"), radius: 5pt, inset: 10pt, code),
    box(width: 100%, fill: rgb("#E9ECEF"), radius: 5pt, inset: 8pt,
      box(width: 100%, fill: white, radius: 3pt, inset: 10pt,
        align(horizon + left, rendered))),
  ),
)

// 上下排列的宽示例，适合较宽的图表内容。
#let wide-example(code, rendered) = block(
  breakable: false,
  {
    block(width: 100%, fill: rgb("#F6F7F9"), radius: 5pt, inset: 10pt,
      above: 8pt, below: 4pt, code)
    block(width: 100%, fill: rgb("#E9ECEF"), radius: 5pt, inset: 8pt,
      above: 0pt, below: 8pt,
      block(width: 100%, fill: white, radius: 3pt, inset: 12pt,
        align(center, rendered)))
  },
)

// 函数签名块；`params` 形如 `(name, (type, ...))`。
#let params-box(fn-name, ..params, returns: none) = block(
  breakable: false,
  width: 100%, fill: rgb("#F6F7F9"), radius: 5pt, inset: 12pt,
  {
    set text(font: ("DejaVu Sans Mono", "Menlo", "Consolas"), size: 9.5pt)
    text(fill: rgb("#4B5EAE"), weight: "bold")[#fn-name#text(fill: black)[(]]
    linebreak()
    for p in params.pos() {
      let pname = p.at(0)
      let ptypes = p.at(1)
      h(16pt)
      text(weight: "bold")[#pname:]
      h(5pt)
      for (i, t) in ptypes.enumerate() {
        if i > 0 { h(4pt) }
        type-pill(t)
      }
      [,]
      linebreak()
    }
    text(fill: black)[)]
    if returns != none {
      h(4pt); [-> ]; h(2pt); type-pill(returns)
    }
  },
)

// 单个参数的说明卡片。
#let param-detail(name, types, default: none, settable: false, body) = block(
  above: 12pt, below: 8pt,
  {
    text(size: 13pt, weight: "bold",
      font: ("DejaVu Sans Mono", "Menlo", "Consolas"))[#name]
    h(10pt)
    for (i, t) in types.enumerate() {
      if i > 0 {
        h(4pt); text(size: 9pt, fill: luma(100))[or]; h(4pt)
      }
      type-pill(t)
    }
    if settable {
      h(8pt)
      box(fill: rgb("#E8EFFF"), radius: 2pt, inset: (x: 4pt, y: 1pt),
        text(size: 8.5pt, weight: "bold", fill: rgb("#4B5EAE"))[Settable])
    }
    v(4pt)
    body
    if default != none {
      v(4pt)
      text(size: 9.5pt)[*Default:* #default]
    }
  }
)

// 非函数条目的标题样式；分页由 manual.typ 顶层控制。
#let entry-title(name, kind: "Function") = {
  [#metadata("bc-entry-title")<bc-entry-title>]
  block(above: 18pt, below: 8pt, {
    text(size: 22pt, weight: "bold",
      font: ("DejaVu Sans Mono", "Menlo", "Consolas"))[#name]
    h(12pt)
    text(size: 11pt, weight: "bold", fill: luma(110))[#kind]
  })
}
