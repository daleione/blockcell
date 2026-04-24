// Scaling regression: the same composition renders at two text sizes.
// Arrow heads, cell insets, state circles, and all gaps should grow
// proportionally to text.size — at 14pt everything is 1.4x the 10pt
// footprint, visually coherent, no fixed pt bleeding through.

#import "/lib.typ": *

#set page(width: 520pt, height: auto, margin: 12pt)

#set text(size: 10pt)
10pt base:
#cell[A] #edge(label: [step]) #cell[B]

#v(4pt)
#state-chain(
  state("s1", initial: true)[S1],
  state("s2")[S2],
  state("s3", accept: true)[S3],
)

#v(8pt)

#set text(size: 14pt)
14pt base:
#cell[A] #edge(label: [step]) #cell[B]

#v(4pt)
#state-chain(
  state("s1", initial: true)[S1],
  state("s2")[S2],
  state("s3", accept: true)[S3],
)
