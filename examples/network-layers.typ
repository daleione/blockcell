// ============================================================================
// Example 1: Network 4-Layer Protocol Stack (TCP/IP)
// ============================================================================
// Visualizes the TCP/IP 4-layer model: Link → Internet → Transport → Application.
// Shows protocol headers, encapsulation, and data flow.

#import "../lib.typ": *

#set page(width: 560pt, height: auto, margin: 20pt)
#set text(size: 9pt)

// ---------------------------------------------------------------------------
// User-defined palette for networking domain
// ---------------------------------------------------------------------------

#let C = (
  link: rgb("#BBDEFB"),       // blue 100 — link layer
  internet: rgb("#C8E6C9"),   // green 100 — internet layer
  transport: rgb("#FFE0B2"),  // orange 100 — transport layer
  app: rgb("#F8BBD0"),        // pink 100 — application layer
  data: rgb("#DCEDC8"),       // lime 100 — payload data
  addr: rgb("#B2DFDB"),       // teal 100 — addresses
  flag: rgb("#E1BEE7"),       // purple 100 — flags/control
  meta: rgb("#FFF9C4"),       // yellow 100 — metadata
  checksum: rgb("#D1C4E9"),   // deep purple 100 — checksums
  reserved: luma(230),
)

#let sub = sub-label

// Row width for consistent field alignment (simulating 32-bit word rows)
#let row-w = 440pt

// =========================================================================

= TCP/IP 4-Layer Protocol Stack

#v(4pt)

// --- Layer 4: Application Layer ---

#section[Layer 4 — Application][
  #schema(title: [*HTTP Request*], desc: [Variable-length text header + body.])[
    #region(fill: C.app, width: row-w)[
      #cell(fill: C.app.darken(15%), width: 55pt)[Method]
      #cell(fill: C.app.darken(15%), width: 180pt, expandable: true)[URI]
      #cell(fill: C.flag, width: 55pt)[Version]
    ]
    #region(fill: C.app.lighten(20%), width: row-w)[
      #cell(fill: C.meta, expandable: true)[Headers]
      #h(4pt)
      #cell(fill: C.reserved, width: 12pt, dash: "dashed")[\u{2190}]
      #note[ CRLF]
    ]
    #region(fill: C.data.lighten(20%), width: row-w)[
      #cell(fill: C.data, expandable: true)[Body]
    ]
  ]

  #v(4pt)

  #schema(title: [*DNS Query*], desc: [Fixed 12B header + variable sections.])[
    #region(fill: C.app)[
      #cell(fill: C.meta, width: 50pt)[ID#sub[2B]]
      #cell(fill: C.flag, width: 50pt)[Flags#sub[2B]]
      #cell(fill: C.meta, width: 55pt)[QDCnt]
      #cell(fill: C.meta, width: 55pt)[ANCnt]
    ]
    #region(fill: C.app.lighten(20%))[
      #cell(fill: C.data, expandable: true)[Questions]
      #cell(fill: C.data.darken(10%), expandable: true)[Answers]
    ]
  ]
]

// --- Layer 3: Transport Layer ---

#section[Layer 3 — Transport][
  #schema(title: [*TCP Segment*], desc: [Reliable, ordered, connection-oriented.])[
    #region(fill: C.transport, width: row-w)[
      #cell(fill: C.addr, width: 80pt)[Src Port#sub[2B]]
      #cell(fill: C.addr, width: 80pt)[Dst Port#sub[2B]]
      #cell(fill: C.meta, width: 105pt)[Seq Number#sub[4B]]
      #cell(fill: C.meta, width: 105pt)[Ack Number#sub[4B]]
    ]
    #region(fill: C.transport.lighten(15%), width: row-w)[
      #cell(fill: C.meta, width: 35pt)[Off]
      #cell(fill: C.reserved, width: 30pt, dash: "dashed")[Rsv]
      #cell(fill: C.flag, width: 110pt)[Flags#sub[SYN ACK FIN RST]]
      #cell(fill: C.meta, width: 80pt)[Window#sub[2B]]
    ]
    #region(fill: C.transport.lighten(15%), width: row-w)[
      #cell(fill: C.checksum, width: 95pt)[Checksum#sub[2B]]
      #cell(fill: C.meta, width: 95pt)[Urgent Ptr#sub[2B]]
      #cell(fill: C.reserved, width: 95pt, dash: "dashed")[Options]
    ]
  ]

  #h(16pt)

  #schema(title: [*UDP Datagram*], desc: [Connectionless, no ordering.])[
    #region(fill: C.transport)[
      #cell(fill: C.addr, width: 75pt)[Src Port#sub[2B]]
      #cell(fill: C.addr, width: 75pt)[Dst Port#sub[2B]]
      #cell(fill: C.meta, width: 60pt)[Length#sub[2B]]
      #cell(fill: C.checksum, width: 75pt)[Checksum#sub[2B]]
    ]
  ]
]

