// ============================================================================
// seq-puml — PlantUML sequence diagram compatibility layer (P0)
// ============================================================================
//
// Parses a subset of PlantUML sequence diagram text and converts it to
// `seq-lane` + `seq-call/ret/note/…` calls.  Pure Typst — no external deps.
//
// Supported P0 syntax:
//   participant/actor/database/entity/… declarations
//   A -> B : label          synchronous call
//   A --> B : label         return
//   A -> A : label          self-call
//   alt/else/end  opt/end  loop/end  par/end
//   note over A : text      (single-participant)
//   note over A, B : text   (spanning)
//   multi-line note … end note
//   == divider ==
//   -[#color]> arrow coloring
//   #color on participant
//   @startuml / @enduml / comments skipped
// ============================================================================

#import "seq.typ": seq-lane, seq-call, seq-ret, seq-note, seq-act, seq-alt, seq-opt, seq-loop, seq-par
#import "palettes.typ": palettes

// ---- Helpers ---------------------------------------------------------------

// Try to parse a PlantUML color value to a Typst color.
// Supports: #RGB, #RRGGBB, and a small set of named colors.
#let _parse-color(raw) = {
  if raw == none { return none }
  let s = raw.trim()
  if s == "" { return none }

  let hex = if s.starts-with("#") { s.slice(1) } else { s }

  let names = (
    "red":        rgb("#FF0000"),
    "blue":       rgb("#0000FF"),
    "green":      rgb("#008000"),
    "yellow":     rgb("#FFFF00"),
    "orange":     rgb("#FFA500"),
    "purple":     rgb("#800080"),
    "pink":       rgb("#FFC0CB"),
    "black":      rgb("#000000"),
    "white":      rgb("#FFFFFF"),
    "gray":       rgb("#808080"),
    "grey":       rgb("#808080"),
    "lightblue":  rgb("#ADD8E6"),
    "lightgreen": rgb("#90EE90"),
    "lightyellow": rgb("#FFFFE0"),
    "lightgray":  rgb("#D3D3D3"),
    "lightgrey":  rgb("#D3D3D3"),
    "darkblue":   rgb("#00008B"),
    "darkgreen":  rgb("#006400"),
    "darkred":    rgb("#8B0000"),
    "gold":       rgb("#FFD700"),
    "cyan":       rgb("#00FFFF"),
    "magenta":    rgb("#FF00FF"),
    "aqua":       rgb("#00FFFF"),
    "coral":      rgb("#FF7F50"),
    "salmon":     rgb("#FA8072"),
    "tomato":     rgb("#FF6347"),
    "skyblue":    rgb("#87CEEB"),
    "plum":       rgb("#DDA0DD"),
    "wheat":      rgb("#F5DEB3"),
    "ivory":      rgb("#FFFFF0"),
    "lavender":   rgb("#E6E6FA"),
    "linen":      rgb("#FAF0E6"),
  )

  let lower-hex = lower(hex)
  if lower-hex in names {
    return names.at(lower-hex)
  }

  if hex.len() == 3 or hex.len() == 6 {
    return rgb("#" + hex)
  }

  none
}

// Remove surrounding quotes from a string if present.
#let _unquote(s) = {
  let t = s.trim()
  if t.len() >= 2 and t.starts-with("\"") and t.ends-with("\"") {
    t.slice(1, t.len() - 1)
  } else {
    t
  }
}

// ---- Participant keywords --------------------------------------------------

#let _participant-keywords = (
  "participant", "actor", "boundary", "control",
  "entity", "database", "collections", "queue",
)

// ---- Line parsers (pure functions, no side effects) ------------------------

