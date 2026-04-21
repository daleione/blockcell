#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#align(center)[
  #flow-col(
    process[Receive request],
    branch([Signature valid?],
      no: terminal(status: "danger")[401 Reject],
    ),
    process(edge-label: [Yes])[Check rate limit],
    terminal[Handled],
  )
]
