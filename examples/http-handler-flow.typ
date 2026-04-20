// ============================================================================
// Example: HTTP Request Handler Flow
// ============================================================================
// A worker loop that handles one HTTP request per iteration, exercising
// nearly every flow-chart primitive in the library:
//
//   flow-loop       outer worker loop wrapping the whole handler
//   flow-col        the linear body inside the loop
//   branch          early-exit decisions (`no:` side-exits to a terminal)
//   branch-merge    cache-hit fast-path vs. cache-miss full-compute
//   switch + case   endpoint routing fanning out to 3 handlers
//   process         the default blue action step
//   decision        implicit inside branch/branch-merge/switch diamonds
//   terminal        entry + exit points; red variant via `status: "danger"`
//   junction        cross-reference marker ("checkpoint A")
//   edge-label      labels the "Yes" arrow out of the signature check
//   status: shorthand for semantic state colors on terminals
//
// Every box shows its default semantic color (process=blue, decision=yellow,
// terminal=green, junction=cyan) — the only explicit fills are the two
// success/alternate paths inside branch-merge where Return-cached and the
// switch cases want to stand out with distinct pastels.
// ============================================================================

#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 24pt)
#set text(size: 10pt, lang: "zh", font: ("LXGW WenKai"))

#align(center)[
  #text(size: 16pt, weight: "bold")[HTTP Request Handler — Worker Loop]
  #v(4pt)
  #text(size: 9pt, fill: luma(120))[
    每轮循环处理一个请求；签名失败或 shutdown 指令分别从两条 `branch` 侧支退出
  ]
]

#v(12pt)

#align(center)[
  #flow-loop(
    flow-col(
      terminal[Accept connection],
      process[Read HTTP request],

      // Early-exit branch: reject invalid signatures. `no:` side-exits to a
      // terminal; `yes` path is the implicit continuation of the flow-col.
      branch([Signature valid?],
        no: terminal(status: "danger")[401 Reject],
      ),

      // Label the implicit Yes-arrow by attaching `edge-label:` to the
      // destination node — robust under reordering, no positional indexing.
      process(edge-label: [Yes])[Check rate limit],

      // Two-arm merge: cache hit returns fast; cache miss fans out through
      // an endpoint switch and rejoins at the bottom.
      branch-merge([Cache hit?],
        yes: process(fill: palettes.pastel.green)[Return cached response],
        no:  switch([endpoint],
          case([/users],  process(fill: palettes.pastel.cyan)[Fetch user data]),
          case([/orders], process(fill: palettes.pastel.orange)[Fetch orders]),
          case([/stats],  process(fill: palettes.pastel.purple)[Compute stats]),
        ),
      ),

      process[Serialize response body],
      process[Write cache + emit audit log],

      // Junction marker — shared reference point with other diagrams
      // (e.g. the admin audit pipeline picks up here).
      junction[A],

      // Loop continuation branch: "yes" falls to Continue which lets the
      // flow-loop back-edge carry execution up to the top; "no" side-exits
      // via a red Shutdown terminal.
      branch([More requests?],
        yes: process[Continue],
        no:  terminal(status: "danger")[Shutdown],
      ),
    ),
    back-label: [next request],
  )
]

#v(16pt)

#align(center)[
  #region(width: 520pt)[
    #text(weight: "bold")[节点颜色图例]
    #v(4pt)
    #legend(
      (label: [`terminal` 默认], fill: palettes.pastel.green),
      (label: [`process` 默认],  fill: palettes.pastel.blue),
      (label: [`decision` 默认], fill: palettes.pastel.yellow),
      (label: [`junction` 默认], fill: palettes.pastel.cyan),
      (label: [`status: danger`], fill: palettes.status.danger.fill),
    )
  ]
]
