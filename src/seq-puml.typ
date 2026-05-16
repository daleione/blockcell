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

#import "seq.typ": seq-lane, seq-call, seq-ret, seq-note, seq-act, seq-ref, seq-divider, seq-else, seq-destroy, seq-create, seq-delay, seq-space, seq-autonumber, seq-autonumber-stop, seq-autonumber-resume, seq-alt, seq-opt, seq-loop, seq-par
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

// ---- Multi-line `participant Foo [ … ]` creole body ------------------------

// Convert one body line to a Typst-markup snippet. Returns `none` for blank
// lines so the caller can drop them.
//   `----` (3+ dashes) → horizontal rule
//   `""text""`         → raw / monospace
//   `=text`            → bold (PlantUML's header levels collapse to bold;
//                        Typst markup has no inline header tag)
//   anything else      → plain text
#let _puml-display-line(line) = {
  let l = line.trim()
  if l == "" { return none }
  if l.match(regex("^-{3,}$")) != none {
    return "#line(length: 100%, stroke: 0.5pt)"
  }
  let m-mono = l.match(regex("^\"\"(.+)\"\"$"))
  if m-mono != none {
    return "`" + m-mono.captures.at(0) + "`"
  }
  let m-h = l.match(regex("^=+\s*(.+)$"))
  if m-h != none {
    return "*" + m-h.captures.at(0) + "*"
  }
  l
}

// Join body lines into a single Typst-markup string. Separator depends on
// the content kind:
//   * all plain-text lines      → `\` (tight line break)
//   * any creole construct line → blank line (paragraph break) so the rule /
//                                 raw / heading reads as a block element
// Returns `(text: str, lines: int)` so the caller can grow `header-height`
// to fit.
#let _puml-display-block(lines) = {
  let parts = ()
  let any-block = false
  for line in lines {
    let snip = _puml-display-line(line)
    if snip == none { continue }
    if snip.starts-with("#") { any-block = true }
    parts.push(snip)
  }
  let joined = if any-block { parts.join("\n\n") } else { parts.join(" \\ ") }
  (text: joined, lines: parts.len())
}

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

// Translate the captured head modifier string into a head kind.
//
// The captured chunk for the right side is `[>]{0,2}[ox]?[/\\]{0,2}` and the
// left side mirrors it: any combination of `<`, `<<`, `o`, `x`, `\`, `/` may
// appear next to the dash run. PlantUML treats these as orthogonal:
//   `>>`      → thin / async open V
//   `>` alone → filled triangle (or open V if dashed return)
//   `o`       → open circle endpoint (replaces the head)
//   `x`       → × marker (replaces the head; lost message)
//   `\`       → only the upper diagonal of a V (half arrow)
//   `/`       → only the lower diagonal
//   nothing   → bare line (treat as default per direction)
//
// `is-dashed` lets a plain `>` map to "v" for return arrows so dashed `-->`
// keeps its existing visual.
#let _head-kind(modifier, is-dashed) = {
  if modifier.contains("x") { return "x" }
  if modifier.contains("o") { return "o" }
  if modifier.contains("\\") and not modifier.contains("/") {
    return "half-top"
  }
  if modifier.contains("/") and not modifier.contains("\\") {
    return "half-bottom"
  }
  let arrow-count = modifier.replace(regex("[^<>]"), "").len()
  if arrow-count >= 2 { return "v" }
  if arrow-count == 1 {
    if is-dashed { return "v" } else { return "filled" }
  }
  // No arrow character at all (e.g. `-x` had its `x` consumed by the
  // contains check above). Fall back to default per dashing.
  if is-dashed { return "v" } else { return "filled" }
}

