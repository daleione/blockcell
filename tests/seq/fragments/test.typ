#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#seq-lane(
  width: 400pt,
  seq-call("client", "biz")[POST /order/create],
  seq-alt([validation passed],
    seq-call("biz", "lock")[acquire],
    seq-ret("lock", "biz")[granted],
    seq-call("biz", "db")[INSERT],
    seq-ret("db", "biz")[OK],
  ),
  seq-ret("biz", "client")[201],
)
