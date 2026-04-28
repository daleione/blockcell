#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// box grouping + boundary arrows + ref + space
#seq-puml(
  width: 380pt,
  `
  participant Browser
  box "Backend" #LightBlue
    participant API
    participant Worker
  end box

  [-> Browser : open
  Browser -> API : POST /op
  API -> Worker : enqueue
  ref over API, Worker : detailed flow
  Worker --> API : done
  |||
  API --> Browser : 200
  Browser ->] : metric
`)

#v(20pt)

// `**` suffix → seq-create + destroy
#seq-puml(
  width: 380pt,
  `
  participant Client
  participant Factory

  Client -> Factory : new product
  Factory -> Worker ** : spawn
  Worker --> Factory : ready
  Factory --> Client : product
  Client -> Worker : use
  Worker --> Client : result
  destroy Worker
`)
