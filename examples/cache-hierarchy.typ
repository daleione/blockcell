// ============================================================================
// Example 3: Computer Cache Hierarchy
// ============================================================================
// Visualizes the multi-level cache structure of modern CPUs:
// Registers → L1 → L2 → L3 → Main Memory → Disk.
// Shows cache line states (MESI), write policies, and false sharing.

#import "../lib.typ": *

#set page(width: 600pt, height: auto, margin: 20pt)
#set text(size: 10pt)

#let C = palettes.cache
#let mc = cell.with(width: 32pt, height: 22pt, inset: 3pt)
#let data-cell(v, c: C.data) = mc(fill: c)[#text(weight: "bold")[#v]]

= Cache Hierarchy

Modern CPUs use a multi-level cache hierarchy to bridge the speed gap
between the processor and main memory.

#v(4pt)

// --- Hierarchy Overview ---

#section[Memory Hierarchy (fast #sym.arrow small #sym.arrow.r slow #sym.arrow large)][
  #align(center)[
    #grid(
      columns: 1,
      row-gutter: 1pt,
      region(fill: C.reg.lighten(40%), width: 140pt)[
        #text(weight: "bold")[Registers]
        #v(1pt)
        #text(size: 0.75em)[~1 cycle #h(4pt) | #h(4pt) ~1 KB]
      ],
      connector(length: 5pt),
      region(fill: C.l1.lighten(40%), width: 210pt)[
        #text(weight: "bold")[L1 Cache (per core)]
        #v(1pt)
        #text(size: 0.75em)[~4 cycles #h(4pt) | #h(4pt) 32–64 KB]
        #v(1pt)
        #text(size: 0.7em, fill: luma(100))[Split: L1i (instructions) + L1d (data)]
      ],
      connector(length: 5pt),
      region(fill: C.l2.lighten(40%), width: 290pt)[
        #text(weight: "bold")[L2 Cache (per core)]
        #v(1pt)
        #text(size: 0.75em)[~12 cycles #h(4pt) | #h(4pt) 256 KB – 1 MB]
      ],
      connector(length: 5pt),
      region(fill: C.l3.lighten(40%), width: 380pt)[
        #text(weight: "bold")[L3 Cache (shared across cores)]
        #v(1pt)
        #text(size: 0.75em)[~40 cycles #h(4pt) | #h(4pt) 8–64 MB]
      ],
      connector(length: 5pt),
      region(fill: C.ram.lighten(40%), width: 460pt)[
        #text(weight: "bold")[Main Memory (DRAM)]
        #v(1pt)
        #text(size: 0.75em)[~100–300 cycles #h(4pt) | #h(4pt) 8–128 GB]
      ],
      connector(length: 5pt),
      region(fill: C.disk.lighten(40%), width: 520pt)[
        #text(weight: "bold")[Storage (SSD / HDD)]
        #v(1pt)
        #text(size: 0.75em)[~10K–10M cycles #h(4pt) | #h(4pt) 256 GB – 4 TB]
      ],
    )
  ]
]

// --- Cache Line & MESI ---

#section[Cache Lines & MESI Protocol][
  Data moves between levels in fixed-size *cache lines* (typically 64 bytes).
  The MESI protocol tracks each line's state across cores:

  #v(6pt)

  #legend(
    (label: [#strong[M]odified],  fill: C.modified),
    (label: [#strong[E]xclusive], fill: C.exclusive),
    (label: [#strong[S]hared],    fill: C.shared),
    (label: [#strong[I]nvalid],   fill: C.invalid),
  )

  #v(10pt)

  *1. Both CPUs read — lines become Shared*
  #v(4pt)

  #grid-row(label: [Memory])[
    #data-cell[`03`] #data-cell[`21`] #data-cell[`7F`] #data-cell[`A0`]
  ]
  #grid-row(label: [CPU 0 L1])[
    #mc(fill: C.shared, overlay: [S])[`03`]
    #mc(fill: C.shared, overlay: [S])[`21`]
    #mc(fill: C.shared, overlay: [S])[`7F`]
    #mc(fill: C.shared, overlay: [S])[`A0`]
  ]
  #grid-row(label: [CPU 1 L1])[
    #mc(fill: C.shared, overlay: [S])[`03`]
    #mc(fill: C.shared, overlay: [S])[`21`]
    #mc(fill: C.shared, overlay: [S])[`7F`]
    #mc(fill: C.shared, overlay: [S])[`A0`]
  ]

  #v(10pt)

  *2. CPU 0 writes `0xFF` — line Modified, CPU 1 invalidated*
  #v(4pt)

  #grid-row(label: [Memory])[
    #data-cell[`03`] #data-cell[`21`] #data-cell[`7F`] #data-cell[`A0`]
    #h(8pt) #text(fill: luma(140))[(stale)]
  ]
  #grid-row(label: [CPU 0 L1])[
    #mc(fill: C.modified, overlay: [M])[`03`]
    #mc(fill: rgb("#E65100"), overlay: [M])[#text(fill: white)[`FF`]]
    #mc(fill: C.modified, overlay: [M])[`7F`]
    #mc(fill: C.modified, overlay: [M])[`A0`]
  ]
  #grid-row(label: [CPU 1 L1])[
    #mc(fill: C.invalid, dash: "dashed", overlay: [I])[]
    #mc(fill: C.invalid, dash: "dashed", overlay: [I])[]
    #mc(fill: C.invalid, dash: "dashed", overlay: [I])[]
    #mc(fill: C.invalid, dash: "dashed", overlay: [I])[]
  ]

  #v(10pt)

  *3. CPU 1 reads — triggers write-back, both Shared again*
  #v(4pt)

  #grid-row(label: [Memory])[
    #data-cell[`03`] #data-cell(c: C.modified)[`FF`] #data-cell[`7F`] #data-cell[`A0`]
    #h(8pt) #text(fill: luma(140))[(updated)]
  ]
  #grid-row(label: [CPU 0 L1])[
    #mc(fill: C.shared, overlay: [S])[`03`]
    #mc(fill: C.shared, overlay: [S])[`FF`]
    #mc(fill: C.shared, overlay: [S])[`7F`]
    #mc(fill: C.shared, overlay: [S])[`A0`]
  ]
  #grid-row(label: [CPU 1 L1])[
    #mc(fill: C.shared, overlay: [S])[`03`]
    #mc(fill: C.shared, overlay: [S])[`FF`]
    #mc(fill: C.shared, overlay: [S])[`7F`]
    #mc(fill: C.shared, overlay: [S])[`A0`]
  ]
]

