#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Advanced features: return keyword, divider, destroy, alt-else.
#seq-puml(
  width: 380pt,
  `
  participant Client
  participant API
  participant Worker

  Client -> API : POST /job
  == handshake ==
  API -> Worker : enqueue
  return job-id
  return 202 accepted

  == execution ==
  Client -> API : GET /job/42
  alt finished
    API --> Client : 200 result
  else still running
    API --> Client : 202 pending
  end
`)

#v(24pt)

// destroy keyword and !! suffix
#seq-puml(
  width: 380pt,
  `
  participant Client
  participant Worker
  participant Temp

  Client -> Worker : start
  Worker -> Temp : spawn
  Temp --> Worker : ready
  Worker -> Temp : do work
  Temp --> Worker : result
  destroy Temp
  Worker --> Client : finished
`)

#v(24pt)

// autonumber, group / critical / break, and delay
#seq-puml(
  width: 380pt,
  `
  participant User
  participant Web
  participant DB

  autonumber
  User -> Web : login
  group Authentication phase
    Web -> DB : check credentials
    DB --> Web : ok
  end
  ...
  autonumber stop
  Web -> Web : compose page
  autonumber resume
  critical render
    Web --> User : page
  end
  ...500ms later...
  break user clicks logout
    User -> Web : logout
  end
`)
