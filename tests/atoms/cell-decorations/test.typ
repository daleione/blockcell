#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// expandable, phantom, overlay decorations.
#cell(fill: palettes.pastel.red, expandable: true)[`T`]
#h(6pt)
#cell(fill: palettes.pastel.blue, phantom: true)[gone]
#h(6pt)
#cell(fill: palettes.pastel.green, overlay: [S])[03]