// --- Write Policies ---

#section[Write Policies][
  When the CPU writes `0xFF`, the cache must decide how to propagate the change.

  #v(10pt)

  #let ok = text(fill: rgb("#2E7D32"), weight: "bold")[#sym.checkmark]
  #let no = text(fill: rgb("#C62828"), weight: "bold")[#sym.times]

  #grid(
    columns: (100pt, 1fr, 1fr),
    row-gutter: 0pt,
    align: (right + horizon, center + horizon, center + horizon),

    // Header
    [],
    block(width: 100%, inset: (y: 6pt), fill: C.l1.lighten(60%),
      align(center, text(weight: "bold")[Write-Through])),
    block(width: 100%, inset: (y: 6pt), fill: C.ram.lighten(60%),
      align(center, text(weight: "bold")[Write-Back])),

    // L1 Cache state
    text(fill: luma(100))[L1 Cache],
    block(inset: (y: 6pt))[
      #mc(fill: C.modified, width: 36pt)[`FF`] #h(4pt) #ok
    ],
    block(inset: (y: 6pt))[
      #mc(fill: C.modified, overlay: [D], width: 36pt)[`FF`] #h(4pt) #ok
    ],

    // Memory state
    text(fill: luma(100))[Memory],
    block(inset: (y: 6pt))[
      #mc(fill: C.modified, width: 36pt)[`FF`] #h(4pt) #ok
    ],
    block(inset: (y: 6pt))[
      #mc(fill: C.invalid, dash: "dashed", width: 36pt)[`21`] #h(4pt) #no
    ],

    // Bus traffic
    text(fill: luma(100))[Bus traffic],
    block(inset: (y: 6pt))[Every write],
    block(inset: (y: 6pt))[Only on eviction],

    // Latency
    text(fill: luma(100))[Latency],
    block(inset: (y: 6pt))[#text(fill: rgb("#C62828"))[Higher]],
    block(inset: (y: 6pt))[#text(fill: rgb("#2E7D32"))[Lower]],

    // Complexity
    text(fill: luma(100))[Complexity],
    block(inset: (y: 6pt))[Simple],
    block(inset: (y: 6pt))[Dirty bit tracking],
  )
]

// --- False Sharing ---

#section[False Sharing][
  Two CPUs access *independent* variables (`x` and `y`) that happen to
  reside in the *same cache line*. Each write invalidates the other CPU's
  copy, causing severe performance loss.

  #v(8pt)

  #grid-row(label: [Cache Line])[
    #mc(fill: rgb("#EF9A9A"), width: 55pt)[`x` (CPU0)]
    #mc(fill: rgb("#90CAF9"), width: 55pt)[`y` (CPU1)]
    #mc(fill: luma(230))[...]
    #mc(fill: luma(230))[...]
    #h(8pt) #note[\u{2190} 64 bytes \u{2192}]
  ]

  #v(6pt)

  #grid-row(label: [CPU0 writes x])[
    #mc(fill: C.modified, overlay: [M], width: 55pt)[`x'`]
    #mc(fill: C.modified, overlay: [M], width: 55pt)[`y`]
    #h(8pt) #badge[Invalidates CPU1!]
  ]
  #grid-row(label: [CPU1 writes y])[
    #mc(fill: C.modified, overlay: [M], width: 55pt)[`x'`]
    #mc(fill: C.modified, overlay: [M], width: 55pt)[`y'`]
    #h(8pt) #badge[Invalidates CPU0!]
  ]

  #v(6pt)

  *Fix:* Pad variables to cache line boundaries
  (`#[repr(align(64))]` in Rust, `alignas(64)` in C++).
]
