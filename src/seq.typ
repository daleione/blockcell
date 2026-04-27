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
/// - `seq-alt(condition, ..steps)`   alt fragment with bracketed condition
/// - `seq-opt(condition, ..steps)`   opt fragment
/// - `seq-loop(condition, ..steps)`  loop fragment
/// - `seq-par(condition, ..steps)`   par fragment
#let seq-call(from, to, body) = (
  type: "call", from: from, to: to, label: body,
)
#let seq-ret(from, to, body) = (
  type: "return", from: from, to: to, label: body,
)
#let seq-note(over, body) = (
  type: "note", over: over, label: body,
)
#let seq-act(who, body) = (
  type: "action", who: who, label: body,
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
  participants: none,
  ..steps,
) = context {
  let em = 1em.to-absolute()
  let head-size = metrics.head-size.to-absolute()
  let step-height = step-height.to-absolute()
  let row-gap = row-gap.to-absolute()
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
  let cat = palettes.categorical
  let auto-ids = ()
  let auto-seen = (:)
  for step in raw-steps {
    let candidates = ()
    let f = step.at("from", default: none)
    if f != none { candidates.push(f) }
    let t = step.at("to", default: none)
    if t != none { candidates.push(t) }
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
    let used-ids = auto-ids.fold((:), (acc, id) => {
      acc.insert(id, true)
      acc
    })
    let seen-user-ids = (:)
    for p in participants {
      if not ("id" in p) {
        panic("seq-lane participants entries must include `id`.")
      }
      if p.id in seen-user-ids {
        panic("seq-lane participants contains duplicate id `" + p.id + "`.")
      }
      seen-user-ids.insert(p.id, true)
      if not (p.id in used-ids) {
        panic("seq-lane participants contains unused id `" + p.id + "`. Remove it or reference it from a step.")
      }
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
  let render-steps = ()
  let fragments = ()
  let frag-stack = ()
  for step in steps {
    if step.type == "fragment-start" {
      frag-stack.push((
        start: render-steps.len(),
        kind: step.at("kind", default: "alt"),
        label: step.at("label", default: none),
      ))
    } else if step.type == "fragment-end" {
      if frag-stack.len() > 0 {
        let frag = frag-stack.pop()
        fragments.push((
          start: frag.start,
          end: calc.max(render-steps.len() - 1, frag.start),
          kind: frag.kind,
          label: frag.label,
        ))
      }
    } else {
      render-steps.push(step)
    }
  }
  for frag in frag-stack {
    fragments.push((
      start: frag.start,
      end: calc.max(render-steps.len() - 1, frag.start),
      kind: frag.kind,
      label: frag.label,
    ))
  }

  let body-height = step-height * render-steps.len() + row-gap * calc.max(render-steps.len() - 1, 0)

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

    // Self-call nesting tracking: a stack per participant of open self-call
    // start indices.  Stack length = current nesting depth above the base.
    let self-stack = (:)  // id -> array of start step indices

    for (i, step) in render-steps.enumerate() {
      if step.type == "call" {
        if step.from == step.to {
          // Self-call: open a nested activation rectangle.
          let stack = self-stack.at(step.from, default: ())
          let depth = stack.len() + 1  // depth 1 for first self-call
          self-step-depth.insert(str(i) + ":" + step.from, depth)
          stack.push(i)
          self-stack.insert(step.from, stack)
        } else {
          // Cross-participant call: open base activation on sender if needed.
          if base-open.at(step.from, default: none) == none {
            base-open.insert(step.from, i)
          }
          // Open base activation on receiver if needed.
          if base-open.at(step.to, default: none) == none {
            base-open.insert(step.to, i)
          }
        }
      } else if step.type == "return" {
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
        } else {
          // Closes a base activation.
          let start = base-open.at(step.from, default: none)
          if start != none {
            activations.push((
              col: id-to-col.at(step.from),
              start: start,
              end: i,
              depth: 0,
            ))
            base-open.insert(step.from, none)
          }
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
        activations.push((
          col: id-to-col.at(id),
          start: start,
          end: render-steps.len() - 1,
          depth: 0,
        ))
      }
    }
  }

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
  //   filled triangle  ▶  — synchronous call
  //   open V (two strokes) — return (no fill so dashed line + sharp head reads
  //                          as "answer" rather than "request")
  // Each returns a content sized head-size × head-size with the tip on the
  // appropriate side, so the caller only has to position the bounding box.
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
  let render-head(kind, paint, dir) = if kind == "v" {
    head-v(paint, dir)
  } else {
    head-filled(paint, dir)
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
    block(width: 100%, height: 100%, {
      if label != none {
        place(horizon + center, dy: -0.6 * em,
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

  let header-cells = participants.map(p =>
    box(
      width: 100%, height: 100%,
      fill: p.fill, stroke: 0.8pt + palettes.base.border,
      radius: 3pt, inset: (x: 0.6em, y: 0.4em),
      align(center + horizon, text(weight: "bold", size: 0.9em, p.name)),
    )
  )

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
      let lo = calc.min(..cols)
      let hi = calc.max(..cols)
      let span = hi - lo + 1
      let fill = step.at("fill", default: rgb("#FFF9C4"))
      let stroke-paint = step.at("stroke", default: rgb("#A88B00"))
      for i in range(lo) { step-cells.push([]) }
      step-cells.push(grid.cell(colspan: span,
        render-note(label, fill: fill, stroke-paint: stroke-paint)))
      for i in range(hi + 1, n) { step-cells.push([]) }
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
      let from-col = id-to-col.at(step.from)
      let to-col = id-to-col.at(step.to)
      let style = if step.type == "return" { "dashed" } else { "solid" }
      let head = if step.type == "return" { "v" } else { "filled" }
      let label = step.at("label", default: none)
      let stroke-paint = step.at("stroke", default: palettes.base.border)

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
  // sitting flush under the headers and extending the full body height.
  let lifelines = grid(
    columns: (1fr,) * n,
    column-gutter: column-gap,
    ..range(n).map(_ =>
      align(center,
        line(angle: 90deg, length: body-height,
             stroke: (paint: palettes.base.border-subtle,
                      thickness: metrics.stroke-thin, dash: "dashed"))))
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
          // Base activation: centered vertically on the call/return steps.
          let yt = act.start * row-h + step-height / 2
          (yt, (act.end - act.start) * row-h)
        } else {
          // Nested self-call activation: top aligns with the self-call
          // arrow arrival point, bottom aligns with the self-return arrow
          // departure point.
          let yt = act.start * row-h + step-height * 0.75
          let yb = act.end * row-h + step-height * 0.5
          (yt, yb - yt)
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

  // Fragment frames: dashed border around a range of step rows with a small
  // corner tag (kind name) and an optional condition label in brackets.
  let fragment-overlay = block(width: 100%, height: body-height, {
    for frag in fragments {
      let y-top = frag.start * row-h
      let y-bot = (frag.end + 1) * row-h - row-gap
      let frame-h = y-bot - y-top
      place(top + left, dy: y-top,
        box(width: 100%, height: frame-h,
            stroke: (paint: palettes.base.border-soft,
                     thickness: metrics.stroke-thin, dash: "dashed")))
      // Corner tag: a single filled label in the top-left bundling the
      // operator name and — if present — the UML guard condition. Merging
      // them into one box matches PlantUML/Mermaid convention so "alt [ok]"
      // reads as one semantic unit instead of two disconnected pieces
      // floating on the top border. Brackets are kept because they're the
      // UML guard notation.
      place(top + left, dy: y-top,
        box(fill: palettes.base.surface,
            stroke: metrics.stroke-thin + palettes.base.border-soft,
            inset: (x: 0.4em, y: 0.1em),
            radius: (bottom-right: 3pt),
            {
              text(size: 0.55em, weight: "bold", upper(frag.kind))
              if frag.label != none {
                h(0.4em)
                text(size: 0.55em, fill: palettes.base.text-muted,
                  [\[#frag.label\]])
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

  block(width: total-width, breakable: false,
    stack(dir: ttb, spacing: 0pt, header-row, body-overlay))
}
