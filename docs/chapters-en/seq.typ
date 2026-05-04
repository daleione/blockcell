#import "../../lib.typ": *
#import "../style.typ": *

= Sequence diagrams <seq>

*blockcell* ships a sequence-diagram toolkit covering the UML vocabulary — #api-ref("layer3-seq-lane", "seq-lane")
(the declarative API) and `seq-puml` (a PlantUML-compatible layer). They share one renderer,
so behavior is identical: anything PlantUML can express, the Typst API can write directly.

Scope: *interaction flows where participants call each other* (API call chains, protocol
handshakes, login flows, microservice orchestration, …). For "a single object's state changes
over time", use #api-ref("layer3-lane", "lane") (in the "Composites" chapter), or
#api-ref("states-state-chain", "state-chain") in the "State transition diagrams" chapter.

#v(6pt)

#align(center)[
  #region(fill: rgb("#E0F2F1"), width: 100%)[
    #text(weight: "bold")[Components in this chapter]
    #v(2pt)
    #grid(
      columns: (110pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[Messages],
      text(size: 0.85em)[#api-ref("seq-seq-call", "seq-call") `(from, to)[..]` synchronous call ·
        #api-ref("seq-seq-ret", "seq-ret") `(from, to)[..]` return ·
        `from == to` automatically renders as a #doc-link("seq-self-call")[self-call] loop],
      text(size: 0.85em, weight: "bold")[Notes],
      text(size: 0.85em)[#api-ref("seq-seq-note", "seq-note") `(over)[..]` folded-corner note ·
        #api-ref("seq-seq-act", "seq-act") `(who)[..]` single-column work block ·
        #api-ref("seq-seq-ref", "seq-ref") `(over)[..]` external reference frame],
      text(size: 0.85em, weight: "bold")[Fragments],
      text(size: 0.85em)[#doc-link("seq-fragments")[`seq-alt` + `seq-else` · `seq-opt` · `seq-loop` ·
        `seq-par`] · plus `group` / `break` / `critical` (see relevant subsection)],
      text(size: 0.85em, weight: "bold")[Pacing],
      text(size: 0.85em)[#doc-link("seq-structure")[`seq-divider[..]` stage divider ·
        `seq-delay[..]` time-passes marker · `seq-space()` blank row]],
      text(size: 0.85em, weight: "bold")[Lifecycle],
      text(size: 0.85em)[#doc-link("seq-lifecycle")[`seq-create(who)` inline header ·
        `seq-destroy(who)` × marker, truncates the lifeline]],
      text(size: 0.85em, weight: "bold")[Boundaries],
      text(size: 0.85em)[#doc-link("seq-boundary-arrows")[Use `"["` / `"]"` for the
        diagram's left / right edge — arrows enter from or leave for "outside"]],
      text(size: 0.85em, weight: "bold")[Numbering],
      text(size: 0.85em)[#doc-link("seq-autonumber")[Top-level `autonumber:` parameter ·
        inline `seq-autonumber()` / `seq-autonumber-stop()` /
        `seq-autonumber-resume()`]],
      text(size: 0.85em, weight: "bold")[Grouping],
      text(size: 0.85em)[#doc-link("seq-boxes")[`boxes:` parameter — swim-lane frame across
        consecutive participants]],
      text(size: 0.85em, weight: "bold")[Compatibility],
      text(size: 0.85em)[`seq-puml(body)` accepts PlantUML source as a string;
        styling parameters pass through to #api-ref("layer3-seq-lane", "seq-lane")],
    )
  ]
]

== Quick start <seq-quick-start>

The most basic "client → service → database" call:

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "biz")[POST /order],
    seq-note("biz")[validate stock],
    seq-alt([ok],
      seq-call("biz", "db")[INSERT],
      seq-ret("db", "biz")[OK],
    ),
    seq-ret("biz", "client")[201],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "biz")[POST /order],
      seq-note("biz")[validate stock],
      seq-alt([ok],
        seq-call("biz", "db")[INSERT],
        seq-ret("db", "biz")[OK],
      ),
      seq-ret("biz", "client")[201],
    )
  ],
)

#v(4pt)

How to read it: participants lay out left-to-right in the order their ids first appear in the
steps; colors cycle through `palettes.categorical`. `seq-call` opens an "activation rectangle"
by default (the narrow vertical bar showing a participant is executing); a matching `seq-ret`
closes it. `seq-alt` takes a bracketed condition as its first arg and nested steps after.
All step functions take their "semantic argument" through a trailing content block
(`seq-call("a", "b")[label]`).

