// ============================================================================
// Sequence diagrams: participants, messages, activation, and UML fragments
// ============================================================================
//
// seq-lane     Renderer: participants (auto-derived), lifelines, activation
//              rectangles, message arrows, fragment frames
//
// Step constructors:
//   seq-call     synchronous message (filled triangle head)
//   seq-ret      response message (dashed + open V head)
//   seq-note     sticky-note spanning one or more columns
//   seq-act      action block in a single column
//   seq-divider  full-width horizontal line + centered label (phase marker)
//   seq-else     branch separator inside seq-alt; subsequent siblings render
//                under the new bracketed condition
//   seq-destroy  terminates a participant's lifeline at this row with an ×
//   seq-create   delays a participant's header rendering to this row; the
//                top header is omitted and the lifeline starts below
//   seq-delay    "time passes" gap; vertical dots on every lifeline + an
//                optional pill label centered across the row
//   seq-space    blank row used as a layout spacer
//   seq-ref      reference / external interaction frame; rectangular box
//                with a "ref" corner tag, rendered above one or more lifelines
//   seq-autonumber*       inline auto-numbering control (start/stop/resume)
//   seq-alt      alt fragment (dashed frame, bracketed condition)
//   seq-opt      opt fragment
//   seq-loop     loop fragment
//   seq-par      par fragment
// ============================================================================

#import "palettes.typ": palettes
#import "internal/metrics.typ": metrics

/// Constructors for `seq-lane` steps. Each returns a tagged dict that the
/// renderer understands. Use trailing-content-block syntax for labels:
/// `seq-call("client", "biz")[POST /create]`. Fragments take a condition as
/// the first positional arg and child steps as variadic.
///
/// - `seq-call(from, to)[label]`     synchronous message; self-loop when
///                                   `from == to`
/// - `seq-ret(from, to)[label]`      response (dashed + open V head)
/// - `seq-note(over)[label]`         sticky-note; `over` is one id or a
///                                   2-tuple `("a", "b")` to span columns
/// - `seq-act(who)[label]`           action block in one column; `who` must
///                                   NOT be inside an activation at that
///                                   step — use `seq-note` to annotate an
///                                   already-active participant
/// - `seq-divider[label]`            full-width horizontal line with centered
///                                   label, occupying its own row; used to
///                                   mark a phase transition or scene break
/// - `seq-else[condition]`           branch separator inside `seq-alt`: a
///                                   dashed line crossing the alt frame with
///                                   the next branch's bracketed condition
/// - `seq-destroy(who)`              terminate the participant's lifeline
///                                   with an × marker at this row; closes any
///                                   open activation, no further messages
///                                   should reference the participant
/// - `seq-create(who)`               delay the participant's header to this
///                                   row instead of the top — the lifeline
///                                   starts below the inline header, modeling
///                                   "this participant is born here"
/// - `seq-delay()` / `seq-delay[…]`  "time passes" marker: vertical dots on
///                                   every lifeline + an optional centered
///                                   pill label
/// - `seq-space()`                   blank row used purely for layout — adds
///                                   a step-height worth of vertical air,
///                                   lifelines pass through unchanged
/// - `seq-ref(over)[label]`          reference frame: rectangular box with
///                                   a `ref` corner tag, used to point at an
///                                   external diagram for the interaction
///                                   between the listed participants
/// - `seq-autonumber(start, step)`   inline: (re)start auto-numbering at the
///                                   given start (default 1) with given step
///                                   (default 1); subsequent call/return
///                                   labels gain an `*N.*` bold prefix
/// - `seq-autonumber-stop()`         pause numbering; intervening messages
///                                   render their labels as-is
/// - `seq-autonumber-resume(step:)`  resume numbering from where it stopped;
///                                   optionally change the step
/// - `seq-alt(condition, ..steps)`   alt fragment with bracketed condition
/// - `seq-opt(condition, ..steps)`   opt fragment
/// - `seq-loop(condition, ..steps)`  loop fragment
/// - `seq-par(condition, ..steps)`   par fragment
// head: optional override of the arrow head shape — one of
//   "filled" (sync default), "v" (return default / async open V),
//   "x" (lost), "o" (open circle), "half-top", "half-bottom".
#let seq-call(from, to, body, stroke: none, head: none) = {
  let s = (type: "call", from: from, to: to, label: body)
  if stroke != none { s.insert("stroke", stroke) }
  if head != none { s.insert("head", head) }
  s
}
#let seq-ret(from, to, body, stroke: none, head: none) = {
  let s = (type: "return", from: from, to: to, label: body)
  if stroke != none { s.insert("stroke", stroke) }
  if head != none { s.insert("head", head) }
  s
}
#let seq-note(over, body) = (
  type: "note", over: over, label: body,
)
#let seq-act(who, body) = (
  type: "action", who: who, label: body,
)
#let seq-divider(body) = (
  type: "divider", label: body,
)
#let seq-else(body) = (
  type: "alt-else", label: body,
)
#let seq-destroy(who) = (
  type: "destroy", who: who,
)
#let seq-create(who) = (
  type: "create", who: who,
)
#let seq-delay(body) = (
  type: "delay", label: body,
)
#let seq-space() = (
  type: "space",
)
#let seq-ref(over, body) = (
  type: "ref", over: over, label: body,
)
#let seq-autonumber(start: 1, step: 1) = (
  type: "autonumber", action: "start", start: start, step: step,
)
#let seq-autonumber-stop() = (
  type: "autonumber", action: "stop",
)
#let seq-autonumber-resume(step: none) = (
  type: "autonumber", action: "resume", step: step,
)
#let seq-alt(label, ..children) = (
  type: "fragment", kind: "alt", label: label, children: children.pos(),
)
#let seq-opt(label, ..children) = (
  type: "fragment", kind: "opt", label: label, children: children.pos(),
)
#let seq-loop(label, ..children) = (
  type: "fragment", kind: "loop", label: label, children: children.pos(),
)
#let seq-par(label, ..children) = (
  type: "fragment", kind: "par", label: label, children: children.pos(),
)

