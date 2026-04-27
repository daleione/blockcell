#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Covers self-calls with activation nesting:
// 1. Two sequential self-calls (each gets its own offset rect)
// 2. One truly nested self-call (recursive: self-call inside a self-call)
#seq-lane(
  width: 380pt,
  participants: (
    (id: "client", name: [client]),
    (id: "biz", name: [biz]),
  ),

  // --- Sequential self-calls (each independent) ---
  seq-call("client", "biz")[GET /profile],
  seq-call("biz", "biz")[validate token],
  seq-ret("biz", "biz")[ok],
  seq-call("biz", "biz")[load session],
  seq-ret("biz", "biz")[ok],
  seq-ret("biz", "client")[200 OK],
)

#v(24pt)

// --- Truly nested (recursive) self-call ---
#seq-lane(
  width: 380pt,
  participants: (
    (id: "client", name: [client]),
    (id: "svc", name: [service]),
  ),
  seq-call("client", "svc")[request],
  seq-call("svc", "svc")[outer validate],
  seq-call("svc", "svc")[inner check],
  seq-ret("svc", "svc")[inner ok],
  seq-ret("svc", "svc")[outer ok],
  seq-ret("svc", "client")[response],
)
