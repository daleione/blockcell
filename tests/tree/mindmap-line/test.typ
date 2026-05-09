#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// `edge-style: "line"` on `mindmap` exercises the diagonal-route path
// for the central-root → branch connectors. Each branch's own connectors
// are governed by the inner `tree(...)`, so we set the same style on those
// to keep the whole diagram consistent.
#align(center)[
  #mindmap(
    node[Brain],
    edge-style: "line",
    lefts: (
      tree(direction: "left", edge-style: "line", node[Memory],
        node[Short],
        node[Long],
      ),
    ),
    rights: (
      tree(direction: "right", edge-style: "line", node[Senses],
        node[Sight],
        node[Hearing],
      ),
    ),
  )
]
