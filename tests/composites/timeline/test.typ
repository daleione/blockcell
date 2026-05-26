#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Date mode: proportional widths from real date gaps, axis above, and
// below-placed labels on the two narrow segments.
#let gold  = rgb("#f7d774")
#let green = palettes.sequential.green
#timeline(
  width: 380pt, axis: "above",
  start: datetime(year: 2026, month: 5, day: 26),
  (to: datetime(year: 2027, month: 5,  day: 26), fill: gold,       label: [专家版]),
  (to: datetime(year: 2029, month: 10, day: 30), fill: green.at(1), label: [普通版]),
  (to: datetime(year: 2030, month: 10, day: 30), fill: green.at(2), label: [年卡], label-pos: "below"),
  (to: datetime(year: 2031, month: 10, day: 30), fill: green.at(3), label: [年卡], label-pos: "below"),
)

#v(10pt)

// Weight mode: palette-cycled fills, no axis, an explicit gap.
#timeline(width: 380pt, axis: none, gap: 4pt,
  (span: 2, label: [设计]),
  (span: 5, label: [开发]),
  (span: 1, label: [上线]),
)