// Attempt to parse a participant declaration line.
// Returns (id: str, name: str, fill: color|none) or none.
#let _parse-participant(line) = {
  let keyword = none
  let rest = none
  for kw in _participant-keywords {
    if line.starts-with(kw + " ") or line.starts-with(kw + "\t") {
      keyword = kw
      rest = line.slice(kw.len()).trim()
      break
    }
  }
  if keyword == none { return none }

  // Extract optional trailing color: #color at the end
  let fill = none
  let color-match = rest.match(regex("\s+(#\S+)\s*$"))
  if color-match != none {
    fill = _parse-color(color-match.captures.at(0))
    rest = rest.slice(0, color-match.start).trim()
  }

  // Extract optional `order N` at the end (ignore but strip)
  let order-match = rest.match(regex("(?i)\s+order\s+\d+\s*$"))
  if order-match != none {
    rest = rest.slice(0, order-match.start).trim()
  }

  // Pattern 1: "Long Name" as alias
  let m1 = rest.match(regex("^\"([^\"]+)\"\s+as\s+(\S+)$"))
  if m1 != none {
    return (id: m1.captures.at(1), name: m1.captures.at(0), fill: fill)
  }

  // Pattern 2: alias as "Long Name"
  let m2 = rest.match(regex("^(\S+)\s+as\s+\"([^\"]+)\"$"))
  if m2 != none {
    return (id: m2.captures.at(0), name: m2.captures.at(1), fill: fill)
  }

  // Pattern 3: just a name (possibly quoted)
  let name = _unquote(rest)
  let id-m = name.match(regex("^\S+"))
  if id-m == none { return none }
  return (id: id-m.text, name: name, fill: fill)
}

// Attempt to parse a message arrow line.
// Returns (from, to, type, label, stroke, suffix) or none.
#let _parse-message(line) = {
  let m = line.match(regex(
    "^(\S+)\s+" +
    "([<]?[ox]?)" +
    "(-+)" +
    "(?:\\[([^\\]]+)\\])?" +
    "(-*)" +
    "([>]{0,2}[ox]?[/\\\\]{0,2})" +
    "\s+" +
    "(\S+)" +
    "\s*" +
    "([+\\-*!]{0,2})" +
    "(?:\s*:\s*(.*))?" +
    "$"
  ))
  if m == none { return none }

  let from = m.captures.at(0)
  let left-head = m.captures.at(1)
  let dashes1 = m.captures.at(2)
  let color-raw = m.captures.at(3)
  let dashes2 = m.captures.at(4)
  let right-head = m.captures.at(5)
  let to = m.captures.at(6)
  let suffix = m.captures.at(7)
  let label-text = m.captures.at(8)

  let total-dashes = dashes1.len() + dashes2.len()
  let is-dashed = total-dashes >= 2
  let is-reversed = left-head.contains("<") and not right-head.contains(">")

  let actual-from = if is-reversed { to } else { from }
  let actual-to = if is-reversed { from } else { to }
  let stroke-color = _parse-color(color-raw)
  let msg-type = if is-dashed { "return" } else { "call" }
  let label = if label-text != none { label-text.trim() } else { "" }

  (
    from: actual-from,
    to: actual-to,
    type: msg-type,
    label: label,
    stroke: stroke-color,
    suffix: if suffix != none { suffix } else { "" },
  )
}

// Attempt to parse a note line.
// Returns (type: "note-start"|"note-single", over, label) or none.
#let _parse-note(line) = {
  // Single-line: note over A : text  /  note over A, B : text
  let m1 = line.match(regex(
    "^(?:r?h?)note\s+over\s+" +
    "([^:,]+(?:\s*,\s*[^:,]+)?)" +
    "\s*:\s*(.+)$"
  ))
  if m1 != none {
    let over-raw = m1.captures.at(0).trim()
    let label = m1.captures.at(1).trim()
    let over = if over-raw.contains(",") {
      let parts = over-raw.split(",").map(s => s.trim())
      (parts.at(0), parts.at(1))
    } else {
      over-raw
    }
    return (type: "note-single", over: over, label: label)
  }

  // note across : text
  let m1b = line.match(regex("^(?:r?h?)note\s+across\s*:\s*(.+)$"))
  if m1b != none {
    return (type: "note-single", over: "across", label: m1b.captures.at(0).trim())
  }

  // Multi-line start: note over A  (no colon)
  let m2 = line.match(regex(
    "^(?:r?h?)note\s+over\s+" +
    "([^:]+?)\s*$"
  ))
  if m2 != none {
    let over-raw = m2.captures.at(0).trim()
    let over = if over-raw.contains(",") {
      let parts = over-raw.split(",").map(s => s.trim())
      (parts.at(0), parts.at(1))
    } else {
      over-raw
    }
    return (type: "note-start", over: over, label: "")
  }

  // note left : text  /  note right : text
  let m3 = line.match(regex("^(?:r?h?)note\s+(?:left|right)\s*:\s*(.+)$"))
  if m3 != none {
    return (type: "note-single", over: "__last__", label: m3.captures.at(0).trim())
  }

  // Multi-line: note left / note right (no colon)
  let m4 = line.match(regex("^(?:r?h?)note\s+(?:left|right)\s*$"))
  if m4 != none {
    return (type: "note-start", over: "__last__", label: "")
  }

  none
}