== Basic messages <seq-basic-messages>

#metadata("seq-seq-ret") <seq-seq-ret>
=== `seq-call` / `seq-ret` <seq-seq-call>

`seq-call` is a synchronous call (solid line + filled triangle arrowhead);
`seq-ret` is a return (dashed line + open V arrowhead).
Both use the same `(from, to)[label]` shape — the third (content-block) argument is the
small annotation above the message line.

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[req],
    seq-call("b", "c")[forward],
    seq-ret("c", "b")[ack],
    seq-ret("b", "a")[done],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[req],
      seq-call("b", "c")[forward],
      seq-ret("c", "b")[ack],
      seq-ret("b", "a")[done],
    )
  ],
)

#v(4pt)

Activation rectangles are tracked automatically: every `seq-call(A, B)` activates A and B
(if not already active); a matching `seq-ret` closes them. Multiple nested calls and calls
across fragments work as you'd expect from a call stack. To disable activations entirely,
pass `activate: false` to `seq-lane`.

You can color a single message line with `stroke:`:

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[normal],
    seq-call("a", "b", stroke: red)[error],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[normal],
      seq-call("a", "b", stroke: red)[error],
    )
  ],
)

#v(4pt)

`head:` overrides the default arrowhead. Allowed values:
`"filled"` (sync-call default), `"v"` (return default / `->>` async open arrow),
`"x"` (×, lost message), `"o"` (open circle, e.g. cache hit or callback registration),
`"half-top"` / `"half-bottom"` (single-side slashes — PUML's `\` / `/` half arrows).
`seq-puml` automatically fills in the right `head:` based on PUML arrow modifiers.

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b", head: "v")[async],
    seq-call("a", "b", head: "x")[lost],
    seq-call("a", "b", head: "o")[circle],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b", head: "v")[async],
      seq-call("a", "b", head: "x")[lost],
      seq-call("a", "b", head: "o")[circle],
    )
  ],
)

#v(4pt)

=== Self-calls and nesting <seq-self-call>

When `from == to`, `seq-call` automatically renders a U-shaped loop on the right; the
activation expands into an inset sub-rectangle (which can nest):

#wide-example(
  ```typ
  #seq-lane(
    seq-call("svc", "svc")[outer],
    seq-call("svc", "svc")[inner],
    seq-ret("svc", "svc")[inner ok],
    seq-ret("svc", "svc")[outer ok],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("svc", "svc")[outer],
      seq-call("svc", "svc")[inner],
      seq-ret("svc", "svc")[inner ok],
      seq-ret("svc", "svc")[outer ok],
    )
  ],
)

#v(4pt)

You can omit `seq-ret` and the engine still closes things up automatically: when a participant's
next action is a message *to someone else*, any unclosed self-call belonging to it auto-closes.
This lets simple "validate input"-style self-calls be a single line —
`seq-call("svc", "svc")[validate]` — with no matching `seq-ret`.

== Notes and annotations <seq-notes>

=== `seq-note` <seq-seq-note>

A folded-corner note placed over one or more participants. `over` accepts a single id or
`("a", "b")` for a span.

#wide-example(
  ```typ
  #seq-lane(
    seq-call("a", "b")[req],
    seq-note("b")[note over single participant],
    seq-call("b", "c")[forward],
    seq-note(("b", "c"))[note across two columns],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("a", "b")[req],
      seq-note("b")[note over single participant],
      seq-call("b", "c")[forward],
      seq-note(("b", "c"))[note across two columns],
    )
  ],
)

#v(4pt)

=== `seq-act` <seq-seq-act>

`seq-act(who)[..]` draws a colored work block in a single participant column — more prominent
than a note, ideal for "this participant did something locally".

Note: `seq-act` cannot land on a row where the participant is *already activated* — a wide
block on top of a narrow activation bar reads badly. The engine panics with a hint to switch
to `seq-note` instead.

=== `seq-ref` <seq-seq-ref>

UML's "reference frame" — "the details of this interaction live in another diagram".
Rectangle border + a `ref` corner marker on the upper left, spanning the named participants:

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "auth")[login],
    seq-ref(("auth", "db"))[
      detailed credential check (auth-flow)
    ],
    seq-ret("auth", "client")[token],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "auth")[login],
      seq-ref(("auth", "db"))[
        detailed credential check (auth-flow)
      ],
      seq-ret("auth", "client")[token],
    )
  ],
)

