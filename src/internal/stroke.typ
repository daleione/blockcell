/// Internal stroke helpers shared across modules.
/// These are implementation details, not part of the public API.
///
/// Merge a dash pattern into an existing stroke, preserving paint and thickness.
/// Returns the stroke unchanged when `dash` is `none`.
#let with-stroke-dash(stroke, dash) = {
  if dash == none { return stroke }
  if type(stroke) == dictionary {
    (..stroke, dash: dash)
  } else {
    let s = std.stroke(stroke)
    (paint: s.paint, thickness: s.thickness, dash: dash)
  }
}
