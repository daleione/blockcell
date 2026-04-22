#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Subtitle renders as a muted second line, centered.
// A single-line cell alongside lines up cleanly thanks to center+horizon.
#flex-row(
  (flex: 1, body: cell(
    fill: palettes.pastel.blue, width: 100%, inset: (x: 6pt, y: 6pt),
  )[Solo]),
  (flex: 1, body: cell(
    subtitle: [with kind],
    fill: palettes.pastel.green, width: 100%, inset: (x: 6pt, y: 6pt),
  )[Duo]),
  (flex: 1, body: cell(
    subtitle: [4 bytes],
    fill: palettes.pastel.yellow, width: 100%, inset: (x: 6pt, y: 6pt),
  )[Field]),
)
