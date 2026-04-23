#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Tree slots accept any content — atoms (cell, tag, flow-node, process)
// drop in directly, no wrapping needed. The root here is a `process`; the
// children mix `cell` (with custom fill), `tag` (dotted), and a nested
// `flow-node(shape: "stadium")`.
#align(center)[
  #tree(
    process[支付回调],
    cell(fill: palettes.status.info.fill)[业务处理],
    tag[副作用],
    flow-node(shape: "stadium", fill: palettes.pastel.red)[退款],
  )
]
