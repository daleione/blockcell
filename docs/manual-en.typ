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

#set text(size: 10pt, lang: "en")
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

// Reading order favors the user: what it is, how to start, how to choose,
// then the full reference.
#include "chapters-en/cover.typ"
#pagebreak(weak: true)

#include "chapters-en/intro.typ"
#pagebreak(weak: true)

#include "chapters-en/api-overview.typ"
#pagebreak(weak: true)

#include "chapters-en/patterns.typ"
#pagebreak(weak: true)

#include "chapters-en/examples.typ"
#pagebreak(weak: true)

// Full reference unfolds from foundations to topical chapters.
#include "chapters-en/layer1-atoms.typ"
#pagebreak(weak: true)

#include "chapters-en/layer2-containers.typ"
#pagebreak(weak: true)

#include "chapters-en/layer3-composites.typ"
#pagebreak(weak: true)

#include "chapters-en/palettes-ref.typ"
#pagebreak(weak: true)

#include "chapters-en/flows.typ"
#pagebreak(weak: true)

#include "chapters-en/states.typ"
#pagebreak(weak: true)

#include "chapters-en/tree.typ"
#pagebreak(weak: true)

#include "chapters-en/seq.typ"
