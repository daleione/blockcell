#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// All four brace directions. The box wrappers keep vertical braces
// inline with adjacent content.

#grid(
  columns: (1fr, 1fr),
  row-gutter: 10pt,
  column-gutter: 18pt,
  align: center + horizon,

  // down (default): horizontal, label below
  brace(span: 140pt)[capacity],
  // up: horizontal, label above
  brace(direction: "up", span: 140pt)[header],

  // right: vertical, label on right
  box(height: 60pt, brace(direction: "right", span: 60pt)[payload]),
  // left: vertical, label on left
  box(height: 60pt, brace(direction: "left", span: 60pt)[prefix]),
)
