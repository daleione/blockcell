#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#seq-lane(
  width: 380pt,
  seq-call("client", "biz")[POST /order],
  seq-call("biz", "db")[INSERT tx],
  seq-ret("db", "biz")[OK],
  seq-ret("biz", "client")[201],
)
