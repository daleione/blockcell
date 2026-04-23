#import "../../lib.typ": *

= API 参考

包的 API 分为三层，由底向上组合：

#align(center)[
  #grid(
    columns: 3,
    column-gutter: 12pt,
    region(fill: rgb("#E3F2FD"), width: 155pt)[
      #text(weight: "bold")[Layer 1 — 原子]
      #v(2pt)
      #text(size: 0.85em)[
        `cell` `tag` `note`\
        `badge` `sub-label`\
        `span-label` `wrap`\
        `brace` `edge`
      ]
    ],
    region(fill: rgb("#E8F5E9"), width: 155pt)[
      #text(weight: "bold")[Layer 2 — 容器]
      #v(2pt)
      #text(size: 0.85em)[
        `region` `target`\
        `connector` `divider`\
        `detail` `entry-list`\
        `stack` `group`
      ]
    ],
    region(fill: rgb("#FFF3E0"), width: 155pt)[
      #text(weight: "bold")[Layer 3 — 组合]
      #v(2pt)
      #text(size: 0.85em)[
        `schema` `linked-schema`\
        `grid-row` `lane`\
        `section` `legend`\
        `bit-row` `flex-row`\
        `seq-lane`
      ]
    ],
  )
  #v(6pt)
  #region(fill: rgb("#F3E5F5"), width: 490pt)[
    #text(weight: "bold")[Palettes — 调色板（按视觉角色分类）]
    #v(2pt)
    #text(size: 0.85em)[
      `palettes.status` `palettes.pastel` `palettes.categorical` `palettes.sequential`
      #h(6pt) (+ 域示例 `rust` / `network` / `cache`)
    ]
  ]
  #v(6pt)
  #region(fill: rgb("#FFECB3"), width: 490pt)[
    #text(weight: "bold")[流程图 — 专题章节]
    #v(2pt)
    #text(size: 0.85em)[
      `process` `decision` `terminal` `junction` (`flow-node`)
      #h(4pt) `flow-col`
      #h(4pt) `branch` `branch-merge` `switch` + `case`
      #h(4pt) `flow-loop`
      #h(6pt) → 详见 "流程图" 章节
    ]
  ]
  #v(6pt)
  #region(fill: rgb("#FCE4EC"), width: 490pt)[
    #text(weight: "bold")[状态转换图 — 专题章节]
    #v(2pt)
    #text(size: 0.85em)[
      `state-chain`
      #h(4pt) `state` (`initial` / `accept`)
      #h(4pt) `loop` `jump`
      #h(6pt) → 详见 "状态转换图" 章节
    ]
  ]
  #v(6pt)
  #region(fill: rgb("#E8F5E9"), width: 490pt)[
    #text(weight: "bold")[层级树图 — 专题章节]
    #v(2pt)
    #text(size: 0.85em)[
      `tree`
      #h(4pt) `node` (`shape: "rect" / "circle" / "stadium"`)
      #h(4pt) `edge-style: "line" / "elbow"`
      #h(6pt) → 详见 "层级树图" 章节
    ]
  ]
]

#v(8pt)

