// Shared page setup for snapshot tests. Fixed width + auto height keeps
// rendered output stable across runs while still letting each fixture lay
// out naturally. Do not pin a specific font here — the test runner should
// be invoked in an environment where Typst's default fonts resolve.

#let setup(body) = {
  set page(width: 420pt, height: auto, margin: 10pt)
  set text(size: 10pt)
  body
}
