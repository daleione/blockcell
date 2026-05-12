// ============================================================================
// Class-card theme: stereotype tint table + compartment row renderer.
// ============================================================================
//
// Shared by `_layout-class` (the 3-compartment card) for its corner chip
// and by `_render-member` for visibility-glyph styling. The desc-family
// shape painters in `shape-desc.typ` do not consult this — they paint a
// uniform fill and need no stereotype glyph.

#import "../palettes.typ": palettes

// Default tint and single-letter glyph for the stereotype circle, keyed by
// entity kind. Loosely mirrors PlantUML's default skin
// (orange/blue/lavender/pink). Codegen passes a `kind` string we look up
// here; unknown kinds fall back to gray + no glyph so a user-defined
// stereotype still renders something readable.
#let _kind-styles = (
  "class":      (fill: rgb("#ADD1B2"), letter: "C"),
  "struct":     (fill: rgb("#ADD1B2"), letter: "C"),
  "exception":  (fill: rgb("#ADD1B2"), letter: "C"),
  "interface":  (fill: rgb("#B4A7E5"), letter: "I"),
  "protocol":   (fill: rgb("#B4A7E5"), letter: "I"),
  "abstract":   (fill: rgb("#A9DCDF"), letter: "A"),
  "enum":       (fill: rgb("#EB937F"), letter: "E"),
  "annotation": (fill: rgb("#E3664A"), letter: "@"),
  "entity":     (fill: rgb("#ADD1B2"), letter: "E"),
)

#let _kind-style(kind) = _kind-styles.at(kind,
  default: (fill: rgb("#D0D0D0"), letter: none))

// Render one compartment row (a field or method). `member` is a dict with
// keys `vis` (string ∈ {"+", "-", "#", "~", ""}), `body` (content),
// `static` (bool), `abstract` (bool). The visibility glyph is rendered
// monospace so a column of `+`/`-`/`#`/`~` lines up cleanly.
#let _render-member(member) = {
  let vis = member.at("vis", default: "")
  let body = member.at("body", default: [])
  let is-static = member.at("static", default: false)
  let is-abstract = member.at("abstract", default: false)
  let glyph = if vis == "" { [] } else {
    text(font: ("DejaVu Sans Mono", "Menlo", "Consolas"),
         size: 0.95em, fill: palettes.base.text-muted, vis)
  }
  let rendered = body
  if is-abstract { rendered = emph(rendered) }
  if is-static { rendered = underline(rendered) }
  // Visibility glyph + thin gap + body. Inline so a row's height is one
  // text line.
  if vis == "" { rendered }
  else {
    glyph
    h(0.35em)
    rendered
  }
}