// Attempt to parse a fragment start line.
#let _parse-fragment-start(line) = {
  let m = line.match(regex(
    "^(alt|opt|loop|par|group|break|critical)" +
    "(?:\\s+(.*))?$"
  ))
  if m == none { return none }
  let kind = m.captures.at(0)
  let label = if m.captures.at(1) != none { m.captures.at(1).trim() } else { "" }

  // Strip optional color prefixes: alt#Gold #LightBlue text
  let label2 = label.match(regex("^(?:#\S+\s+)*(.*)$"))
  if label2 != none {
    label = label2.captures.at(0).trim()
  }

  (kind: kind, label: label)
}

// Attempt to parse an `else` line inside alt.
#let _parse-else(line) = {
  let m = line.match(regex("^else(?:\s+(.*))?$"))
  if m == none { return none }
  let label = if m.captures.at(0) != none { m.captures.at(0).trim() } else { "" }
  let label2 = label.match(regex("^(?:#\S+\s+)?(.*)$"))
  if label2 != none {
    label = label2.captures.at(0).trim()
  }
  (label: label)
}

// Check for divider: == text ==
#let _parse-divider(line) = {
  let m = line.match(regex("^==\s*(.+?)\s*==$"))
  if m == none { return none }
  (label: m.captures.at(0).trim())
}

// ---- Recursive step converter ----------------------------------------------

// Resolve __divider__ notes to span first/last participant.
#let _resolve-dividers(step-list, seen-ids) = {
  step-list.map(s => {
    if s.type == "note" and s.over == "__divider__" {
      if seen-ids.len() >= 2 {
        (type: "note", over: (seen-ids.first(), seen-ids.last()), label: s.label)
      } else if seen-ids.len() == 1 {
        (type: "note", over: seen-ids.first(), label: s.label)
      } else {
        s
      }
    } else if s.type == "fragment" {
      let resolved = _resolve-dividers(s.children, seen-ids)
      (type: s.type, kind: s.kind, label: s.label, children: resolved)
    } else {
      s
    }
  })
}

// Convert a plain string to Typst content.
// We eval in markup mode directly — no wrapping in [...] brackets.
#let _str-to-content(s) = {
  if s == "" { return [] }
  eval(s, mode: "markup")
}

// Convert label strings to Typst content via eval.
#let _labels-to-content(step-list) = {
  step-list.map(s => {
    if s.type == "call" or s.type == "return" {
      let base = (
        type: s.type,
        from: s.from,
        to: s.to,
        label: _str-to-content(s.label),
      )
      if "stroke" in s and s.stroke != none {
        base.insert("stroke", s.stroke)
      }
      base
    } else if s.type == "note" {
      (
        type: "note",
        over: s.over,
        label: _str-to-content(s.label),
      )
    } else if s.type == "action" {
      (
        type: "action",
        who: s.who,
        label: _str-to-content(s.label),
      )
    } else if s.type == "fragment" {
      let children = _labels-to-content(s.children)
      (
        type: "fragment",
        kind: s.kind,
        label: _str-to-content(s.label),
        children: children,
      )
    } else {
      s
    }
  })
}

// ---- Main parser -----------------------------------------------------------

