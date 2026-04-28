#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Top-level autonumber: true
#seq-lane(
  width: 380pt,
  autonumber: true,
  seq-call("client", "biz")[POST /order],
  seq-call("biz", "db")[INSERT tx],
  seq-ret("db", "biz")[OK],
  seq-ret("biz", "client")[201],
)

#v(20pt)

// Custom start/step via parameter
#seq-lane(
  width: 380pt,
  autonumber: (start: 100, step: 5),
  seq-call("a", "b")[hi],
  seq-call("b", "c")[forward],
  seq-ret("c", "a")[done],
)

#v(20pt)

// Inline control: start / stop / resume / restart-with-new-step
#seq-lane(
  width: 380pt,
  seq-autonumber(),
  seq-call("a", "b")[step 1],
  seq-call("b", "c")[step 2],
  seq-autonumber-stop(),
  seq-call("a", "b")[unnumbered],
  seq-autonumber-resume(),
  seq-call("a", "b")[step 3],
  seq-autonumber(start: 100, step: 10),
  seq-call("a", "b")[step 100],
  seq-call("a", "c")[step 110],
)
