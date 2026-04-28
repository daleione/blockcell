#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Note variants: over single, over span, multi-line, across, and side notes.
#seq-puml(
  width: 380pt,
  `
  participant Alice
  participant Bob
  participant Carol

  Alice -> Bob : hi
  note over Bob : single-line note
  Bob -> Carol : forward
  note over Bob, Carol : spans two participants
  Carol --> Bob : ok
  note over Alice
    multi-line note
    on Alice's lifeline
  end note
  Bob --> Alice : reply
  note across : banner across the whole diagram
  Alice -> Bob : last message
  note right : side note follows last message
`)
