#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Horizontal edges between sibling cells — solid/dashed, labeled, no head.
#cell[Controller] #edge(label: [HTTP]) #cell[Business]

#v(4pt)

#cell[Business] #edge(label: [SQL], style: "dashed") #cell[MySQL]

#v(4pt)

#cell[A] #edge(head: "none", length: 30pt) #cell[B]
