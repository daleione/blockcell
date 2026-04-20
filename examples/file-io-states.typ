// ============================================================================
// Example: File I/O state machine — reading → eof → closed
// ============================================================================
// Mirrors the classic fletcher state-diagram sample: three linear states with
// a self-loop on "reading" and a jump from "reading" directly to "closed".
// ============================================================================

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 24pt)
#set text(size: 11pt, font: ("Inter", "PingFang SC"))

#align(center)[
  #text(size: 14pt, weight: "bold")[File I/O state machine]
  #v(10pt)
  #state-chain(
    state("reading", initial: true)[reading],
    state("eof",    edge-label: [`read()`])[eof],
    state("closed", edge-label: [`close()`], accept: true)[closed],
    loop("reading")[`read()`],
    jump("reading", "closed", route: "below")[`close()`],
  )
]