/// A sequence diagram. Steps are variadic positional args built with the
/// `seq-*` constructors:
///
/// ```typst
/// #seq-lane(
///   seq-call("client", "biz")[POST /order/create],
///   seq-note("biz")[校验库存与黑名单],
///   seq-alt([validation passed],
///     seq-call("biz", "ganon")[POST /lock],
///     seq-ret("ganon", "biz")[200 OK],
///   ),
///   seq-ret("biz", "client")[201 Created],
/// )
/// ```
///
/// Participants are auto-derived from the step IDs in first-appearance order
/// using `palettes.categorical` for colors. To override display name or fill
/// for any participant, pass `participants: ((id: "biz", name: [Business],
/// fill: my-color), …)` — only the listed ids are overridden; ordering still
/// follows the user list, with any extra ids appended in step order.
///
/// When `activate` is true (default), narrow activation rectangles ("focus of
/// control") are drawn on the lifelines from each `call` to its matching
/// `return` from the same participant — UML's standard convention for showing
/// when a participant is actively executing. Message arrows attach to the
/// activation edges, not the lifeline center. Returns use an open V arrow
/// head to visually distinguish them from synchronous calls.
#let seq-lane(
  width: auto,
  step-height: 3em,
  header-height: 2.6em,
  column-gap: 1em,
  row-gap: 0.4em,
  activate: true,
  activation-width: 0.8em,
  autonumber: false,
  participants: none,
  boxes: none,
  message-align: "center",
  response-below: false,
  ..steps,
) = context {
  let em = 1em.to-absolute()
  let head-size = metrics.head-size.to-absolute()
  let step-height = step-height.to-absolute()
  let row-gap = row-gap.to-absolute()
  let column-gap = column-gap.to-absolute()
  let activation-width = if activation-width == metrics.activation-width {
    metrics.activation-width.to-absolute()
  } else {
    activation-width.to-absolute()
  }
  let total-width = if width == auto { 100% } else { width }
  let row-h = step-height + row-gap

  // Recursively expand nested fragment dicts into the linear
  // `fragment-start` / `fragment-end` sequence the renderer below understands.
  let flatten(items) = {
    let out = ()
    for item in items {
      if item.type == "fragment" {
        out.push((type: "fragment-start", kind: item.kind, label: item.label))
        out += flatten(item.children)
        out.push((type: "fragment-end"))
      } else {
        out.push(item)
      }
    }
    out
  }
  let raw-steps = flatten(steps.pos())

  // Auto-derive participants: walk the flat step list, collect every id we
  // see in first-appearance order, assign default colors from the categorical
  // palette. User-supplied `participants` overrides per-id (matched on `id`)
  // and takes ordering precedence; any ids not in the user list get appended
  // in step-discovery order.
  // Boundary endpoints — virtual anchors for `[->`/`->]` style arrows that
  // connect to the figure's left/right edge instead of a real participant.
  let is-edge(id) = id == "[" or id == "]"

  let cat = palettes.categorical
  let auto-ids = ()
  let auto-seen = (:)
  for step in raw-steps {
    let candidates = ()
    let f = step.at("from", default: none)
    if f != none and not is-edge(f) { candidates.push(f) }
    let t = step.at("to", default: none)
    if t != none and not is-edge(t) { candidates.push(t) }
    let w = step.at("who", default: none)
    if w != none { candidates.push(w) }
    let over = step.at("over", default: none)
    if over != none {
      if type(over) == str { candidates.push(over) }
      else { for o in over { candidates.push(o) } }
    }
    for id in candidates {
      if not (id in auto-seen) {
        auto-seen.insert(id, true)
        auto-ids.push(id)
      }
    }
  }

  let user-overrides = (:)
  let user-order = ()
  if participants != none {
    let seen-user-ids = (:)
    for p in participants {
      if not ("id" in p) {
        panic("seq-lane participants entries must include `id`.")
      }
      if p.id in seen-user-ids {
        panic("seq-lane participants contains duplicate id `" + p.id + "`.")
      }
      seen-user-ids.insert(p.id, true)
      user-overrides.insert(p.id, p)
      user-order.push(p.id)
    }
  }
  let extra-ids = auto-ids.filter(id => not (id in user-overrides))
  let final-ids = user-order + extra-ids
  let resolved-participants = ()
  for (i, id) in final-ids.enumerate() {
    let default = (
      id: id,
      name: raw(id),
      fill: cat.at(calc.rem(i, cat.len())),
    )
    let override = user-overrides.at(id, default: (:))
    resolved-participants.push(default + override)
  }

  let participants = resolved-participants
  let steps = raw-steps
  let n = participants.len()
  if n == 0 { return [] }

  let id-to-col = (:)
  for (i, p) in participants.enumerate() {
    id-to-col.insert(p.id, i)
  }

  // Pre-process: separate fragment markers from rendered steps. Fragment
  // markers (`fragment-start` / `fragment-end`) don't occupy a row; they
  // bracket a range of subsequent steps that get a dashed frame around them.
  // Returns `render-steps` (the rows that actually get drawn) and `fragments`
  // (range + kind + label tuples). Unclosed fragments auto-close at the last
  // rendered step.
  //
  // The same walk also threads the auto-numbering state through the step
  // stream: `seq-autonumber* ()` control steps mutate `autonum-state`, and
  // each call/return that lands in render-steps records its assigned number
  // (or `none`) into the parallel `step-numbers` array consulted at render
  // time to prefix the label.
  let autonum-state = if autonumber == false {
    none
  } else if autonumber == true {
    (current: 1, step: 1, paused: false)
  } else {
    (
      current: autonumber.at("start", default: 1),
      step: autonumber.at("step", default: 1),
      paused: false,
    )
  }
  let render-steps = ()
  let step-numbers = ()
  let fragments = ()
  let frag-stack = ()
  for step in steps {
    if step.type == "fragment-start" {
      frag-stack.push((
        start: render-steps.len(),
        depth: frag-stack.len(),
        kind: step.at("kind", default: "alt"),
        label: step.at("label", default: none),
      ))
    } else if step.type == "fragment-end" {
      if frag-stack.len() > 0 {
        let frag = frag-stack.pop()
        fragments.push((
          start: frag.start,
          end: calc.max(render-steps.len() - 1, frag.start),
          depth: frag.depth,
          kind: frag.kind,
          label: frag.label,
        ))
      }
    } else if step.type == "autonumber" {
      if step.action == "start" {
        autonum-state = (
          current: step.at("start", default: 1),
          step: step.at("step", default: 1),
          paused: false,
        )
      } else if step.action == "stop" {
        if autonum-state != none { autonum-state.paused = true }
      } else if step.action == "resume" {
        if autonum-state == none {
          autonum-state = (current: 1, step: 1, paused: false)
        }
        autonum-state.paused = false
        let s = step.at("step", default: none)
        if s != none { autonum-state.step = s }
      }
    } else {
      let is-msg = step.type == "call" or step.type == "return"
      let active = autonum-state != none and not autonum-state.paused
      let assign = if is-msg and active {
        let n = autonum-state.current
        autonum-state.current = autonum-state.current + autonum-state.step
        n
      } else {
        none
      }
      step-numbers.push(assign)
      render-steps.push(step)
    }
  }
  for frag in frag-stack {
    fragments.push((
      start: frag.start,
      end: calc.max(render-steps.len() - 1, frag.start),
      depth: frag.depth,
      kind: frag.kind,
      label: frag.label,
    ))
  }

  let body-height = step-height * render-steps.len() + row-gap * calc.max(render-steps.len() - 1, 0)

  // Map participant id → render-step index where it is destroyed. Beyond that
  // row, the lifeline does not render and any open activations are clamped.
  let destroy-row = (:)
  // Map participant id → render-step index where its header is rendered
  // inline (instead of at the top header row); the lifeline starts below.
  let create-row = (:)
  for (i, step) in render-steps.enumerate() {
    if step.type == "destroy" and not (step.who in destroy-row) {
      destroy-row.insert(step.who, i)
    }
    if step.type == "create" and not (step.who in create-row) {
      create-row.insert(step.who, i)
    }
  }

  // Auto-derive activation ranges from call/return pairs.
  //
  // Two kinds of activation:
  //   depth 0  — the "base" activation opened by a cross-participant call
  //              and closed by the corresponding return.  Centered on the
  //              lifeline, exactly like before.
  //   depth 1+ — a "nested" activation opened by a self-call while the
  //              participant is already active.  Each self-call gets its OWN
  //              short rectangle, offset to the right of the base rect.
  //              Multiple sequential self-calls each get depth 1 (they don't
  //              stack horizontally); truly recursive self-calls (self-call
  //              inside a self-call before its return) get depth 2, 3, etc.
  let activations = ()
  // Per-step lookup: for a self-call at render-step i on participant id,
  // stores the nesting depth so the self-loop renderer knows how far right
  // to draw.
  let self-step-depth = (:)
  if activate {
    // Base activation tracking (depth 0): one entry per participant,
    // tracking whether it currently has an open base activation.
    let base-open = (:)  // id -> start step index (or none)

    // When a self-call lands on an inactive participant we implicitly open
    // a base activation so the outer rect is visible (otherwise the U-shape
    // departs from a bare lifeline and looks like a missing rectangle).
    // Records the self-call start index that opened the base; the matching
    // self-return then closes both the depth-1 rect and the base.
    let base-self-opener = (:)  // id -> step index (or none)

    // Top-edge offset (0..1 within step-height) of the base rect at its open
    // step, set when base is opened.  Cross-participant arrows enter at the
    // row's horizon center (0.5); a self-call exits the parent rect at 0.25
    // (top of its U-shape), so its auto-opened base must extend up to 0.25
    // for the arrow to leave from the rect's right edge.
    let base-top-y = (:)  // id -> fraction

    // Self-call nesting tracking: a stack per participant of open self-call
    // start indices.  Stack length = current nesting depth above the base.
    let self-stack = (:)  // id -> array of start step indices

    for (i, step) in render-steps.enumerate() {
      if step.type == "call" {
        // Boundary arrows don't carry an activation on their virtual edge
        // endpoint — only the real participant side participates in the
        // activation stack.
        if is-edge(step.from) or is-edge(step.to) {
          let real = if is-edge(step.from) { step.to } else { step.from }
          if base-open.at(real, default: none) == none {
            base-open.insert(real, i)
            base-top-y.insert(real, 0.5)
          }
        } else if step.from == step.to {
          // Self-call: open a nested activation rectangle.  If the
          // participant currently has no base activation, also implicitly
          // open one so the outer (depth-0) rect anchors the U-shape; the
          // matching self-return will close both.
          if base-open.at(step.from, default: none) == none {
            base-open.insert(step.from, i)
            base-self-opener.insert(step.from, i)
            base-top-y.insert(step.from, 0.25)
          }
          let stack = self-stack.at(step.from, default: ())
          let depth = stack.len() + 1  // depth 1 for first self-call
          self-step-depth.insert(str(i) + ":" + step.from, depth)
          stack.push(i)
          self-stack.insert(step.from, stack)
        } else {
          // Cross-participant call: auto-close any open self-call activations
          // on the sender.  A self-call is a synchronous internal operation —
          // it must complete before the participant can send a message to
          // someone else.  This lets users omit the explicit seq-ret for
          // simple self-calls like "validate input".
          let sender-stack = self-stack.at(step.from, default: ())
          while sender-stack.len() > 0 {
            let start = sender-stack.pop()
            let depth = sender-stack.len() + 1
            activations.push((
              col: id-to-col.at(step.from),
              start: start,
              end: i - 1,
              depth: depth,
            ))
            // If this force-closed self-call had auto-opened the base,
            // the base ownership now transfers to the outgoing cross call —
            // keep base-open as is, just clear the opener tracking.
            if base-self-opener.at(step.from, default: none) == start {
              base-self-opener.insert(step.from, none)
            }
          }
          self-stack.insert(step.from, sender-stack)

          // Open base activation on sender if needed.
          if base-open.at(step.from, default: none) == none {
            base-open.insert(step.from, i)
            base-top-y.insert(step.from, 0.5)
          }
          // Open base activation on receiver if needed.
          if base-open.at(step.to, default: none) == none {
            base-open.insert(step.to, i)
            base-top-y.insert(step.to, 0.5)
          }
        }
      } else if step.type == "return" {
        if is-edge(step.from) or is-edge(step.to) {
          // Boundary return: close the real participant's base activation.
          let real = if is-edge(step.from) { step.to } else { step.from }
          let start = base-open.at(real, default: none)
          if start != none {
            activations.push((
              col: id-to-col.at(real),
              start: start,
              end: i,
              depth: 0,
              top-y: base-top-y.at(real, default: 0.5),
              bot-y: 0.5,
            ))
            base-open.insert(real, none)
          }
          continue
        }
        // Check if this closes a self-call first.
        let stack = self-stack.at(step.from, default: ())
        if stack.len() > 0 {
          let start = stack.pop()
          let depth = stack.len() + 1
          activations.push((
            col: id-to-col.at(step.from),
            start: start,
            end: i,
            depth: depth,
          ))
          self-stack.insert(step.from, stack)
          // If this self-call had auto-opened the base, close that too.
          if base-self-opener.at(step.from, default: none) == start {
            let base-start = base-open.at(step.from)
            activations.push((
              col: id-to-col.at(step.from),
              start: base-start,
              end: i,
              depth: 0,
              top-y: base-top-y.at(step.from, default: 0.25),
              bot-y: 0.75,
            ))
            base-open.insert(step.from, none)
            base-self-opener.insert(step.from, none)
          }
        } else {
          // Closes a base activation.
          let start = base-open.at(step.from, default: none)
          if start != none {
            activations.push((
              col: id-to-col.at(step.from),
              start: start,
              end: i,
              depth: 0,
              top-y: base-top-y.at(step.from, default: 0.5),
              bot-y: 0.5,
            ))
            base-open.insert(step.from, none)
          }
        }
      } else if step.type == "destroy" {
        // Close any open activations on the destroyed participant.
        let id = step.who
        let stack = self-stack.at(id, default: ())
        while stack.len() > 0 {
          let start = stack.pop()
          let depth = stack.len() + 1
          activations.push((
            col: id-to-col.at(id),
            start: start,
            end: i,
            depth: depth,
          ))
        }
        self-stack.insert(id, ())
        let start = base-open.at(id, default: none)
        if start != none {
          activations.push((
            col: id-to-col.at(id),
            start: start,
            end: i,
            depth: 0,
            top-y: base-top-y.at(id, default: 0.5),
            bot-y: 0.5,
          ))
          base-open.insert(id, none)
          base-self-opener.insert(id, none)
        }
      }
    }
    // Close any still-open self-call activations.
    for (id, stack) in self-stack {
      let remaining = stack
      while remaining.len() > 0 {
        let start = remaining.pop()
        let depth = remaining.len() + 1
        activations.push((
          col: id-to-col.at(id),
          start: start,
          end: render-steps.len() - 1,
          depth: depth,
        ))
      }
    }
    // Close any still-open base activations.
    for (id, start) in base-open {
      if start != none {
        // If the base was auto-opened by a self-call (no explicit return), the
        // U-shape's return arm lands at y=0.75 of the call's row — extend the
        // base down to cover that so the rectangle wraps the whole U.
        let opened-by-self = base-self-opener.at(id, default: none) != none
        let bot = if opened-by-self { 0.75 } else { 0.5 }
        activations.push((
          col: id-to-col.at(id),
          start: start,
          end: render-steps.len() - 1,
          depth: 0,
          top-y: base-top-y.at(id, default: 0.5),
          bot-y: bot,
        ))
      }
    }
  }

  // Drop one-shot base activations that don't span anything — typical for
  // `A -> B` calls with no matching return; they'd render as a hairline on
  // the lifeline and just add visual noise. But keep all nested (depth >= 1)
  // activations regardless of span (a self-call legitimately has start ==
  // end yet draws a meaningful U-shape), and keep any depth-0 base that
  // wraps a nested activation so the U-shape's outer rect stays anchored.
  let _acts-snapshot = activations
  activations = activations.filter(a => {
    if a.depth > 0 { return true }
    if a.start != a.end { return true }
    _acts-snapshot.any(o =>
      o.depth > 0 and o.col == a.col
      and o.start <= a.end and o.end >= a.start)
  })

  // True if column `col` has an activation rectangle covering step `i`.
  let is-active(col, i) = activations.any(a =>
    a.col == col and a.start <= i and i <= a.end)

  // Innermost activation depth covering step `i` in column `col`.
  let active-depth(col, i) = {
    let depth = -1
    for a in activations {
      if a.col == col and a.start <= i and i <= a.end {
        depth = calc.max(depth, a.depth)
      }
    }
    depth
  }

  // A `seq-act` placed inside an existing activation on the same participant
  // is ambiguous (new discrete action vs. continuation of the in-flight call)
  // and its wide box overlaps the narrow activation strip in a close fill
  // family — the diagram reads as visual noise. Fail fast with a fix hint.
  for (i, step) in render-steps.enumerate() {
    if step.type == "action" and is-active(id-to-col.at(step.who), i) {
      panic(
        "seq-act on \"" + step.who + "\" is inside an activation on the same "
        + "participant. Move it outside the surrounding call/return pair, or "
        + "use seq-note for annotations on an already-active participant.",
      )
    }
  }

  // Head renderers. UML conventions:
  //   filled triangle  ▶          — synchronous call
  //   open V (two strokes)        — return / async open arrow
  //   x (two crossed strokes)     — lost message marker
  //   o (open circle)             — circle endpoint
  //   half-top / half-bottom      — single-stroke half arrows
  // Each returns a content sized head-size × head-size; the tip / endpoint
  // sits on the side opposite `dir` so the caller can place the bounding
  // box flush against the line endpoint.
  let head-filled(paint, dir) = if dir == "right" {
    polygon(fill: paint, stroke: none,
      (0pt, 0pt), (head-size, head-size / 2), (0pt, head-size))
  } else {
    polygon(fill: paint, stroke: none,
      (head-size, 0pt), (0pt, head-size / 2), (head-size, head-size))
  }
  let head-v(paint, dir) = if dir == "right" {
    box(width: head-size, height: head-size, {
      place(top + left,
        line(start: (0pt, 0pt), end: (head-size, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal)))
      place(top + left,
        line(start: (0pt, head-size), end: (head-size, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal)))
    })
  } else {
    box(width: head-size, height: head-size, {
      place(top + left,
        line(start: (head-size, 0pt), end: (0pt, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal)))
      place(top + left,
        line(start: (head-size, head-size), end: (0pt, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal)))
    })
  }
  // × marker for "lost message". Two diagonals through the head's center.
  let head-x(paint, dir) = box(width: head-size, height: head-size, {
    let s = (paint: paint, thickness: metrics.stroke-normal)
    place(top + left,
      line(start: (0pt, 0pt), end: (head-size, head-size), stroke: s))
    place(top + left,
      line(start: (0pt, head-size), end: (head-size, 0pt), stroke: s))
  })
  // Open circle endpoint. Sized slightly smaller than head-size so it visually
  // matches the triangle/V head weights.
  let head-o(paint, dir) = {
    let d = head-size * 0.7
    let pad = (head-size - d) / 2
    box(width: head-size, height: head-size,
      place(top + left, dx: pad, dy: pad,
        circle(radius: d / 2,
               fill: none,
               stroke: (paint: paint, thickness: metrics.stroke-normal))))
  }
  // Half arrows: only the upper or lower diagonal of the V. Direction-aware
  // so a left-pointing arrow keeps the chosen half on the same visual side.
  let head-half-top(paint, dir) = if dir == "right" {
    box(width: head-size, height: head-size,
      place(top + left,
        line(start: (0pt, 0pt), end: (head-size, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal))))
  } else {
    box(width: head-size, height: head-size,
      place(top + left,
        line(start: (head-size, 0pt), end: (0pt, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal))))
  }
  let head-half-bottom(paint, dir) = if dir == "right" {
    box(width: head-size, height: head-size,
      place(top + left,
        line(start: (0pt, head-size), end: (head-size, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal))))
  } else {
    box(width: head-size, height: head-size,
      place(top + left,
        line(start: (head-size, head-size), end: (0pt, head-size / 2),
             stroke: (paint: paint, thickness: metrics.stroke-normal))))
  }
  let render-head(kind, paint, dir) = {
    if kind == "v" { head-v(paint, dir) }
    else if kind == "x" { head-x(paint, dir) }
    else if kind == "o" { head-o(paint, dir) }
    else if kind == "half-top" { head-half-top(paint, dir) }
    else if kind == "half-bottom" { head-half-bottom(paint, dir) }
    else { head-filled(paint, dir) }
  }

  // The colspan cell covers `span` columns plus (span-1) gutters. We want
  // the message line to start at the source lifeline (col-lo center) and end
  // at the destination lifeline (col-hi center), so we inset by half a column
  // on each side. col_w = (colspan_w - (span-1)*gap) / span, so the inset
  // ratio is 50%/span minus the gap-correction term. When an endpoint sits
  // on an active participant, we additionally pull the line in by half the
  // activation width so the arrow attaches to the activation edge instead
  // of overlapping the rectangle.
  let message-line(label: none, direction: "right", style: "solid",
                   head: "filled",
                   stroke-paint: palettes.base.border, span: 2,
                   lo-active: false, hi-active: false) = {
    let line-stroke = (paint: stroke-paint, thickness: metrics.stroke-normal,
                      dash: if style == "solid" { none } else { "dashed" })
    let inset = 50% / span - (span - 1) * column-gap / (2 * span)
    let act-shift = activation-width / 2
    let left-extra = if lo-active { act-shift } else { 0pt }
    let right-extra = if hi-active { act-shift } else { 0pt }
    let line-len = 100% - 2 * inset - left-extra - right-extra
    // `responseMessageBelowArrow true` puts response labels under the line.
    // A "response" is either a dashed return arrow (`-->`) or a reversed-
    // direction call (`<-`) — both read as a reply to the previous call.
    let is-return = style != "solid" or direction == "left"
    let label-dy = if is-return and response-below { 0.6 * em } else { -0.6 * em }
    // Resolve `message-align`: `direction` follows the arrow head's side so
    // the label hugs the destination; explicit left/center/right are absolute.
    let align-kind = if message-align == "direction" { direction } else { message-align }
    let (label-anchor, label-dx) = if align-kind == "left" {
      (horizon + left, inset + left-extra + 0.4 * em)
    } else if align-kind == "right" {
      (horizon + right, -(inset + right-extra) - 0.4 * em)
    } else {
      (horizon + center, 0pt)
    }
    block(width: 100%, height: 100%, {
      if label != none {
        place(label-anchor, dx: label-dx, dy: label-dy,
          text(size: 0.65em, fill: palettes.base.text-muted, label))
      }
      place(horizon + left, dx: inset + left-extra,
        line(length: line-len, stroke: line-stroke))
      let anchor = if direction == "right" { horizon + right } else { horizon + left }
      let dx = if direction == "right" { -(inset + right-extra) } else { inset + left-extra }
      place(anchor, dx: dx, render-head(head, stroke-paint, direction))
    })
  }

  // Nested activation offset: how far right each nesting level shifts.
  // The offset rect overlaps the base rect by half its width (standard UML).
  let nested-offset = activation-width / 2

  // Self-call arrow: a U-shape from the right edge of the current activation
  // level, going right → down → left to the LEFT edge of the new offset
  // activation rect.  Only used for `type: "call"` with `from == to`.
  let self-call-arrow(label: none,
                      stroke-paint: palettes.base.border, depth: 1) = {
    let line-stroke = (paint: stroke-paint, thickness: metrics.stroke-normal)
    // Right edge of the parent rect (departure point).
    let from-x = 50% + activation-width / 2 + (depth - 1) * nested-offset
    // Right edge of the new offset rect (arrival point).
    let target-x = 50% + activation-width / 2 + depth * nested-offset
    let loop-w = 2 * em
    let y-start = step-height * 0.25
    let y-end   = step-height * 0.75
    block(width: 100%, height: 100%, {
      // Horizontal out →
      place(top + left, dx: from-x, dy: y-start,
        line(length: loop-w, stroke: line-stroke))
      // Vertical down
      place(top + left, dx: from-x + loop-w, dy: y-start,
        line(angle: 90deg, length: y-end - y-start, stroke: line-stroke))
      // Horizontal back ← to the offset rect left edge + arrowhead
      place(top + left, dx: target-x + head-size, dy: y-end,
        line(length: from-x + loop-w - target-x - head-size, stroke: line-stroke))
      // Filled arrowhead pointing left at the offset rect left edge
      place(top + left, dx: target-x, dy: y-end - head-size / 2,
        head-filled(stroke-paint, "left"))
      // Label to the right of the loop
      if label != none {
        place(horizon + left, dx: from-x + loop-w + 0.4 * em,
          text(size: 0.65em, fill: palettes.base.text-muted, label))
      }
    })
  }

  // Self-return arrow: a U-shape mirror of the self-call arrow.
  // Departs from the offset rect RIGHT edge, goes right → down → left,
  // arriving at the parent activation rect RIGHT edge with a dashed open-V
  // arrowhead.  This mirrors the call U-shape and is clearly visible.
  let self-return-arrow(label: none,
                        stroke-paint: palettes.base.border, depth: 1) = {
    let line-stroke = (paint: stroke-paint, thickness: metrics.stroke-normal,
                      dash: "dashed")
    // Right edge of the offset rect at this depth (departure point).
    let depart-x = 50% + activation-width / 2 + depth * nested-offset
    // Right edge of the parent rect (arrival point for arrowhead).
    let arrive-x = 50% + activation-width / 2 + (depth - 1) * nested-offset
    let loop-w = 2 * em
    let y-start = step-height * 0.25
    let y-end   = step-height * 0.75
    block(width: 100%, height: 100%, {
      // Horizontal out → from offset rect right edge
      place(top + left, dx: depart-x, dy: y-start,
        line(length: loop-w, stroke: line-stroke))
      // Vertical down
      place(top + left, dx: depart-x + loop-w, dy: y-start,
        line(angle: 90deg, length: y-end - y-start, stroke: line-stroke))
      // Horizontal back ← to parent right edge + arrowhead
      place(top + left, dx: arrive-x + head-size, dy: y-end,
        line(length: depart-x + loop-w - arrive-x - head-size, stroke: line-stroke))
      // Open-V arrowhead pointing left at parent right edge
      place(top + left, dx: arrive-x, dy: y-end - head-size / 2,
        head-v(stroke-paint, "left"))
      // Label to the right of the loop
      if label != none {
        place(horizon + left, dx: depart-x + loop-w + 0.4 * em,
          text(size: 0.65em, fill: palettes.base.text-muted, label))
      }
    })
  }

  // Sticky-note: a pentagon whose top-right corner is clipped diagonally so
  // the silhouette itself reads as folded. A darker triangle snapped against
  // the diagonal fills the interior slice and stands in for the folded-back
  // side of the paper. `layout` resolves the ratio width to a concrete length
  // so the polygon math is in absolute units, and `measure` sizes the note to
  // its label the way a `box` with insets would auto-size.
  let render-note(label, fill: rgb("#FFF9C4"), stroke-paint: rgb("#A88B00")) = {
    let inset-x = 1 * em
    let inset-y = 0.3 * em
    let fold = 0.6 * em
    let stroke = 0.5pt + stroke-paint
    let content = align(center + horizon, text(size: 0.75em, label))
    align(horizon, layout(size => context {
      let w = size.width
      let content-h = measure(block(width: w - 2 * inset-x, content)).height
      let h = content-h + 2 * inset-y
      box(width: w, height: h, {
        place(top + left,
          polygon(fill: fill, stroke: stroke,
            (0pt, 0pt),
            (w - fold, 0pt),
            (w, fold),
            (w, h),
            (0pt, h)))
        place(top + left, dx: w - fold,
          polygon(fill: fill.darken(14%), stroke: stroke,
            (0pt, 0pt),
            (fold, fold),
            (0pt, fold)))
        place(top + left, dx: inset-x, dy: inset-y,
          block(width: w - 2 * inset-x, content))
      })
    }))
  }

  // UML interaction-reference frame ("ref"): a plain bordered rectangle
  // (no folded corner — it's a delegation marker, not a sticky note) with a
  // small `ref` corner tag in the top-left. Sized like a note via measure.
  let render-ref(label) = {
    let inset-x = 1 * em
    let inset-y = 0.4 * em
    let stroke-paint = palettes.base.border-soft
    let stroke = metrics.stroke-thin + stroke-paint
    let fill = palettes.base.surface
    let content = align(center + horizon, text(size: 0.75em, label))
    align(horizon, layout(size => context {
      let w = size.width
      let content-h = measure(block(width: w - 2 * inset-x, content)).height
      let h = content-h + 2 * inset-y
      box(width: w, height: h, {
        place(top + left,
          rect(width: w, height: h, fill: fill, stroke: stroke))
        place(top + left, dx: inset-x, dy: inset-y,
          block(width: w - 2 * inset-x, content))
        place(top + left,
          box(fill: fill, stroke: stroke,
              inset: (x: 0.4em, y: 0.05em),
              radius: (bottom-right: 3pt),
              text(size: 0.55em, weight: "bold", "ref")))
      })
    }))
  }

  let render-header(p) = box(
    width: 100%, height: 100%,
    fill: p.fill, stroke: 0.8pt + palettes.base.border,
    radius: 3pt, inset: (x: 0.6em, y: 0.4em),
    align(center + horizon, text(weight: "bold", size: 0.9em, p.name)),
  )
  let header-cells = participants.map(p => {
    if p.id in create-row {
      // Header is drawn inline at the create row; reserve space at the top.
      box(width: 100%, height: 100%)
    } else {
      render-header(p)
    }
  })

  // Phase divider: full-width horizontal line (drawn double-stroke for
  // scene-break feel) with the label centered on top in a surface-filled
  // pill so the line reads as cleanly broken by the text.
  let render-divider(label) = block(width: 100%, height: 100%, {
    let line-stroke = (paint: palettes.base.border-soft,
                       thickness: metrics.stroke-normal)
    let gap = 0.18em
    place(horizon + left, dy: -gap,
      line(length: 100%, stroke: line-stroke))
    place(horizon + left, dy: gap,
      line(length: 100%, stroke: line-stroke))
    if label != none and label != [] {
      place(horizon + center,
        box(fill: palettes.base.surface,
            inset: (x: 0.6em, y: 0.05em),
            text(size: 0.75em, weight: "bold", label)))
    }
  })

  // Time-passes delay marker: nest an inner grid with the same column
  // structure so vertical dots line up with each lifeline center, and
  // overlay an optional centered pill label that visually breaks the dots.
  let render-delay(label) = block(width: 100%, height: 100%, {
    place(horizon + left,
      grid(
        columns: (1fr,) * n,
        column-gutter: column-gap,
        ..range(n).map(_ => align(center,
          text(size: 1em, fill: palettes.base.text-muted, weight: "bold",
            "⋮")))))
    if label != none and label != [] {
      place(horizon + center,
        box(fill: palettes.base.surface,
            stroke: metrics.stroke-thin + palettes.base.border-soft,
            inset: (x: 0.6em, y: 0.05em),
            radius: 3pt,
            text(size: 0.7em, fill: palettes.base.text-muted, label)))
    }
  })

  // Alt-else branch separator: a thin dashed line at the row's top edge
  // (continuous with the alt frame's dashed border) with the next branch's
  // condition shown as a UML guard `[cond]` at the top-left, on a surface-
  // filled tag so it reads as the new branch header.
  let render-alt-else(label) = block(width: 100%, height: 100%, {
    let line-stroke = (paint: palettes.base.border-soft,
                       thickness: metrics.stroke-thin, dash: "dashed")
    place(top + left, line(length: 100%, stroke: line-stroke))
    place(top + left,
      box(fill: palettes.base.surface,
          stroke: metrics.stroke-thin + palettes.base.border-soft,
          inset: (x: 0.4em, y: 0.1em),
          radius: (bottom-right: 3pt),
          text(size: 0.55em, fill: palettes.base.text-muted,
            if label != none and label != [] [\[else: #label\]] else [\[else\]])))
  })

  // Notes that ride outside the column grid (`note left` on the leftmost
  // participant, `note right` on the rightmost). Recorded here and rendered
  // in the side-margin overlays so they don't squash into the lifelines.
  let outside-left-notes = ()
  let outside-right-notes = ()
  let step-cells = ()
  for (step-idx, step) in render-steps.enumerate() {
    if step.type == "note" {
      let over = step.over
      let label = step.at("label", default: none)
      let cols = if type(over) == str {
        (id-to-col.at(over),)
      } else {
        over.map(id => id-to-col.at(id))
      }
      let mut-lo = calc.min(..cols)
      let mut-hi = calc.max(..cols)
      let side = step.at("side", default: none)
      let fill = step.at("fill", default: rgb("#FFF9C4"))
      let stroke-paint = step.at("stroke", default: rgb("#A88B00"))
      // `note left` on the leftmost lifeline (or `note right` on the
      // rightmost) needs to render OUTSIDE the column grid — PlantUML
      // floats it in the figure margin past the edge lifeline. Defer to
      // the side-note overlay below.
      // `note left` / `note right` (`side` set) always anchor on the
      // sender's lifeline regardless of where that lifeline sits, so we
      // route every side note through the absolute-positioned overlay
      // below. `note over X` (`side == none`) still flows through the grid
      // so it can span multiple columns.
      if side == "left" {
        outside-left-notes.push((
          row: step-idx, col: mut-lo,
          label: label, fill: fill, stroke: stroke-paint))
        for i in range(n) { step-cells.push([]) }
      } else if side == "right" {
        outside-right-notes.push((
          row: step-idx, col: mut-hi,
          label: label, fill: fill, stroke: stroke-paint))
        for i in range(n) { step-cells.push([]) }
      } else {
        let span = mut-hi - mut-lo + 1
        for i in range(mut-lo) { step-cells.push([]) }
        step-cells.push(grid.cell(colspan: span,
          render-note(label, fill: fill, stroke-paint: stroke-paint)))
        for i in range(mut-hi + 1, n) { step-cells.push([]) }
      }
    } else if step.type == "ref" {
      let over = step.over
      let label = step.at("label", default: none)
      let cols = if type(over) == str {
        (id-to-col.at(over),)
      } else {
        over.map(id => id-to-col.at(id))
      }
      let lo = calc.min(..cols)
      let hi = calc.max(..cols)
      let span = hi - lo + 1
      for i in range(lo) { step-cells.push([]) }
      step-cells.push(grid.cell(colspan: span, render-ref(label)))
      for i in range(hi + 1, n) { step-cells.push([]) }
    } else if step.type == "divider" {
      let label = step.at("label", default: none)
      step-cells.push(grid.cell(colspan: n, render-divider(label)))
    } else if step.type == "alt-else" {
      let label = step.at("label", default: none)
      step-cells.push(grid.cell(colspan: n, render-alt-else(label)))
    } else if step.type == "delay" {
      let label = step.at("label", default: none)
      step-cells.push(grid.cell(colspan: n, render-delay(label)))
    } else if step.type == "space" {
      step-cells.push(grid.cell(colspan: n, []))
    } else if step.type == "create" {
      let col = id-to-col.at(step.who)
      let p = participants.at(col)
      for i in range(n) {
        if i == col {
          step-cells.push(
            block(width: 100%, height: 100%,
              align(center + horizon,
                box(fill: p.fill,
                    stroke: 0.8pt + palettes.base.border,
                    radius: 3pt,
                    inset: (x: 0.6em, y: 0.3em),
                    text(weight: "bold", size: 0.85em, p.name)))))
        } else {
          step-cells.push([])
        }
      }
    } else if step.type == "destroy" {
      let col = id-to-col.at(step.who)
      for i in range(n) {
        if i == col {
          let size = 0.9em
          let stroke-style = (paint: palettes.base.border,
                              thickness: metrics.stroke-normal)
          step-cells.push(block(width: 100%, height: 100%, {
            place(horizon + center,
              box(width: size, height: size, {
                place(top + left,
                  line(start: (0pt, 0pt), end: (size, size),
                       stroke: stroke-style))
                place(top + left,
                  line(start: (size, 0pt), end: (0pt, size),
                       stroke: stroke-style))
              }))
          }))
        } else {
          step-cells.push([])
        }
      }
    } else if step.type == "action" {
      let col = id-to-col.at(step.who)
      for i in range(n) {
        if i == col {
          let action-fill = step.at("fill", default: participants.at(col).fill.lighten(25%))
          step-cells.push(
            box(width: 100%, height: 100%,
                fill: action-fill,
                stroke: 0.5pt + palettes.base.border-soft,
                radius: 2pt, inset: (x: 0.4em, y: 0.3em),
                align(center + horizon,
                  text(size: 0.85em, step.label)))
          )
        } else {
          step-cells.push([])
        }
      }
    } else if step.type == "call" or step.type == "return" {
      let style = if step.type == "return" { "dashed" } else { "solid" }
      let default-head = if step.type == "return" { "v" } else { "filled" }
      let head = step.at("head", default: default-head)
      let raw-label = step.at("label", default: none)
      let num = step-numbers.at(step-idx, default: none)
      let label = if num != none {
        if raw-label == none or raw-label == [] {
          [*#(str(num) + ".")*]
        } else {
          [*#(str(num) + ".")* #raw-label]
        }
      } else {
        raw-label
      }
      let stroke-paint = step.at("stroke", default: palettes.base.border)

      if is-edge(step.from) or is-edge(step.to) {
        // Boundary arrow — line spans from a figure edge to a participant
        // column center (or the reverse). Layout-resolved so column centers
        // align with the same 1fr columns used by the outer grid.
        let real-id = if is-edge(step.from) { step.to } else { step.from }
        let real-col = id-to-col.at(real-id)
        let from-edge = is-edge(step.from)
        let real-active = is-active(real-col, step-idx)
        step-cells.push(grid.cell(colspan: n,
          layout(size => block(width: 100%, height: 100%, {
            let w = size.width
            let col-w = (w - (n - 1) * column-gap) / n
            let real-cx = real-col * (col-w + column-gap) + col-w / 2
            let act-shift = activation-width / 2

            let direction = if from-edge {
              if step.from == "[" { "right" } else { "left" }
            } else {
              if step.to == "]" { "right" } else { "left" }
            }
            let edge-x = if (from-edge and step.from == "[") or (not from-edge and step.to == "[") {
              0pt
            } else {
              w
            }
            // Inset from the participant side so the line attaches to the
            // activation strip's outer edge rather than the lifeline center.
            let real-edge-x = if real-active {
              if real-cx < edge-x { real-cx + act-shift }
              else { real-cx - act-shift }
            } else { real-cx }

            let lo-x = calc.min(edge-x, real-edge-x)
            let hi-x = calc.max(edge-x, real-edge-x)
            let line-stroke = (paint: stroke-paint,
                               thickness: metrics.stroke-normal,
                               dash: if style == "solid" { none } else { "dashed" })

            if label != none {
              place(horizon + left, dx: lo-x, dy: -0.6 * em,
                block(width: hi-x - lo-x, align(center + horizon,
                  text(size: 0.65em, fill: palettes.base.text-muted, label))))
            }
            place(horizon + left, dx: lo-x,
              line(length: hi-x - lo-x, stroke: line-stroke))
            // Arrowhead at the "to" end.
            let to-x = if from-edge { real-edge-x } else { edge-x }
            let head-anchor-x = if direction == "right" {
              to-x - head-size
            } else {
              to-x
            }
            place(horizon + left, dx: head-anchor-x,
              render-head(head, stroke-paint, direction))
          }))))
        continue
      }

      let from-col = id-to-col.at(step.from)
      let to-col = id-to-col.at(step.to)

      if from-col == to-col {
        // Self-message: either a U-shaped call or a short return line.
        let col = from-col
        let depth = self-step-depth.at(str(step-idx) + ":" + step.from, default: 1)
        for i in range(col) { step-cells.push([]) }
        if step.type == "call" {
          step-cells.push(self-call-arrow(
            label: label, stroke-paint: stroke-paint, depth: depth))
        } else {
          // self-return: find the depth of the activation being closed.
          // The return closes the innermost open self-call, so its depth
          // is one more than the remaining stack length after popping.
          // We look up the matching activation to get its depth.
          let ret-depth = {
            let d = 1
            for a in activations {
              if a.col == col and a.end == step-idx and a.depth > 0 {
                d = a.depth
              }
            }
            d
          }
          step-cells.push(self-return-arrow(
            label: label, stroke-paint: stroke-paint, depth: ret-depth))
        }
        for i in range(col + 1, n) { step-cells.push([]) }
      } else {
        let lo = calc.min(from-col, to-col)
        let hi = calc.max(from-col, to-col)
        let direction = if to-col > from-col { "right" } else { "left" }
        let span = hi - lo + 1
        for i in range(lo) { step-cells.push([]) }
        step-cells.push(grid.cell(colspan: span,
          message-line(label: label, direction: direction, style: style,
                       head: head, stroke-paint: stroke-paint, span: span,
                       lo-active: is-active(lo, step-idx),
                       hi-active: is-active(hi, step-idx))))
        for i in range(hi + 1, n) { step-cells.push([]) }
      }
    }
  }

  // Vertical dashed lifelines through each participant column center,
  // sitting flush under the headers and extending the full body height —
  // unless the participant is destroyed, in which case the lifeline ends
  // at the destroy row's vertical center.
  let lifeline-stroke = (paint: palettes.base.border-subtle,
                         thickness: metrics.stroke-thin, dash: "dashed")
  let lifeline-cells = range(n).map(col-i => {
    let id = participants.at(col-i).id
    let start-y = if id in create-row {
      create-row.at(id) * row-h + step-height / 2
    } else {
      0pt
    }
    let end-y = if id in destroy-row {
      destroy-row.at(id) * row-h + step-height / 2
    } else {
      body-height
    }
    let len = calc.max(end-y - start-y, 0pt)
    box(width: 100%, height: body-height,
      place(top + center, dy: start-y,
        line(angle: 90deg, length: len, stroke: lifeline-stroke)))
  })
  let lifelines = grid(
    columns: (1fr,) * n,
    column-gutter: column-gap,
    ..lifeline-cells,
  )

  // Activation rectangles.
  //
  // depth 0 — "base" activation, centered on the lifeline.
  // depth d (d ≥ 1) — nested self-call activation, shifted right by
  //   d × nested-offset from the base position.  With nested-offset =
  //   activation-width / 2 the offset rect overlaps the parent by half
  //   its width, which is the standard UML convention.
  let activation-cells = range(n).map(col-i => {
    let col-acts = activations.filter(a => a.col == col-i)
    if col-acts.len() == 0 { return [] }
    let p-fill = participants.at(col-i).fill
    let act-fill = p-fill.lighten(35%)
    let act-stroke = metrics.stroke-thin + p-fill.darken(20%)
    align(center, box(width: 100%, height: body-height, {
      // Draw depth 0 first (behind), then higher depths on top.
      let sorted = col-acts.sorted(key: a => a.depth)
      for act in sorted {
        let (y-top, h) = if act.depth == 0 {
          // Base activation: top/bottom edges follow the y-position where
          // the opening/closing arrow touches the lifeline-side rect edge —
          // 0.5 for cross-participant arrows (horizon), 0.25/0.75 for self-
          // call/self-return U-shapes that exit/arrive at the rect edge.
          let top-y = act.at("top-y", default: 0.5)
          let bot-y = act.at("bot-y", default: 0.5)
          let yt = act.start * row-h + step-height * top-y
          let yb = act.end * row-h + step-height * bot-y
          (yt, yb - yt)
        } else {
          // Nested self-call activation: top aligns with the self-call
          // arrow arrival point, bottom aligns with the self-return arrow
          // departure point. For a single-row self-call (start == end with
          // no explicit return) those formulas invert, so fall back to a
          // fixed extent within the row that overlaps the wrapping base.
          if act.start == act.end {
            let yt = act.start * row-h + step-height * 0.5
            let yb = act.start * row-h + step-height * 0.75
            (yt, yb - yt)
          } else {
            let yt = act.start * row-h + step-height * 0.75
            let yb = act.end * row-h + step-height * 0.5
            (yt, yb - yt)
          }
        }
        let x = 50% - activation-width / 2 + act.depth * nested-offset
        let fill = p-fill.lighten(calc.max(0%, 35% - act.depth * 20%))
        place(top + left, dx: x, dy: y-top,
          box(width: activation-width, height: h,
              fill: fill, stroke: act-stroke))
      }
    }))
  })
  let activation-overlay = grid(
    columns: (1fr,) * n,
    column-gutter: column-gap,
    ..activation-cells,
  )

  let header-row = grid(
    columns: (1fr,) * n,
    rows: header-height,
    column-gutter: column-gap,
    ..header-cells,
  )

  // Resolve participant boxes: each entry { name, ids, fill? } draws a tinted
  // backdrop spanning the listed participants' header columns with a small
  // title bar above. Ids must be contiguous in the final column order.
  let resolved-boxes = ()
  if boxes != none {
    for b in boxes {
      let box-ids = b.at("ids", default: ())
      if box-ids.len() == 0 { continue }
      let cols = box-ids.map(id => {
        if not (id in id-to-col) {
          panic("seq-lane boxes: participant `" + id + "` not declared.")
        }
        id-to-col.at(id)
      })
      let lo = calc.min(..cols)
      let hi = calc.max(..cols)
      if hi - lo + 1 != box-ids.len() {
        panic(
          "seq-lane boxes: participants in `" + b.at("name", default: "<box>")
          + "` must be contiguous in column order.",
        )
      }
      resolved-boxes.push((
        name: b.at("name", default: ""),
        lo: lo, hi: hi,
        fill: b.at("fill", default: palettes.base.surface-alt),
      ))
    }
  }
  // Box title bar above the participant headers when any box is present;
  // PlantUML treats the box as a swim-lane that vertically encloses both
  // headers AND lifelines, so the actual rectangle is drawn in the final
  // composition spanning the full header+body height.
  let box-title-h = if resolved-boxes.len() > 0 { 1.9 * em } else { 0pt }

  // Breathing room between participant headers and the body content.  Without
  // it, a fragment frame that starts at row 0 sits flush against the header
  // bar (its top edge is at y=0 of the body); cross-participant arrows are
  // at the row's horizon center so they have natural half-row whitespace,
  // but fragment frames extend to the row top.
  let body-pad-top = 0.4 * em

  // Fragment frames: dashed border around a range of step rows with a small
  // corner tag (kind name) and an optional condition label in brackets.
  // Per-depth horizontal indent so nested fragments visibly sit inside
  // their parents instead of overlapping at full body width.
  let frag-indent-step = 0.5 * em
  let fragment-overlay = block(width: 100%, height: body-height, {
    for frag in fragments {
      let y-top = frag.start * row-h
      let y-bot = (frag.end + 1) * row-h - row-gap
      let frame-h = y-bot - y-top
      let depth = frag.at("depth", default: 0)
      let dx-inset = depth * frag-indent-step
      let frame-w = 100% - 2 * dx-inset
      place(top + left, dx: dx-inset, dy: y-top,
        box(width: frame-w, height: frame-h,
            stroke: (paint: palettes.base.border-soft,
                     thickness: metrics.stroke-thin, dash: "dashed")))
      // Corner tag: a single filled label in the top-left bundling the
      // operator name and — if present — the UML guard condition. Merging
      // them into one box matches PlantUML/Mermaid convention so "alt [ok]"
      // reads as one semantic unit instead of two disconnected pieces
      // floating on the top border. Brackets are kept because they're the
      // UML guard notation.
      //
      // `group` is special-cased: PlantUML uses the user-supplied label as
      // the entire header (no "GROUP" prefix), so we drop the kind name and
      // render the label without brackets when present.
      place(top + left, dx: dx-inset, dy: y-top,
        box(fill: palettes.base.surface,
            stroke: metrics.stroke-thin + palettes.base.border-soft,
            inset: (x: 0.4em, y: 0.1em),
            radius: (bottom-right: 3pt),
            {
              if frag.kind == "group" {
                if frag.label != none {
                  text(size: 0.55em, weight: "bold", frag.label)
                } else {
                  text(size: 0.55em, weight: "bold", "GROUP")
                }
              } else {
                text(size: 0.55em, weight: "bold", upper(frag.kind))
                if frag.label != none {
                  h(0.4em)
                  text(size: 0.55em, fill: palettes.base.text-muted,
                    [\[#frag.label\]])
                }
              }
            }))
    }
  })

  let body-overlay = box(width: 100%, height: body-height, {
    place(top + left, lifelines)
    place(top + left, activation-overlay)
    place(top + left, fragment-overlay)
    place(top + left,
      grid(
        columns: (1fr,) * n,
        rows: (step-height,) * render-steps.len(),
        column-gutter: column-gap,
        row-gutter: row-gap,
        ..step-cells,
      ))
  })

  // Side-margin notes: rendered as an absolute-positioned overlay over the
  // composed body so the note's inner edge lands just past the sender's
  // activation rectangle (which sits centered on the lifeline), clearing
  // the rect with a small visual gap.
  let any-left = outside-left-notes.len() > 0
  let any-right = outside-right-notes.len() > 0
  let side-note-width = 8 * em
  // Half the activation strip plus a small breathing gap, so notes never
  // touch the focus-of-control rectangle even if the sender is currently
  // active at that row.
  let side-note-gap = activation-width / 2 + 0.3 * em

  let composed = if resolved-boxes.len() == 0 {
    let main-stack = stack(dir: ttb, spacing: 0pt,
      header-row, v(body-pad-top), body-overlay)
    if any-left or any-right {
      let header-y = header-height + body-pad-top
      let total-h = header-height + body-pad-top + body-height
      layout(size => {
        let w = size.width
        let col-w = (w - (n - 1) * column-gap) / n
        block(width: w, height: total-h, {
          place(top + left, main-stack)
          for note in outside-left-notes {
            let lifeline-x = note.col * (col-w + column-gap) + col-w / 2
            // Note's right edge sits just left of the activation strip;
            // left edge overflows when the column is narrower than the note.
            let dx = lifeline-x - side-note-gap - side-note-width
            place(top + left, dx: dx, dy: header-y + note.row * row-h,
              box(width: side-note-width, height: step-height,
                align(horizon,
                  render-note(note.label, fill: note.fill, stroke-paint: note.stroke))))
          }
          for note in outside-right-notes {
            let lifeline-x = note.col * (col-w + column-gap) + col-w / 2
            // Note's left edge sits just right of the activation strip;
            // right edge overflows past the body's right edge when needed.
            place(top + left, dx: lifeline-x + side-note-gap, dy: header-y + note.row * row-h,
              box(width: side-note-width, height: step-height,
                align(horizon,
                  render-note(note.label, fill: note.fill, stroke-paint: note.stroke))))
          }
        })
      })
    } else { main-stack }
  } else {
    // Boxes are full-height swim lanes: draw a single tinted rectangle
    // running from the title bar at the top to the bottom of the body, with
    // the title text in the bar above the headers. Headers and body are then
    // overlaid on top.
    let total-h = box-title-h + header-height + body-pad-top + body-height
    layout(size => {
      let w = size.width
      let col-w = (w - (n - 1) * column-gap) / n
      block(width: 100%, height: total-h, {
        for b in resolved-boxes {
          let x-left = b.lo * (col-w + column-gap)
          let span-w = (b.hi - b.lo + 1) * col-w + (b.hi - b.lo) * column-gap
          let pad = 0.4 * em
          place(top + left, dx: x-left - pad,
            rect(width: span-w + 2 * pad, height: total-h,
                 fill: b.fill,
                 stroke: metrics.stroke-thin + palettes.base.border-soft,
                 radius: 4pt))
          if b.name != "" and b.name != [] {
            place(top + left, dx: x-left - pad, dy: 0.5 * em,
              block(width: span-w + 2 * pad,
                align(center, text(size: 0.85em, weight: "bold",
                  fill: palettes.base.text, b.name))))
          }
        }
        place(top + left, dy: box-title-h, header-row)
        place(top + left, dy: box-title-h + header-height + body-pad-top,
              body-overlay)
      })
    })
  }
  block(width: total-width, breakable: false, composed)
}
