#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Exercise default (show-bits: true) and suppressed bit labels.
#bit-row(total: 32, width: 360pt, fields: (
  (bits: 4,  label: [Ver],          fill: yellow),
  (bits: 4,  label: [IHL],          fill: yellow),
  (bits: 8,  label: [DSCP],         fill: purple),
  (bits: 16, label: [Total Length], fill: aqua),
))

#v(6pt)

#bit-row(total: 32, width: 360pt, show-bits: false, fields: (
  (bits: 16, label: [Src Port],  fill: palettes.pastel.blue),
  (bits: 16, label: [Dst Port],  fill: palettes.pastel.blue),
))