// Attempt to parse a message arrow line.
// Returns (from, to, type, label, stroke, suffix, head) or none.
#let _parse-message(line) = {
  let m = line.match(regex(
    "^(\S+)\s+" +
    "([<]{0,2}[ox]?[/\\\\]{0,2})" +
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

  // The head we render lands on `to`. When the arrow is reversed (`<-`,
  // `<<-`, etc.), the modifiers on the left side describe that head.
  let outgoing-modifier = if is-reversed { left-head } else { right-head }
  let head-kind = _head-kind(outgoing-modifier, is-dashed)

  (
    from: actual-from,
    to: actual-to,
    type: msg-type,
    label: label,
    stroke: stroke-color,
    suffix: if suffix != none { suffix } else { "" },
    head: head-kind,
  )
}

// Boundary-arrow patterns where one endpoint is the figure edge:
//   `[-> A : label`    left edge enters A      (from = "[", to = A)
//   `[<- A : label`    A sends to left edge    (from = A, to = "[")
//   `A ->] : label`    A sends to right edge   (from = A, to = "]")
//   `A <-] : label`    right edge sends to A   (from = "]", to = A)
// Returns same shape as `_parse-message` but with one endpoint == "[" or "]".
#let _parse-boundary(line) = {
  let m1 = line.match(regex("^\[(-{1,2})>\s+(\S+)\s*(?::\s*(.*))?$"))
  if m1 != none {
    let dashes = m1.captures.at(0)
    let target = m1.captures.at(1).trim()
    let label = if m1.captures.at(2) != none { m1.captures.at(2).trim() } else { "" }
    return (
      from: "[", to: target,
      type: if dashes.len() == 2 { "return" } else { "call" },
      label: label, stroke: none, suffix: "",
    )
  }
  let m2 = line.match(regex("^\[<(-{1,2})\s+(\S+)\s*(?::\s*(.*))?$"))
  if m2 != none {
    let dashes = m2.captures.at(0)
    let target = m2.captures.at(1).trim()
    let label = if m2.captures.at(2) != none { m2.captures.at(2).trim() } else { "" }
    return (
      from: target, to: "[",
      type: if dashes.len() == 2 { "return" } else { "call" },
      label: label, stroke: none, suffix: "",
    )
  }
  let m3 = line.match(regex("^(\S+)\s+(-{1,2})>\]\s*(?::\s*(.*))?$"))
  if m3 != none {
    let source = m3.captures.at(0).trim()
    let dashes = m3.captures.at(1)
    let label = if m3.captures.at(2) != none { m3.captures.at(2).trim() } else { "" }
    return (
      from: source, to: "]",
      type: if dashes.len() == 2 { "return" } else { "call" },
      label: label, stroke: none, suffix: "",
    )
  }
  let m4 = line.match(regex("^(\S+)\s+<(-{1,2})\]\s*(?::\s*(.*))?$"))
  if m4 != none {
    let source = m4.captures.at(0).trim()
    let dashes = m4.captures.at(1)
    let label = if m4.captures.at(2) != none { m4.captures.at(2).trim() } else { "" }
    return (
      from: "]", to: source,
      type: if dashes.len() == 2 { "return" } else { "call" },
      label: label, stroke: none, suffix: "",
    )
  }
  none
}