#v(4pt)

== Fragments <seq-fragments>

UML wraps "branches / loops / optionals / parallels" as *combined fragments* — a dashed frame
with an operator name in the upper-left corner. `seq-lane` provides the full set, all using the
same `seq-X(condition, ..steps)` shape:

#grid(
  columns: (200pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-alt(cond, ..)`],
  [Optional branches; first arg is the bracketed condition.],
  text(weight: "bold")[`seq-else(label)`],
  [The *branch separator* inside `seq-alt` — subsequent siblings render in a new branch with
   an extra dashed line and an `[else: ..]` label on the frame.],
  text(weight: "bold")[`seq-opt(cond, ..)`],
  [Conditionally-executed block ("only run if condition is met").],
  text(weight: "bold")[`seq-loop(cond, ..)`],
  [Loop.],
  text(weight: "bold")[`seq-par(label, ..)`],
  [Parallel; conventionally laid out side by side.],
)

`group` / `break` / `critical` currently exist as "generic fragment kinds", primarily produced
by `seq-puml` from PlantUML input (see the compatibility section). When using the API directly,
the fixed set of `seq-alt` / `seq-opt` / `seq-loop` / `seq-par` covers about 95% of use cases.

#section-label[alt + else]

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "server")[GET],
    seq-alt([cache hit],
      seq-call("server", "cache")[lookup],
      seq-ret("cache", "server")[value],
      seq-else([cache miss]),
      seq-call("server", "cache")[lookup],
      seq-ret("cache", "server")[nil],
      seq-call("server", "server")[compute],
    ),
    seq-ret("server", "client")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "server")[GET],
      seq-alt([cache hit],
        seq-call("server", "cache")[lookup],
        seq-ret("cache", "server")[value],
        seq-else([cache miss]),
        seq-call("server", "cache")[lookup],
        seq-ret("cache", "server")[nil],
        seq-call("server", "server")[compute],
      ),
      seq-ret("server", "client")[200],
    )
  ],
)

#v(4pt)

`seq-else` is a step marker — drop it among `seq-alt`'s children. Use as many as you want;
each starts a new branch.

#section-label[opt / loop / par]

#wide-example(
  ```typ
  #seq-lane(
    seq-loop([every 5s],
      seq-call("agent", "server")[heartbeat],
      seq-ret("server", "agent")[ack],
    ),
    seq-opt([config changed],
      seq-call("server", "agent")[reload],
    ),
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-loop([every 5s],
        seq-call("agent", "server")[heartbeat],
        seq-ret("server", "agent")[ack],
      ),
      seq-opt([config changed],
        seq-call("server", "agent")[reload],
      ),
    )
  ],
)

#v(4pt)

== Pacing and structure <seq-structure>

Tools for segmenting interactions, leaving whitespace, and showing "time has passed":

#grid(
  columns: (200pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-divider[label]`],
  [Full-width double rule + centered bold label. Splits logical phases ("init / main loop / cleanup").],
  text(weight: "bold")[`seq-delay[label]`],
  ["Time passed". Each lifeline gets a column of vertical ellipses, with an optional centered
   pill label (e.g. "5 minutes later").],
  text(weight: "bold")[`seq-space()`],
  [Pure blank row. Stretches the layout.],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-call("c", "s")[POST /job],
    seq-divider[handshake],
    seq-call("s", "w")[enqueue],
    seq-ret("w", "s")[job-id],
    seq-ret("s", "c")[202],
    seq-delay[5 minutes later],
    seq-call("c", "s")[GET /job/42],
    seq-ret("s", "c")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("c", "s")[POST /job],
      seq-divider[handshake],
      seq-call("s", "w")[enqueue],
      seq-ret("w", "s")[job-id],
      seq-ret("s", "c")[202],
      seq-delay[5 minutes later],
      seq-call("c", "s")[GET /job/42],
      seq-ret("s", "c")[200],
    )
  ],
)

#v(4pt)

== Lifecycle <seq-lifecycle>

UML distinguishes *static participants* (present from the start) from *dynamically-created*
ones (born during a particular call), which may also be explicitly destroyed.
`seq-create` and `seq-destroy` correspond to each:

#grid(
  columns: (200pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-create(who)`],
  [Defers this participant's *header frame* to this row; its lifeline starts here downward.
   The top header row reserves an empty slot. Usually paired with the `seq-call` that triggers
   creation.],
  text(weight: "bold")[`seq-destroy(who)`],
  [Draws an × on this row; the participant's lifeline truncates, all open activations close,
   and no further messages should reference this id.],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-call("client", "factory")[new product],
    seq-create("worker"),
    seq-call("factory", "worker")[spawn],
    seq-ret("worker", "factory")[ready],
    seq-ret("factory", "client")[product],
    seq-call("client", "worker")[use],
    seq-ret("worker", "client")[result],
    seq-destroy("worker"),
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("client", "factory")[new product],
      seq-create("worker"),
      seq-call("factory", "worker")[spawn],
      seq-ret("worker", "factory")[ready],
      seq-ret("factory", "client")[product],
      seq-call("client", "worker")[use],
      seq-ret("worker", "client")[result],
      seq-destroy("worker"),
    )
  ],
)

