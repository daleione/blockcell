#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Focused regression fixture for self-call anchor geometry.
// Verifies:
// 1. outer self-call: lifeline -> first activation
// 2. inner self-call: first activation -> second activation
// 3. inner self-return: second activation -> first activation
// 4. outer self-return: first activation -> lifeline
#seq-lane(
  width: 320pt,
  participants: (
    (id: "svc", name: [service]),
  ),
  seq-call("svc", "svc")[outer],
  seq-call("svc", "svc")[inner],
  seq-ret("svc", "svc")[inner ok],
  seq-ret("svc", "svc")[outer ok],
)

#v(24pt)

// Same anchor rules, but with a caller present, to ensure the self-call
// geometry remains correct when nested inside a normal request/response flow.
#seq-lane(
  width: 380pt,
  participants: (
    (id: "client", name: [client]),
    (id: "svc", name: [service]),
  ),
  seq-call("client", "svc")[request],
  seq-call("svc", "svc")[outer],
  seq-call("svc", "svc")[inner],
  seq-ret("svc", "svc")[inner ok],
  seq-ret("svc", "svc")[outer ok],
  seq-ret("svc", "client")[response],
)