// Attempt to parse a `ref over A[, B] : text` line.
// Returns (over, label) or none.
#let _parse-ref(line) = {
  let m = line.match(regex(
    "^ref\s+over\s+" +
    "([^:,]+(?:\s*,\s*[^:,]+)?)" +
    "\s*:\s*(.+)$"))
  if m == none { return none }
  let over-raw = m.captures.at(0).trim()
  let label = m.captures.at(1).trim()
  let over = if over-raw.contains(",") {
    let parts = over-raw.split(",").map(s => s.trim())
    (parts.at(0), parts.at(1))
  } else {
    over-raw
  }
  (over: over, label: label)
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
  let m3 = line.match(regex("^(?:r?h?)note\s+(left|right)\s*:\s*(.+)$"))
  if m3 != none {
    return (type: "note-single", over: "__last__",
            side: m3.captures.at(0),
            label: m3.captures.at(1).trim())
  }

  // Multi-line: note left / note right (no colon)
  let m4 = line.match(regex("^(?:r?h?)note\s+(left|right)\s*$"))
  if m4 != none {
    return (type: "note-start", over: "__last__",
            side: m4.captures.at(0), label: "")
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
// We eval in markup mode directly — no wrapping in [...] brackets. Literal
// `\n` in the source string is rewritten to Typst's markup line break
// (` \ `, backslash followed by space) so PlantUML labels like
// `Alice -> Bob : foo\nbar` render across two lines.
#let _str-to-content(s) = {
  if s == "" { return [] }
  let s = s.replace("\\n", " \\ ")
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
      if "head" in s and s.head != none {
        base.insert("head", s.head)
      }
      base
    } else if s.type == "note" {
      let base = (
        type: "note",
        over: s.over,
        label: _str-to-content(s.label),
      )
      // Preserve `side` (set by `note left` / `note right` after a message)
      // so the renderer can place the note in the correct margin.
      if "side" in s and s.side != none { base.insert("side", s.side) }
      base
    } else if s.type == "ref" {
      (
        type: "ref",
        over: s.over,
        label: _str-to-content(s.label),
      )
    } else if s.type == "action" {
      (
        type: "action",
        who: s.who,
        label: _str-to-content(s.label),
      )
    } else if s.type == "divider" {
      (
        type: "divider",
        label: _str-to-content(s.label),
      )
    } else if s.type == "alt-else" {
      (
        type: "alt-else",
        label: _str-to-content(s.label),
      )
    } else if s.type == "delay" {
      let lbl = if s.label == "" { none } else { _str-to-content(s.label) }
      (
        type: "delay",
        label: lbl,
      )
    } else if s.type == "fragment" {
      let children = _labels-to-content(s.children)
      let lbl = if s.label == "" { none } else { _str-to-content(s.label) }
      (
        type: "fragment",
        kind: s.kind,
        label: lbl,
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
  activate: auto,
  activation-width: 0.8em,
  message-align: "center",
  response-below: false,
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
    pblock-state: none,   // none or {id, lines} — accumulating a `participant Foo [ … ]` block
    pblock-max-lines: 1,  // max body-line count across all participants; drives header-height
    autoactivate-on: true,   // PlantUML strict default is off; we default on
                             // because zero-span auto-activations are filtered
                             // anyway, leaving only the meaningful spans.
    last-from: none,      // last message sender
    last-to: none,        // last message receiver
    call-stack: (),       // for `return` keyword resolution
    boxes: (),            // resolved (name, ids, fill) entries
    box-state: none,      // active `box ... end box` accumulator
    created-ids: (),      // ids for which a seq-create step has been emitted
  )

  for line in lines {
    // ---- Skip noise ----
    if line == "" { continue }
    if line.starts-with("'") { continue }
    if line.starts-with("/'") { continue }
    if line.starts-with("@startuml") or line.starts-with("@enduml") { continue }
    if line.starts-with("hide ") or line.starts-with("skinparam ") { continue }
    if line.starts-with("autoactivate ") {
      let arg = lower(line.slice("autoactivate ".len()).trim())
      st.autoactivate-on = (arg == "on" or arg == "yes" or arg == "true")
      continue
    }
    if line.starts-with("title ") or line == "title" { continue }
    if line.starts-with("header ") or line.starts-with("footer ") { continue }
    if line.starts-with("mainframe ") { continue }
    if line.starts-with("newpage") { continue }

    // ---- Multi-line participant block: `participant Foo [ … ]` ----
    if st.pblock-state != none {
      if line == "]" {
        let target-id = st.pblock-state.id
        let body = _puml-display-block(st.pblock-state.lines)
        for (i, existing) in st.participants.enumerate() {
          if existing.id == target-id {
            st.participants.at(i).name = body.text
            break
          }
        }
        if body.lines > st.pblock-max-lines {
          st.pblock-max-lines = body.lines
        }
        st.pblock-state = none
      } else {
        st.pblock-state.lines.push(line)
      }
      continue
    }

    // ---- Multi-line note state machine ----
    if st.note-state != none {
      if line == "end note" or line == "endnote" or line == "endrnote" or line == "endhnote" {
        let over = st.note-state.over
        let content = st.note-state.lines.join("\n")

        // Resolve __last__ to the SENDER of the previous message (left/right
        // sides are relative to the sender's lifeline, not the receiver's).
        if over == "__last__" {
          if st.last-from != none { over = st.last-from }
          else if st.last-to != none { over = st.last-to }
        }

        let step = (type: "note", over: over, label: content)
        let side = st.note-state.at("side", default: none)
        if side != none { step.insert("side", side) }
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

    // ---- box "Name" [#color] / end box ----
    if line == "end box" {
      if st.box-state != none {
        let b = (name: st.box-state.name, ids: st.box-state.ids)
        if st.box-state.fill != none {
          b.insert("fill", st.box-state.fill)
        }
        st.boxes.push(b)
        st.box-state = none
      }
      continue
    }
    let bm = line.match(regex("^box\s+(?:\"([^\"]+)\"|(\S+))(?:\s+(#\S+))?\s*$"))
    if bm != none {
      let name = if bm.captures.at(0) != none {
        bm.captures.at(0)
      } else {
        bm.captures.at(1)
      }
      let color-raw = bm.captures.at(2)
      let fill = if color-raw != none { _parse-color(color-raw) } else { none }
      st.box-state = (name: name, ids: (), fill: fill)
      continue
    }

    // ---- autonumber directive ----
    // Forms (PlantUML format string is ignored — engine uses `*N.*` prefix):
    //   autonumber                    start = 1, step = 1
    //   autonumber 5                  start = 5, step = 1
    //   autonumber 5 10               start = 5, step = 10
    //   autonumber stop               pause numbering
    //   autonumber resume [step]      resume; optional new step
    //
    // Each form emits a control step that the engine processes during the
    // render-step pre-pass, so puml and direct seq-lane usage share one
    // numbering implementation.
    if line.starts-with("autonumber") {
      let rest = line.slice("autonumber".len()).trim()
      let ctrl = none
      if rest == "" {
        ctrl = (type: "autonumber", action: "start", start: 1, step: 1)
      } else if rest == "stop" {
        ctrl = (type: "autonumber", action: "stop")
      } else if rest.starts-with("resume") {
        let after = rest.slice("resume".len()).trim()
        let m = after.match(regex("^(\d+)"))
        let s = if m != none { int(m.captures.at(0)) } else { none }
        ctrl = (type: "autonumber", action: "resume", step: s)
      } else {
        let m = rest.match(regex("^(\d+)(?:\s+(\d+))?"))
        if m != none {
          let start = int(m.captures.at(0))
          let step = if m.captures.at(1) != none {
            int(m.captures.at(1))
          } else { 1 }
          ctrl = (type: "autonumber", action: "start", start: start, step: step)
        }
      }
      if ctrl != none {
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(ctrl)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(ctrl)
        }
      }
      continue
    }

    // ---- Participant declaration (possibly opening a `[ … ]` body) ----
    let header-line = line
    let opens-pblock = false
    if line.ends-with("[") {
      let starts-pkw = false
      for kw in _participant-keywords {
        if line.starts-with(kw + " ") or line.starts-with(kw + "\t") {
          starts-pkw = true
          break
        }
      }
      if starts-pkw {
        header-line = line.slice(0, line.len() - 1).trim()
        opens-pblock = true
      }
    }
    let p = _parse-participant(header-line)
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
      // If we are inside an open `box ... end box`, record the participant.
      if st.box-state != none and not (p.id in st.box-state.ids) {
        st.box-state.ids.push(p.id)
      }
      if opens-pblock {
        st.pblock-state = (id: p.id, lines: ())
      }
      continue
    }

    // ---- create keyword: defer the participant's header to this row ----
    if line.starts-with("create ") {
      let id = line.slice(7).trim()
      if id not in st.seen-ids {
        st.seen-ids.push(id)
        st.participants.push((id: id, name: id, fill: none))
      }
      if not (id in st.created-ids) {
        st.created-ids.push(id)
        let cstep = (type: "create", who: id)
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(cstep)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(cstep)
        }
      }
      continue
    }

    // ---- Divider: == text == ----
    let dv = _parse-divider(line)
    if dv != none {
      let step = (type: "divider", label: dv.label)
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      continue
    }

    // ---- Space: `|||` or `||N||` (N currently ignored — always one row) ----
    let is-space = line.match(regex("^\|\|\|$")) != none or line.match(regex("^\|\|\d+\|\|$")) != none
    if is-space {
      let step = (type: "space")
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      continue
    }

    // ---- Delay: `...` or `...label...` ----
    if line == "..." {
      let step = (type: "delay", label: "")
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      continue
    }
    let dly = line.match(regex("^\.\.\.(.+?)\.\.\.$"))
    if dly != none {
      let step = (type: "delay", label: dly.captures.at(0).trim())
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
        let top = st.frag-stack.last()
        top.children.push((type: "alt-else", label: el.label))
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      }
      continue
    }

    // ---- end (close fragment) ----
    if line == "end" {
      if st.frag-stack.len() > 0 {
        let frag = st.frag-stack.pop()
        let step = (
          type: "fragment",
          kind: frag.kind,
          label: frag.label,
          children: frag.children,
        )
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

    // ---- ref over ... : text ----
    let rf = _parse-ref(line)
    if rf != none {
      // Auto-create participants if not seen.
      let ids = if type(rf.over) == str { (rf.over,) } else { rf.over }
      for id in ids {
        if id not in st.seen-ids {
          st.seen-ids.push(id)
          st.participants.push((id: id, name: id, fill: none))
        }
      }
      let step = (type: "ref", over: rf.over, label: rf.label)
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      continue
    }

    // ---- Note ----
    let nt = _parse-note(line)
    if nt != none {
      if nt.type == "note-start" {
        st.note-state = (
          over: nt.over,
          side: nt.at("side", default: none),
          lines: (),
        )
      } else {
        let over = nt.over
        if over == "__last__" {
          // PlantUML anchors `note left/right : …` on the SENDER of the
          // previous message — the visual "left/right" sides are relative
          // to the sender's lifeline, not the receiver's.
          if st.last-from != none { over = st.last-from }
          else if st.last-to != none { over = st.last-to }
        }
        if over == "across" {
          over = "__divider__"
        }
        let step = (type: "note", over: over, label: nt.label)
        let side = nt.at("side", default: none)
        if side != none { step.insert("side", side) }
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

    // ---- activate / deactivate (skip — auto-tracked) ----
    if line.starts-with("activate ") or line.starts-with("deactivate ") {
      continue
    }

    // ---- destroy A ----
    if line.starts-with("destroy ") {
      let id = line.slice("destroy ".len()).trim()
      if id not in st.seen-ids {
        st.seen-ids.push(id)
        st.participants.push((id: id, name: id, fill: none))
      }
      let step = (type: "destroy", who: id)
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
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

    // ---- Boundary message: [-> / [<- / ->] / <-] ----
    let bmsg = _parse-boundary(line)
    if bmsg != none {
      // Auto-create the real participant (the non-edge endpoint).
      let real-id = if bmsg.from == "[" or bmsg.from == "]" {
        bmsg.to
      } else {
        bmsg.from
      }
      if real-id not in st.seen-ids {
        st.seen-ids.push(real-id)
        st.participants.push((id: real-id, name: real-id, fill: none))
      }
      let step = (
        type: bmsg.type,
        from: bmsg.from,
        to: bmsg.to,
        label: bmsg.label,
      )
      if st.frag-stack.len() > 0 {
        let top = st.frag-stack.last()
        top.children.push(step)
        st.frag-stack.at(st.frag-stack.len() - 1) = top
      } else {
        st.steps.push(step)
      }
      st.last-from = bmsg.from
      st.last-to = bmsg.to
      continue
    }

    // ---- Message arrow ----
    let msg = _parse-message(line)
    if msg != none {
      // Ensure participants exist (skip edge anchors).
      if msg.from != "[" and msg.from != "]" and msg.from not in st.seen-ids {
        st.seen-ids.push(msg.from)
        st.participants.push((id: msg.from, name: msg.from, fill: none))
      }
      if msg.to != "[" and msg.to != "]" and msg.to not in st.seen-ids {
        st.seen-ids.push(msg.to)
        st.participants.push((id: msg.to, name: msg.to, fill: none))
      }

      // `**` suffix on the target creates it as a new participant — emit a
      // seq-create step BEFORE the message so the header lands above the
      // arrow.
      if msg.suffix == "**" and not (msg.to in st.created-ids) {
        st.created-ids.push(msg.to)
        let cstep = (type: "create", who: msg.to)
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(cstep)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(cstep)
        }
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
      // Only carry an explicit head when it differs from the type default,
      // so unmodified `->` and `-->` arrows stay in the canonical shape.
      let default-head = if msg.type == "return" { "v" } else { "filled" }
      if msg.head != default-head {
        step.insert("head", msg.head)
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

      // `!!` suffix on the target destroys it after the message lands.
      if msg.suffix == "!!" {
        let dstep = (type: "destroy", who: msg.to)
        if st.frag-stack.len() > 0 {
          let top = st.frag-stack.last()
          top.children.push(dstep)
          st.frag-stack.at(st.frag-stack.len() - 1) = top
        } else {
          st.steps.push(dstep)
        }
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
  let final-boxes = if st.boxes.len() > 0 { st.boxes } else { none }
  // Grow `header-height` when any participant has a multi-line `[ … ]` body
  // so the rendered title/rule/subtitle stack stays inside the header rect.
  let effective-header-height = if st.pblock-max-lines > 1 {
    let needed = st.pblock-max-lines * 1.25em + 0.6em
    if needed > header-height { needed } else { header-height }
  } else { header-height }
  // Resolve `activate: auto` (the default) from the parsed `autoactivate`
  // directive; explicit `true`/`false` from the caller wins. PlantUML's own
  // default is no auto-activation unless `autoactivate on` is set.
  let effective-activate = if activate == auto { st.autoactivate-on } else { activate }
  seq-lane(
    width: width,
    step-height: step-height,
    header-height: effective-header-height,
    column-gap: column-gap,
    row-gap: row-gap,
    activate: effective-activate,
    activation-width: activation-width,
    message-align: message-align,
    response-below: response-below,
    participants: final-participants,
    boxes: final-boxes,
    ..steps,
  )
}