#v(4pt)

== Boundary arrows <seq-boundary-arrows>

UML uses the diagram's left / right edge to denote "outside the system". Set a message's
`from` or `to` to the literal `"["` (left edge) or `"]"` (right edge), and the arrow enters
from / leaves for the boundary — without an explicit "outside participant" taking a column.

#wide-example(
  ```typ
  #seq-lane(
    seq-call("[", "browser")[page request],
    seq-call("browser", "api")[POST /op],
    seq-call("api", "]")[publish metric],
    seq-ret("api", "browser")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-call("[", "browser")[page request],
      seq-call("browser", "api")[POST /op],
      seq-call("api", "]")[publish metric],
      seq-ret("api", "browser")[200],
    )
  ],
)

#v(4pt)

Boundary endpoints don't participate in "auto id collection" and aren't drawn as a participant
header / lifeline — they're just rendering anchors.

== Auto-numbering <seq-autonumber>

PlantUML's `autonumber` has two equivalent paths in `seq-lane`:

#section-label[Top-level parameter]

`seq-lane(autonumber: ..)` covers common cases with one argument:

#grid(
  columns: (200pt, 1fr),
  row-gutter: 5pt,
  raw("false", lang: none),
  [Off (default).],
  raw("true", lang: none),
  [Start at 1, step 1.],
  raw("(start: int, step: int)", lang: none),
  [Custom start and step.],
)

#wide-example(
  ```typ
  #seq-lane(
    autonumber: (start: 100, step: 5),
    seq-call("a", "b")[hi],
    seq-call("b", "c")[forward],
    seq-ret("c", "a")[done],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      autonumber: (start: 100, step: 5),
      seq-call("a", "b")[hi],
      seq-call("b", "c")[forward],
      seq-ret("c", "a")[done],
    )
  ],
)

#v(4pt)

#section-label[Inline control]

To pause / resume / reset numbering mid-diagram, use the three control steps:

#grid(
  columns: (240pt, 1fr),
  row-gutter: 5pt,
  text(weight: "bold")[`seq-autonumber(start, step)`],
  [Start or reset the counter. Both `start:` and `step:` default to 1.],
  text(weight: "bold")[`seq-autonumber-stop()`],
  [Pause. Calls / returns in between aren't numbered.],
  text(weight: "bold")[`seq-autonumber-resume(step:)`],
  [Resume from where it paused. Optional `step:` changes the step size.],
)

