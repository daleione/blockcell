// ============================================================================
// Edge rendering: head shapes, multi-segment bezier draw, label placement.
// ============================================================================
//
// Codegen emits one edge as
//   (head-from, head-to, line-style, segments, label, mult-*, role-*, note, ...)
// where `segments` is a list of cubic-bezier segments. `_draw-edge`
// renders the path and the two endpoint heads; `_place-edge-label` does
// the centred label / multiplicity / role text with collision-avoidance
// against class bboxes.

#import "../palettes.typ": palettes

// Draw the head decoration `head` at point `at`, oriented so the shape's
// "tip" points at `at` and its "tail" extends back along `-tangent`.
// `tangent` is a (x, y) length tuple (normalised here, so the caller can
// pass raw differences).
//
// `head` ∈ "none" | "triangle-open" | "arrow-open" | "diamond-open" |
//          "diamond-filled" | "cross" | "plus" | "circle" |
//          "socket-open" | "socket-closed"
//
// Returns content. "Open" heads (triangle-open, diamond-open, circle)
// use `bg-color` as their fill so the underlying line is hidden inside
// the head shape — no need to clip the line to the head boundary.
#let _draw-head(at, tangent, head, color, bg-color, head-size, thickness) = {
  if head == "none" { return [] }
  let tx = tangent.at(0)
  let ty = tangent.at(1)
  let lenn = calc.sqrt((tx / 1pt) * (tx / 1pt) + (ty / 1pt) * (ty / 1pt))
  if lenn == 0 { return [] }
  let ux = tx / (lenn * 1pt)
  let uy = ty / (lenn * 1pt)
  let px = -uy
  let py = ux

  let tip-x = at.at(0)
  let tip-y = at.at(1)

  if head == "triangle-open" or head == "triangle-filled" {
    let bx = tip-x - ux * head-size
    let by = tip-y - uy * head-size
    let half = head-size * 0.6
    let fill-paint = if head == "triangle-filled" { color } else { bg-color }
    place(top + left, polygon(
      fill: fill-paint,
      stroke: thickness + color,
      (tip-x, tip-y),
      (bx + px * half, by + py * half),
      (bx - px * half, by - py * half),
    ))
  } else if head == "diamond-open" or head == "diamond-filled" {
    let len = head-size * 1.6
    let bx = tip-x - ux * len
    let by = tip-y - uy * len
    let mx = tip-x - ux * (len / 2)
    let my = tip-y - uy * (len / 2)
    let half = head-size * 0.45
    let fill-paint = if head == "diamond-filled" { color } else { bg-color }
    place(top + left, polygon(
      fill: fill-paint,
      stroke: thickness + color,
      (tip-x, tip-y),
      (mx + px * half, my + py * half),
      (bx, by),
      (mx - px * half, my - py * half),
    ))
  } else if head == "arrow-open" {
    let bx = tip-x - ux * head-size
    let by = tip-y - uy * head-size
    let half = head-size * 0.55
    place(top + left, line(
      start: (bx + px * half, by + py * half),
      end: (tip-x, tip-y),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (bx - px * half, by - py * half),
      end: (tip-x, tip-y),
      stroke: thickness + color,
    ))
  } else if head == "cross" {
    let half = head-size * 0.5
    place(top + left, line(
      start: (tip-x - ux * half + px * half, tip-y - uy * half + py * half),
      end: (tip-x + ux * half - px * half, tip-y + uy * half - py * half),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (tip-x - ux * half - px * half, tip-y - uy * half - py * half),
      end: (tip-x + ux * half + px * half, tip-y + uy * half + py * half),
      stroke: thickness + color,
    ))
  } else if head == "plus" {
    let half = head-size * 0.5
    place(top + left, line(
      start: (tip-x - ux * half, tip-y - uy * half),
      end: (tip-x + ux * half, tip-y + uy * half),
      stroke: thickness + color,
    ))
    place(top + left, line(
      start: (tip-x - px * half, tip-y - py * half),
      end: (tip-x + px * half, tip-y + py * half),
      stroke: thickness + color,
    ))
  } else if head == "circle" {
    let r = head-size * 0.5
    place(top + left, dx: tip-x - r, dy: tip-y - r,
      circle(radius: r, fill: bg-color, stroke: thickness + color))
  } else if head == "socket-open" or head == "socket-closed" {
    // Component-interface socket: a half-circle ARC whose open side
    // faces the line direction (i.e. "cups" the incoming line). The
    // arc center is offset OUTWARD from the tip so the cup opens toward
    // the source. Approximated with an arc-shaped polygon — Typst's
    // primitive `circle` doesn't support arc spans, so we draw a full
    // circle and overlay a rectangle to mask the unwanted half.
    let r = head-size * 0.55
    // Center sits past the tip in the line's direction (so the open
    // side faces back toward the source).
    let cx = tip-x + ux * r
    let cy = tip-y + uy * r
    place(top + left, dx: cx - r, dy: cy - r,
      circle(radius: r, fill: none, stroke: thickness + color))
    // Mask the "back" half (the half on the far side of the tip from
    // the source) by overlaying a rectangle in bg-color.
    let mask-half = r + thickness.to-absolute()
    let mask-cx = cx + ux * (mask-half / 2)
    let mask-cy = cy + uy * (mask-half / 2)
    let mask-w = if calc.abs(ux) > 0.5 { mask-half } else { 2 * r + 2pt }
    let mask-h = if calc.abs(uy) > 0.5 { mask-half } else { 2 * r + 2pt }
    place(top + left,
      dx: mask-cx - mask-w / 2,
      dy: mask-cy - mask-h / 2,
      rect(width: mask-w, height: mask-h, fill: bg-color, stroke: none))
  }
  // Unknown heads silently render nothing.
}

