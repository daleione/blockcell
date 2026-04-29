#import "../lib.typ": *

#set page(
  width: 600pt,
  margin: (x: 36pt, y: 30pt),
  numbering: "1",
  footer: context align(center,
    text(size: 9pt, fill: luma(140))[
      #counter(page).display("1") /
      #context counter(page).final().at(0)
    ]
  ),
)

#set text(size: 10pt, lang: "zh", font: ("LXGW WenKai"))
#set par(leading: 0.8em, justify: true)

#show heading.where(level: 1): it => {
  block(below: 18pt, text(size: 22pt, weight: "bold", it.body))
}

#show heading.where(level: 2): it => {
  v(12pt)
  block(below: 8pt, text(size: 13pt, fill: rgb("#1565C0"), it.body))
}

#show heading.where(level: 3): it => block(
  breakable: false,
  above: 18pt,
  below: 8pt,
  {
    text(
      size: 22pt,
      weight: "bold",
      font: ("DejaVu Sans Mono", "Menlo", "Consolas"),
      it.body,
    )
    h(12pt)
    text(size: 11pt, weight: "bold", fill: luma(110))[Function]
  },
)

#show raw.where(block: true): set text(size: 8.5pt)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: luma(246),
  radius: 3pt,
  inset: 8pt,
  it,
)

// 用户优先的阅读顺序：先知道是什么、怎么开始、怎么选，再进入完整参考。
#include "chapters/cover.typ"
#pagebreak(weak: true)

#include "chapters/intro.typ"
#pagebreak(weak: true)

#include "chapters/api-overview.typ"
#pagebreak(weak: true)

#include "chapters/patterns.typ"
#pagebreak(weak: true)

#include "chapters/examples.typ"
#pagebreak(weak: true)

// 完整参考从基础到专题展开。
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

#include "chapters/tree.typ"
#pagebreak(weak: true)

#include "chapters/seq.typ"
