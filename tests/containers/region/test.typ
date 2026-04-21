#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Plain region.
#region[
  #cell(fill: palettes.pastel.blue)[`ptr`]
  #cell(fill: palettes.pastel.cyan)[`len`]
  #cell(fill: palettes.pastel.cyan)[`cap`]
]

#v(6pt)

// Danger border.
#region(danger: true)[
  #cell(fill: palettes.pastel.red)[`unchecked`]
]

#v(6pt)

// Faded (zero-size / absent) + bottom-right label.
#region(faded: true, label: "(missing)")[
  #cell(fill: palettes.pastel.gray)[`?`]
]