/// Parse PlantUML sequence diagram text and return a `seq-lane` content block.
///
/// Usage:
/// ```typst
/// #seq-puml(`
///   Alice -> Bob : hello
///   Bob --> Alice : world
/// `)
/// ```
///
/// Accepts a raw block (backtick-delimited) or a plain string.
/// All `seq-lane` parameters (width, step-height, etc.) can be passed through.
#let seq-puml(
  body,
  width: auto,
  step-height: 3em,
  header-height: 2.6em,
  column-gap: 1em,
  row-gap: 0.4em,
  activate: true,
  activation-width: 0.8em,
) = {
  // Extract text from raw block or string.
  let text = if type(body) == str { body } else { body.text }

  // Split into lines and preprocess.
  let lines = text.split("\n").map(l => l.trim())

  // ---- All mutable state lives in a single dict ----------------------------
  // Typst doesn't allow closures to mutate outer locals, so we thread a
  // state dict through the loop via reassignment.
  let st = (
    participants: (),     // array of (id:, name:, fill:)
    seen-ids: (),         // ordered list of participant IDs
    steps: (),            // top-level step list
    frag-stack: (),       // stack of {kind, label, children}
    note-state: none,     // none or {over, lines}
    last-from: none,      // last message sender
    last-to: none,        // last message receiver
    call-stack: (),       // for `return` keyword resolution
  )

  for line in lines {
    // ---- Skip noise ----
    if line == "" { continue }
    if line.starts-with("'") { continue }
    if line.starts-with("/'") { continue }
    if line.starts-with("@startuml") or line.starts-with("@enduml") { continue }
    if line.starts-with("hide ") or line.starts-with("skinparam ") { continue }
    if line.starts-with("autoactivate ") or line.starts-with("autonumber") { continue }
    if line.starts-with("title ") or line == "title" { continue }
    if line.starts-with("header ") or line.starts-with("footer ") { continue }
    if line.starts-with("mainframe ") { continue }
    if line.starts-with("newpage") { continue }

    // ---- Multi-line note state machine ----
    if st.note-state != none {
      if line == "end note" or line == "endnote" or line == "endrnote" or line == "endhnote" {
        let over = st.note-state.over
        let content = st.note-state.lines.join("\n")

        // Resolve __last__
        if over == "__last__" {
          if st.last-to != none { over = st.last-to }
          else if st.last-from != none { over = st.last-from }
        }

        let step = (type: "note", over: over, label: content)
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(step)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(step)
        }
        st.note-state = none
      } else {
        st.note-state.lines.push(line)
      }
      continue
    }

    // ---- Participant declaration ----
    let p = _parse-participant(line)
    if p != none {
      let found = false
      for (i, existing) in st.participants.enumerate() {
        if existing.id == p.id {
          st.participants.at(i).name = p.name
          if p.fill != none { st.participants.at(i).fill = p.fill }
          found = true
          break
        }
      }
      if not found {
        st.seen-ids.push(p.id)
        st.participants.push((id: p.id, name: p.name, fill: p.fill))
      }
      continue
    }

    // ---- create keyword (P0: skip, ensure participant) ----
    if line.starts-with("create ") {
      let id = line.slice(7).trim()
      if id not in st.seen-ids {
        st.seen-ids.push(id)
        st.participants.push((id: id, name: id, fill: none))
      }
      continue
    }

    // ---- Divider: == text == ----
    let dv = _parse-divider(line)
    if dv != none {
      let step = (type: "note", over: "__divider__", label: dv.label)
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      continue
    }

    // ---- Fragment start ----
    let fs = _parse-fragment-start(line)
    if fs != none {
      st.frag-stack.push((kind: fs.kind, label: fs.label, children: ()))
      continue
    }

    // ---- else (inside alt) ----
    let el = _parse-else(line)
    if el != none {
      if st.frag-stack.len() > 0 {
        let label = if el.label != "" { "[else: " + el.label + "]" } else { "[else]" }
        let top = st.frag-stack.last()
        top.children.push((type: "note", over: "__divider__", label: label))
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      }
      continue
    }

    // ---- end (close fragment) ----
    if line == "end" {
      if st.frag-stack.len() > 0 {
        let frag = st.frag-stack.pop()
        let kind = frag.kind

        let step = if kind == "alt" or kind == "opt" or kind == "loop" or kind == "par" {
          (type: "fragment", kind: kind, label: frag.label, children: frag.children)
        } else {
          // group, break, critical → map to alt as fallback with capitalized kind as prefix
          let prefix = upper(kind.slice(0, 1)) + kind.slice(1)
          let lbl = if frag.label != "" { prefix + " " + frag.label } else { prefix }
          (type: "fragment", kind: "alt", label: lbl, children: frag.children)
        }

        if st.frag-stack.len() > 0 {
          let parent = st.frag-stack.last()
          parent.children.push(step)
          st.frag-stack.at(st.frag-stack.len() - 1) = parent
        } else {
          st.steps.push(step)
        }
      }
      continue
    }

    // ---- Note ----
    let nt = _parse-note(line)
    if nt != none {
      if nt.type == "note-start" {
        st.note-state = (over: nt.over, lines: ())
      } else {
        let over = nt.over
        if over == "__last__" {
          if st.last-to != none { over = st.last-to }
          else if st.last-from != none { over = st.last-from }
        }
        if over == "across" {
          over = "__divider__"
        }
        let step = (type: "note", over: over, label: nt.label)
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(step)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(step)
        }
      }
      continue
    }

    // ---- activate / deactivate / destroy (skip in P0) ----
    if line.starts-with("activate ") or line.starts-with("deactivate ") or line.starts-with("destroy ") {
      continue
    }

    // ---- return keyword ----
    if line.starts-with("return") and (line.len() == 6 or line.at(6) == " ") {
      let label = if line.len() > 7 { line.slice(7).trim() } else { "" }
      if st.call-stack.len() > 0 {
        let caller = st.call-stack.pop()
        if st.last-to != none {
          let step = (type: "return", from: st.last-to, to: caller, label: label)
          if st.frag-stack.len() > 0 {
            let top = st.frag-stack.last()
            top.children.push(step)
            st.frag-stack.at(st.frag-stack.len() - 1) = top
          } else {
            st.steps.push(step)
          }
          st.last-from = st.last-to
          st.last-to = caller
        }
      }
      continue
    }

    // ---- Message arrow ----
    let msg = _parse-message(line)
    if msg != none {
      // Ensure participants exist
      if msg.from not in st.seen-ids {
        st.seen-ids.push(msg.from)
        st.participants.push((id: msg.from, name: msg.from, fill: none))
      }
      if msg.to not in st.seen-ids {
        st.seen-ids.push(msg.to)
        st.participants.push((id: msg.to, name: msg.to, fill: none))
      }

      let step = (
        type: msg.type,
        from: msg.from,
        to: msg.to,
        label: msg.label,
      )
      if msg.stroke != none {
        step.insert("stroke", msg.stroke)
      }

      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }

      st.last-from = msg.from
      st.last-to = msg.to
      if msg.type == "call" and msg.from != msg.to {
        st.call-stack.push(msg.from)
      }

      continue
    }

    // ---- Unrecognized line: skip silently (lenient mode) ----
  }

  // ---- Close any unclosed fragments ----
  while st.frag-stack.len() > 0 {
    let frag = st.frag-stack.pop()
    let step = (type: "fragment", kind: frag.kind, label: frag.label, children: frag.children)
    if st.frag-stack.len() > 0 {
      let parent = st.frag-stack.last()
      parent.children.push(step)
      st.frag-stack.at(st.frag-stack.len() - 1) = parent
    } else {
      st.steps.push(step)
    }
  }

  // ---- Post-process steps ----
  let steps = _resolve-dividers(st.steps, st.seen-ids)
  let steps = _labels-to-content(steps)

  // ---- Build final participant list ----
  let cat-colors = palettes.categorical
  let final-participants = st.participants.enumerate().map(((i, p)) => {
    let fill = if p.fill != none { p.fill } else { cat-colors.at(calc.rem(i, cat-colors.len())) }
    (id: p.id, name: _str-to-content(p.name), fill: fill)
  })

  // ---- Call seq-lane ----
  seq-lane(
    width: width,
    step-height: step-height,
    header-height: header-height,
    column-gap: column-gap,
    row-gap: row-gap,
    activate: activate,
    activation-width: activation-width,
    participants: final-participants,
    ..steps,
  )
}