// Draw a multi-segment cubic bezier from `start` through `segments` to
// `end`. Each segment is `(c1: ..., c2: ..., end: ...)`. The first
// segment's start equals `start`; subsequent starts equal the previous
// segment's end; the last segment's end is overridden by the resolved
// `end` here. Boundary control handles are translated to keep the path
// tangent into the resolved endpoints — same scheme as
// records.typ::_draw-bezier-path.
//
// Heads are drawn with their tips snapped to the resolved endpoints, so
// they stay glued to the class edge even if Rust-side endpoint estimates
// differ slightly from Typst's measured geometry.
#let _draw-edge(
  start, segments, end,
  head-from, head-to, line-style,
  color, bg-color, thickness, head-size,
  from-side: none, to-side: none,
  from-axis-snap: true, to-axis-snap: true,
) = {
  let n = segments.len()
  if n == 0 { return }

  // The painter-side endpoints are snapped to the rendered class
  // geometry, which can drift from codegen's estimate. The two boundary
  // control handles compensate differently:
  //   • first c1: collapsed onto the launch axis dictated by `from-side`
  //     so the head tangent is axis-aligned and never degenerate. For
  //     top/bot (the TB default) that's the vertical axis; for left/right
  //     it's horizontal.
  //   • last c2: translated by (end - last.end) so the codegen-emitted
  //     incoming tangent is preserved against the snapped endpoint, then
  //     collapsed onto the arrival axis dictated by `to-side` for the
  //     same reason.
  //
  // `*-axis-snap: false` opts a side out of the axis collapse — used
  // when codegen explicitly set the anchor coord (via from-x/y or
  // to-x/y override) and intends a non-axis-aligned tangent (e.g. a
  // straight diagonal cubic between two distributed anchors). The
  // (end - last.end) translation still applies so the curve closes on
  // the painter-side endpoint.
  let from-horizontal = from-side == "left" or from-side == "right"
  let to-horizontal = to-side == "left" or to-side == "right"
  let first-c1 = if not from-axis-snap {
    segments.at(0).c1
  } else if from-horizontal {
    (segments.at(0).c1.at(0), start.at(1))
  } else {
    (start.at(0), segments.at(0).c1.at(1))
  }
  let last = segments.at(n - 1)
  let last-c2-translated = (
    last.c2.at(0) + end.at(0) - last.end.at(0),
    last.c2.at(1) + end.at(1) - last.end.at(1),
  )
  let last-c2 = if not to-axis-snap {
    last-c2-translated
  } else if to-horizontal {
    (last-c2-translated.at(0), end.at(1))
  } else {
    (end.at(0), last-c2-translated.at(1))
  }

  let cmds = (curve.move(start),)
  for i in range(n) {
    let seg = segments.at(i)
    let seg-end = if i == n - 1 { end } else { seg.end }
    let seg-c1 = if i == 0 { first-c1 } else { seg.c1 }
    let seg-c2 = if i == n - 1 { last-c2 } else { seg.c2 }
    cmds.push(curve.cubic(seg-c1, seg-c2, seg-end))
  }
  let dash-pat = if line-style == "dashed" { "dashed" }
                 else if line-style == "dotted" { "dotted" }
                 else { none }
  place(top + left, curve(
    ..cmds,
    stroke: (paint: color, thickness: thickness, dash: dash-pat),
  ))

  // Head at start: tip = start, body extends back along start - c1.
  let from-tan = (start.at(0) - first-c1.at(0), start.at(1) - first-c1.at(1))
  _draw-head(start, from-tan, head-from, color, bg-color, head-size, thickness)
  // Head at end: tip = end, body extends back along end - c2.
  let to-tan = (end.at(0) - last-c2.at(0), end.at(1) - last-c2.at(1))
  _draw-head(end, to-tan, head-to, color, bg-color, head-size, thickness)
}

