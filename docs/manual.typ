// blockcell 使用手册入口：统一页面样式与章节编排。


#import "../lib.typ": *

#set page(width: 600pt, margin: (x: 36pt, y: 30pt),
  numbering: "1", footer: context align(center,
    text(size: 9pt, fill: luma(140))[
      #counter(page).display("1") /
      #context counter(page).final().at(0)
    ]))


#set text(size: 10pt, lang: "zh", font: ("LXGW WenKai"))
#set par(leading: 0.8em, justify: true)
#show heading.where(level: 1): it => {
  block(below: 18pt, text(size: 22pt, weight: "bold", it.body))
}
#show heading.where(level: 2): it => {
  v(12pt)
  block(below: 8pt, text(size: 13pt, fill: rgb("#1565C0"), it.body))
}
// 三级标题用于 API 条目标题，并尽量与后续内容保持在一起。
#show heading.where(level: 3): it => block(
  breakable: false,
  above: 18pt,
  below: 8pt,
  {
    text(size: 22pt, weight: "bold",
      font: ("DejaVu Sans Mono", "Menlo", "Consolas"), it.body)
    h(12pt)
    text(size: 11pt, weight: "bold", fill: luma(110))[Function]
  },
)
#show raw.where(block: true): set text(size: 8.5pt)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(246), radius: 3pt, inset: 8pt, it,
)

// 每个 chapter 从新页开始，chapter 内部允许自然分页。
#include "chapters/cover.typ"
#pagebreak(weak: true)
#include "chapters/intro.typ"
#pagebreak(weak: true)
#include "chapters/api-overview.typ"
#pagebreak(weak: true)
#include "chapters/layer1-atoms.typ"
#pagebreak(weak: true)
#include "chapters/layer2-containers.typ"
#pagebreak(weak: true)
#include "chapters/layer3-composites.typ"
#pagebreak(weak: true)
#include "chapters/palettes-ref.typ"
#pagebreak(weak: true)
#include "chapters/flows.typ"
#pagebreak(weak: true)
#include "chapters/states.typ"
#pagebreak(weak: true)
#include "chapters/patterns.typ"
#pagebreak(weak: true)
#include "chapters/examples.typ"