#wide-example(
  ```typ
  #seq-lane(
    seq-autonumber(),
    seq-call("a", "b")[step 1],
    seq-call("b", "c")[step 2],
    seq-autonumber-stop(),
    seq-call("a", "b")[(unnumbered)],
    seq-autonumber-resume(),
    seq-call("a", "b")[step 3],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      seq-autonumber(),
      seq-call("a", "b")[step 1],
      seq-call("b", "c")[step 2],
      seq-autonumber-stop(),
      seq-call("a", "b")[(unnumbered)],
      seq-autonumber-resume(),
      seq-call("a", "b")[step 3],
    )
  ],
)

#v(4pt)

Numbers are rendered in bold `*N.*` form, prefixed to the original label.

== Participants <seq-participants>

=== `participants` parameter <seq-participants-arg>

When omitted, the engine collects ids in the order they first appear in steps, with colors
cycling through `palettes.categorical`. Pass it to lock down order and display name explicitly:

```typ
#seq-lane(
  participants: (
    (id: "browser", name: [Browser]),
    (id: "api",     name: [API], fill: rgb("#FFE0B2")),
    (id: "auth",    name: [Auth]),
    (id: "db",      name: [DB]),
  ),
  seq-call("browser", "api")[POST /login],
  // ...
)
```

Each item needs at least `id:`. `name:` defaults to `raw(id)`; `fill:` defaults to the cycling
palette color. An id that *doesn't appear in any step* is rejected (panic) — better to delete
the column than leave an orphan.

=== `boxes` — Swim-lane grouping <seq-boxes>

PlantUML's `box ... end box`: frame *adjacent* participants and their lifelines as one logical
boundary ("internal services" / "storage layer", …).

#wide-example(
  ```typ
  #seq-lane(
    participants: (
      (id: "browser", name: [Browser]),
      (id: "api",     name: [API]),
      (id: "worker",  name: [Worker]),
    ),
    boxes: (
      (name: [Backend], ids: ("api", "worker"),
       fill: rgb("#B3E5FC")),
    ),
    seq-call("browser", "api")[POST /op],
    seq-call("api", "worker")[enqueue],
    seq-ret("worker", "api")[done],
    seq-ret("api", "browser")[200],
  )
  ```,
  [
    #seq-lane(
      width: 100%,
      participants: (
        (id: "browser", name: [Browser]),
        (id: "api",     name: [API]),
        (id: "worker",  name: [Worker]),
      ),
      boxes: (
        (name: [Backend], ids: ("api", "worker"),
         fill: rgb("#B3E5FC")),
      ),
      seq-call("browser", "api")[POST /op],
      seq-call("api", "worker")[enqueue],
      seq-ret("worker", "api")[done],
      seq-ret("api", "browser")[200],
    )
  ],
)

#v(4pt)

Each box is `(name:, ids: ("a", "b", ..), fill?:)`. `ids` must be *contiguous* in the final
column order — otherwise it panics. The frame extends from the top title bar all the way to
the bottom of the diagram, with participant headers, lifelines, activations, and message
arrows all stacked on top.

== `seq-puml` — PlantUML compatibility layer

Pass PlantUML sequence-diagram source as a string / raw block to `seq-puml`; it parses and
translates to the corresponding `seq-lane` + `seq-*` calls. All `seq-lane` styling parameters
pass through.

#wide-example(
  ```typ
  #seq-puml(`
    participant Browser
    box "Backend" #LightBlue
      participant API
      participant Worker
    end box

    autonumber
    Browser -> API : POST /login
    alt cache hit
      API -> Worker : lookup
      Worker --> API : value
    else cache miss
      API -> Worker : compute
      Worker --> API : value
    end
    ...
    API --> Browser : 200
  `)
  ```,
  [
    #seq-puml(width: 100%, `
      participant Browser
      box "Backend" #LightBlue
        participant API
        participant Worker
      end box

      autonumber
      Browser -> API : POST /login
      alt cache hit
        API -> Worker : lookup
        Worker --> API : value
      else cache miss
        API -> Worker : compute
        Worker --> API : value
      end
      ...
      API --> Browser : 200
    `)
  ],
)

#v(4pt)

#section-label[Supported PlantUML subset]

#grid(
  columns: (180pt, 1fr),
  row-gutter: 4pt,
  text(weight: "bold", size: 0.9em)[Participants],
  text(size: 0.9em)[`participant` / `actor` / `boundary` / `control` /
    `entity` / `database` / `collections` / `queue` (all rendered as rectangles) ·
    `"Long Name" as alias` · `#color`],
  text(weight: "bold", size: 0.9em)[Messages],
  text(size: 0.9em)[`->` / `-->` / `->>` / `-->>` / `<-` / `<--` ·
    `-[#color]>` colored arrows · `[->` / `[<-` / `->]` / `<-]` boundary arrows],
  text(weight: "bold", size: 0.9em)[Suffixes],
  text(size: 0.9em)[`!!` destroy target · `**` create target ·
    `++` / `--` absorbed by auto-activation],
  text(weight: "bold", size: 0.9em)[Activation],
  text(size: 0.9em)[`activate` / `deactivate` tracked automatically; explicit forms also accepted],
  text(weight: "bold", size: 0.9em)[Notes],
  text(size: 0.9em)[`note over A` (one or two participants, single-line or multi-line +
    `end note`) · `note left/right` · `note across` · `ref over A, B`],
  text(weight: "bold", size: 0.9em)[Fragments],
  text(size: 0.9em)[`alt` / `else` / `end` · `opt` · `loop` · `par` ·
    `group <label>` · `break` · `critical` (nested arbitrarily)],
  text(weight: "bold", size: 0.9em)[Pacing],
  text(size: 0.9em)[`== text ==` divider · `...` / `...label...` time-passes ·
    `\|\|\|` / `\|\|N\|\|` blank rows],
  text(weight: "bold", size: 0.9em)[Lifecycle],
  text(size: 0.9em)[`create X` / `destroy X` · `**` / `!!` suffixes],
  text(weight: "bold", size: 0.9em)[Numbering],
  text(size: 0.9em)[`autonumber [start [step]]` / `autonumber stop` /
    `autonumber resume [step]`],
  text(weight: "bold", size: 0.9em)[Grouping],
  text(size: 0.9em)[`box "Name" [#color] ... end box`],
  text(weight: "bold", size: 0.9em)[Ignored],
  text(size: 0.9em)[`@startuml` / `@enduml` / `'` line comments /
    `skinparam` / `hide` / `title` / `header` / `footer`],
)

