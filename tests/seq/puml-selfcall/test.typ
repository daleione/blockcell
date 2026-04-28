#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Single self-call, sequential self-calls, nested self-calls,
// self-call with explicit return, and self-call inside a fragment.
#seq-puml(
  width: 380pt,
  `
  participant Client
  participant Service

  Client -> Service : request
  Service -> Service : validate
  Service -> Service : authorize
  Service -> Service : outer
  Service -> Service : inner
  Service --> Service : inner ok
  Service --> Service : outer ok
  alt branch
    Service -> Service : log
  end
  Service --> Client : response
`)
