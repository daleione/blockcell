#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Multi-branch alt with else, nested loop+opt, par.
#seq-puml(
  width: 380pt,
  `
  participant Client
  participant Server
  participant Cache

  Client -> Server : GET /item/42
  alt cache hit
    Server -> Cache : lookup
    Cache --> Server : value
  else cache miss
    Server -> Cache : lookup
    Cache --> Server : nil
    loop retry up to 3
      Server -> Server : compute
    end
  else fatal error
    Server --> Client : 500
  end
  Server --> Client : 200 OK
`)

#v(24pt)

// par + opt + nested alt
#seq-puml(
  width: 380pt,
  `
  participant A
  participant B
  participant C

  A -> B : start
  par
    B -> C : task1
    C --> B : ok1
  end
  opt fast path
    A -> C : shortcut
    alt success
      C --> A : data
    else timeout
      C --> A : retry-later
    end
  end
  B --> A : done
`)
