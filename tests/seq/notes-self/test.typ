#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Covers: standalone seq-act (outside any activation), a spanning note,
// and a self-call nested inside a real client→biz request.
#seq-lane(
  width: 360pt,
  participants: (
    (id: "client", name: [client]),
    (id: "biz",    name: [biz]),
  ),
  seq-act("biz")[warm connection pool],
  seq-note(("client", "biz"))[Session established],
  seq-call("client", "biz")[GET /profile],
  seq-call("biz", "biz")[validate token],
  seq-ret("biz", "client")[200 OK],
)