// --- Layer 2: Internet Layer ---

#section[Layer 2 — Internet][
  #schema(title: [*IPv4 Header*], desc: [20–60 bytes. TTL prevents routing loops.])[
    #bit-row(total: 32, width: row-w, fields: (
      (bits: 4,  label: [Ver],          fill: C.meta),
      (bits: 4,  label: [IHL],          fill: C.meta),
      (bits: 8,  label: [DSCP],         fill: C.flag),
      (bits: 16, label: [Total Length],  fill: C.meta),
    ))
    #bit-row(total: 32, width: row-w, fields: (
      (bits: 16, label: [Identification], fill: C.meta),
      (bits: 3,  label: [Flg],            fill: C.flag),
      (bits: 13, label: [Frag Offset],     fill: C.meta),
    ))
    #bit-row(total: 32, width: row-w, fields: (
      (bits: 8,  label: [TTL],            fill: C.meta),
      (bits: 8,  label: [Protocol],        fill: C.meta),
      (bits: 16, label: [Hdr Checksum],    fill: C.checksum),
    ))
    #bit-row(total: 32, width: row-w, fields: (
      (bits: 32, label: [Source Address], fill: C.addr),
    ))
    #bit-row(total: 32, width: row-w, fields: (
      (bits: 32, label: [Destination Address], fill: C.addr),
    ))
  ]
]

// --- Layer 1: Link Layer ---

#section[Layer 1 — Link (Ethernet)][
  #schema(title: [*Ethernet II Frame*], desc: [IEEE 802.3. Preamble and FCS handled by hardware.])[
    #region(fill: C.link, width: 490pt)[
      #cell(fill: C.addr, width: 80pt)[Dst MAC#sub[6B]]
      #cell(fill: C.addr, width: 80pt)[Src MAC#sub[6B]]
      #cell(fill: C.meta, width: 70pt)[EtherType#sub[2B]]
      #cell(fill: C.data, width: 140pt, expandable: true)[Payload#sub[46–1500B]]
      #cell(fill: C.checksum, width: 45pt)[FCS#sub[4B]]
    ]
  ]
]

#v(16pt)

// --- Encapsulation Overview ---

#section[Encapsulation (top \u{2192} bottom)][
  #text(size: 0.8em, fill: luma(80))[
    Each layer wraps the layer above as its payload:
  ]
  #v(6pt)
  #let r = 3pt
  #let layer-row(fill, width, body) = box(
    width: width, fill: fill, radius: r,
    stroke: (paint: fill.darken(20%), thickness: 0.5pt),
    inset: (x: 4pt, y: 5pt), baseline: 30%, body,
  )
  #let hdr(label, fill, width) = box(
    width: width, fill: fill, radius: r,
    stroke: (paint: fill.darken(30%), thickness: 0.5pt),
    inset: (x: 4pt, y: 3pt), baseline: 30%,
    { set align(center); text(size: 0.8em, label) },
  )
  #let payload(label, fill, width) = box(
    width: width, fill: fill, radius: r,
    stroke: (paint: fill.darken(20%), thickness: 0.5pt),
    inset: (x: 4pt, y: 3pt), baseline: 30%,
    { set align(center); text(size: 0.8em, label) },
  )
  #align(center)[
    #grid(
      columns: 1,
      row-gutter: 4pt,
      layer-row(C.app.lighten(30%), 350pt)[
        #text(size: 0.8em, weight: "bold")[Application Data]
      ],
      layer-row(C.transport.lighten(20%), 390pt)[
        #hdr([TCP Hdr], C.transport, 55pt)
        #payload([Application Data], C.app.lighten(30%), 260pt)
      ],
      layer-row(C.internet.lighten(20%), 430pt)[
        #hdr([IP Hdr], C.internet, 45pt)
        #hdr([TCP Hdr], C.transport, 55pt)
        #payload([Application Data], C.app.lighten(30%), 240pt)
      ],
      layer-row(C.link.lighten(20%), 470pt)[
        #hdr([Eth Hdr], C.link, 45pt)
        #hdr([IP Hdr], C.internet, 45pt)
        #hdr([TCP], C.transport, 40pt)
        #payload([Application Data], C.app.lighten(30%), 200pt)
        #hdr([FCS], C.checksum, 35pt)
      ],
    )
  ]
]
