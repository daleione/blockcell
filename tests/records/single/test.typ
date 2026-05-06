#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Standalone record block — exercises every cell visual: bold key column,
// internal separators, and special-marker values.
#align(center)[
  #record((
    (key: [name],   value: ["Alice"]),
    (key: [active], value: [☑ true]),
    (key: [age],    value: [30]),
    (key: [parent], value: [␀]),
  ))
]
