#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Raw shapes via flow-node, plus the four semantic aliases.
#flow-node(shape: "rect")[rect]
#h(6pt)
#flow-node(shape: "diamond", width: 80pt)[diamond]
#h(6pt)
#flow-node(shape: "stadium")[stadium]
#h(6pt)
#flow-node(shape: "circle")[O]

#v(6pt)

#process[process]
#h(6pt)
#decision(width: 90pt)[decision?]
#h(6pt)
#terminal[start]
#h(6pt)
#junction[J]
