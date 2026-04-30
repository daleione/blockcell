#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

// Cover the eight slot combinations. Each row keeps the same accent so any
// regression in slot-rendering (vs. accent derivation) is easy to isolate.
#let blue = palettes.categorical.at(0)

#stack(spacing: 6pt,
  // 1 — every slot present, plus the emphasized variant.
  field-cell(raw("user_id"),
    desc:  [用户 ID — 内部账户标识],
    badge: text(fill: blue.darken(35%), weight: "bold")[★],
    chip:  pill("string", accent: blue),
    accent: blue,
    emphasized: true,
  ),

  // 2 — every slot present, default stroke weight.
  field-cell(raw("transaction_id"),
    desc: [本次交易 ID],
    badge: text(fill: blue.darken(35%))[!],
    chip:  pill("string", accent: blue),
    accent: blue,
  ),

  // 3 — body + desc + chip (no badge).
  field-cell(raw("price"),
    desc: [价格 × 1000],
    chip: pill("int", accent: blue),
    accent: blue,
  ),

  // 4 — body + desc + badge (no chip).
  field-cell(raw("notification_uuid"),
    desc:  [来源通知 UUID],
    badge: text(fill: blue.darken(35%))[?],
    accent: blue,
  ),

  // 5 — body + chip (no desc, no badge).
  field-cell([Status],
    chip: pill("flag", accent: blue),
    accent: blue,
  ),

  // 6 — body + desc only.
  field-cell([Notes],
    desc:  [Free-form annotations],
    accent: blue,
  ),

  // 7 — body only — should still render cleanly with no extra row.
  field-cell([just-a-body], accent: blue),

  // 8 — explicit overrides (fill, stroke, body-fill) bypass accent derivation.
  field-cell(raw("custom"),
    desc:  [overridden colors],
    chip:  pill("override", accent: blue),
    fill:  rgb("#FFF4E6"),
    stroke: 1.2pt + rgb("#FB8C00"),
    body-fill: rgb("#5D2C00"),
  ),
)
