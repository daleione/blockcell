#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// P0 basic: participants, calls, returns, self-call, notes, fragments, divider, arrow color
#seq-puml(
  width: 400pt,
  `
  participant Browser
  participant "API Server" as API
  participant Auth
  participant DB

  Browser -> API : POST /login
  API -> API : validate input
  alt credentials provided
    API -> Auth : authenticate
    Auth -> DB : SELECT user
    DB --> Auth : user row
    note over Auth : bcrypt compare
    Auth --> API : session token
  end
  API --> Browser : 200 + Set-Cookie
`)

#v(24pt)

// Self-call with explicit return, note spanning two participants
#seq-puml(
  width: 380pt,
  `
  participant client
  participant service

  client -> service : request
  service -> service : outer validate
  service -> service : inner check
  service --> service : inner ok
  service --> service : outer ok
  service --> client : response
`)

#v(24pt)

// Fragments: loop + opt, divider, colored arrow
#seq-puml(
  width: 380pt,
  `
  actor User
  participant App
  database Store

  User -> App : open
  == Initialization ==
  loop every 5s
    App -> Store : ping
    Store --> App : pong
  end
  opt cache miss
    App -[#FF0000]> Store : fetch
    Store --> App : data
  end
  App --> User : ready
`)