#v(6pt)

Not implemented: `hnote` / `rnote` shape variants (rendered as plain notes); slanted arrows
`->(N)`; Teoz mode `&` parallel; `mainframe`; Creole rich text (Typst markup itself handles
basic `*bold*` and `_italic_`; richer Creole isn't expanded).

#section-label[Lenient parsing]

Unrecognized lines are *silently skipped*. This keeps copy-pasting from PlantUML from panicking
on minor differences, but it also means typos won't trigger a warning. If you write puml source
by hand, render and compare before shipping.

== `seq-lane` full parameters

#params-box("seq-lane",
  ("..steps",          ("content",)),
  ("width",            ("auto", "length")),
  ("step-height",      ("length",)),
  ("header-height",    ("length",)),
  ("column-gap",       ("length",)),
  ("row-gap",          ("length",)),
  ("activate",         ("bool",)),
  ("activation-width", ("length",)),
  ("autonumber",       ("bool", "dictionary")),
  ("participants",     ("none", "array")),
  ("boxes",            ("none", "array")),
  returns: "content",
)

#param-detail("participants", ("none", "array"),
  default: raw("none", lang: none))[
  Lock participant order and display names. Each item is a dictionary like
  `(id: "biz", name: [Business], fill: color)`. When omitted, ids are inferred in order of
  first appearance, with colors cycling through `palettes.categorical`. An `id` must appear
  in at least one step — orphan columns panic.
]

#param-detail("boxes", ("none", "array"),
  default: raw("none", lang: none))[
  Swim-lane groups. Each item is `(name: [..], ids: ("a", "b", ..), fill?: color)`.
  `ids` must be *contiguous* in the final column order. `name` renders as a centered bold
  title at the top. The frame spans the entire body (headers + lifelines + messages),
  forming a visual container.
]

#param-detail("autonumber", ("bool", "dictionary"),
  default: raw("false", lang: none))[
  Top-level auto-numbering. `true` is equivalent to `(start: 1, step: 1)`; pass a dictionary
  for custom values. For finer in-line control use the three step functions
  `seq-autonumber()` / `seq-autonumber-stop()` / `seq-autonumber-resume(step:)`.
  Both paths share one implementation and can be mixed.
]

#param-detail("activate", ("bool",), default: raw("true", lang: none))[
  Whether to draw activation rectangles ("focus of control" — the narrow vertical bars
  showing a participant is executing). `seq-call` opens; matching `seq-ret` closes;
  self-calls expand into right-shifted sub-rectangles (which can nest).
  When off, all messages connect directly to the lifelines without rectangles.
]

#param-detail("activation-width", ("length",),
  default: raw("0.8em", lang: none))[
  Width of an activation rectangle. Also affects the offset of nested self-call sub-rectangles
  (offset = `activation-width / 2`, overlapping the parent rectangle by half).
]

#param-detail("step-height", ("length",), default: raw("3em", lang: none))[
  Height of each step row (excluding row spacing). Decrease for a more compact diagram, increase
  for more annotation room. Notes / reference frames adapt to this height.
]

#param-detail("column-gap", ("length",), default: raw("1em", lang: none))[
  Horizontal spacing between participant columns. Affects message-arrow length and note width.
]

#param-detail("row-gap", ("length",), default: raw("0.4em", lang: none))[
  Row spacing — only affects whitespace between adjacent step rows; fragment frames default to
  aligning with the row baseline.
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  Total diagram width. `auto` takes the parent container's `100%`. At document scale it's
  common to fix a pt value (e.g. `380pt`) so multiple diagrams line up horizontally.
]