// Returns true iff the rect (x, y, x+w, y+h) overlaps any class /
// note / lollipop bbox in `classes` × `metas`.
#let _overlaps-any-class(x, y, w, h, classes, metas) = {
  let hit = false
  for i in range(classes.len()) {
    let r = classes.at(i)
    let mw = metas.at(i).width
    let mh = metas.at(i).height
    let cx = r.x
    let cy = r.y
    if not (x + w <= cx or x >= cx + mw
            or y + h <= cy or y >= cy + mh) {
      hit = true
      break
    }
  }
  hit
}

// Place an edge label centered on a parametric position along the
// chord. `t` ∈ [0, 1]: 0 = start anchor, 1 = end anchor. `perp` shifts
// the label perpendicular to the edge — positive values drift to the
// chord's left (using the (dx, dy) → (-dy, dx) 90° CCW rotation).
//
// `label-pos: (x, y)` overrides the whole `start`/`end`/`t` chord
// computation with an absolute point — codegen sets this for
// orthogonally-routed edges (§3.8), where the straight start→end
// chord's midpoint can land far from the actual bent path; it instead
// picks the midpoint of the route's longest straight trunk segment.
// Collision avoidance falls back to a small set of absolute offset
// candidates instead of the chord-relative perpendicular, since an
// absolute point has no single "perpendicular" direction to rotate
// around.
//
// If `classes` and `metas` are non-empty, the label's bbox is checked
// against every class bbox; on overlap the perp offset is doubled,
// then doubled again, before falling back to the original position
// (some overlap may remain in dense diagrams — proper avoidance needs
// a layout solver).
#let _place-edge-label(start, end, t, body, perp: 0pt, label-pos: none,
                       classes: (), metas: (), shift-x: 0pt, shift-y: 0pt) = {
  if body == none { return }
  // Light-tint background — readable text over a line, much less
  // obtrusive than the previous opaque (CC ~80% alpha) box.
  let lbl = box(inset: 2pt, fill: rgb("#FFFFFF80"),
    text(size: 0.78em, fill: palettes.base.text, body))
  let m = measure(lbl)

  if label-pos != none {
    let candidates = ((0pt, 0pt), (0pt, 12pt), (0pt, -12pt), (12pt, 0pt), (-12pt, 0pt))
    let chosen = (0pt, 0pt)
    let found = false
    for (ox, oy) in candidates {
      if not found {
        let x = label-pos.at(0) + ox - m.width / 2
        let y = label-pos.at(1) + oy - m.height / 2
        let collides = (classes.len() != 0) and _overlaps-any-class(
          x - shift-x, y - shift-y, m.width, m.height, classes, metas)
        if not collides {
          chosen = (ox, oy)
          found = true
        }
      }
    }
    let x = label-pos.at(0) + chosen.at(0) - m.width / 2
    let y = label-pos.at(1) + chosen.at(1) - m.height / 2
    place(top + left, dx: x, dy: y, lbl)
    return
  }

  let dx = end.at(0) - start.at(0)
  let dy = end.at(1) - start.at(1)
  let len-pt = calc.sqrt((dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt))
  let (px, py) = if len-pt == 0 { (0, 0) }
    else { (-dy / (len-pt * 1pt), dx / (len-pt * 1pt)) }

  // Pick the first perp offset whose label bbox doesn't clip a class.
  // For non-zero perp (mult / role), try the opposite side too — if
  // the target class sits in the default direction, all positive
  // candidates collide and the label would otherwise land on the
  // class's header band.
  let perps = if perp == 0pt {
    (0pt, 12pt, -12pt, 24pt)
  } else {
    (perp, -perp, perp * 1.8, -perp * 1.8, perp * 2.6, -perp * 2.6)
  }
  let chosen-perp = perp
  let found = false
  for p in perps {
    if not found {
      let x = start.at(0) + dx * t + px * p - m.width / 2
      let y = start.at(1) + dy * t + py * p - m.height / 2
      let check-x = x - shift-x
      let check-y = y - shift-y
      let collides = (classes.len() != 0) and _overlaps-any-class(
        check-x, check-y, m.width, m.height, classes, metas)
      if not collides {
        chosen-perp = p
        found = true
      }
    }
  }
  let x = start.at(0) + dx * t + px * chosen-perp - m.width / 2
  let y = start.at(1) + dy * t + py * chosen-perp - m.height / 2
  place(top + left, dx: x, dy: y, lbl)
}
