#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Covers every status + custom fill/stroke override.
#badge[DEFAULT]
#h(4pt)
#badge(status: "success")[OK]
#h(4pt)
#badge(status: "warning")[WAIT]
#h(4pt)
#badge(status: "danger")[ERROR]
#h(4pt)
#badge(status: "info")[INFO]
#h(4pt)
#badge(status: "neutral")[SKIP]
#h(4pt)
#badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
