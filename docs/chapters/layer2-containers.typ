#import "../../lib.typ": *
#import "../style.typ": *

== Layer 2 — 容器

=== `region`

带背景和边框的容器，把多个 `cell` 聚合为一个结构单元。配合 `danger` / `faded`
标志可以直接表达"受保护区"或"零大小 / 缺失区"。

#section-label[Example]

#example-pair(
  ```typ
  #region[
    #cell(fill: rgb("#87CEFA"))[ptr]
    #cell(fill: rgb("#00FFFF"))[len]
    #cell(fill: rgb("#00FFFF"))[cap]
  ]
  ```,
  [
    #region[
      #cell(fill: rgb("#87CEFA"))[`ptr`]
      #cell(fill: aqua)[`len`]
      #cell(fill: aqua)[`cap`]
    ]
  ],
)

#section-label[Parameters]

#params-box("region",
  ("body",          ("content",)),
  ("fill",          ("color",)),
  ("stroke",        ("stroke",)),
  ("dash",          ("none", "str")),
  ("radius",        ("length",)),
  ("width",         ("auto", "length")),
  ("content-align", ("alignment",)),
  ("label",         ("none", "str", "content")),
  ("danger",        ("bool",)),
  ("faded",         ("bool",)),
  returns: "content",
)

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  右下角小号标注，常用于 `"(heap)"` / `"(stack)"` 等位置线索。
]

#param-detail("danger", ("bool",), default: raw("false", lang: none))[
  加厚红色边框（2pt），语义上表示"越权 / unsafe / 受限访问"。与 `faded` 互斥。
]

#param-detail("faded", ("bool",), default: raw("false", lang: none))[
  虚线边框 + 60% 透明填充，语义上表示"零大小 / 不存在 / 将要被 move 走"。
  与 `danger` 互斥。
]

#section-label[More]

三种形态并列：

#align(center)[
  #region[
    #cell(fill: rgb("#87CEFA"))[`ptr`]
    #cell(fill: aqua)[`len`]
    #cell(fill: aqua)[`cap`]
  ]
  #h(12pt)
  #region(danger: true)[
    #cell(fill: rgb("#87CEFA"))[`ptr`]
    #cell(fill: luma(230), dash: "dashed")[`meta`]
  ]
  #h(12pt)
  #region(faded: true, width: 20pt)[]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  普通 #h(48pt) `danger: true` #h(28pt) `faded: true`
])

=== `target`

"被引用的区域" —— 虚线边框 + 半透明填充，加右下角 `(heap)` / `(static)` 等小标签。
底层是 `region` 的薄封装，专用于和 `connector` 搭配表达"上层结构 → 下层存储"。

#section-label[Example]

#example-pair(
  ```typ
  #target(fill: rgb("#C6DBE7"),
          label: "(heap)",
          width: 120pt)[
    #cell(fill: rgb("#FA8072"))[T]
    #cell(fill: rgb("#FA8072"))[T]
  ]
  ```,
  [
    #target(fill: rgb("#C6DBE7"), label: "(heap)", width: 120pt)[
      #cell(fill: rgb("#FA8072"))[`T`]
      #cell(fill: rgb("#FA8072"))[`T`]
    ]
  ],
)

#section-label[Parameters]

#params-box("target",
  ("body",  ("content",)),
  ("fill",  ("color",)),
  ("label", ("none", "str", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

=== `connector`

区域与目标之间的垂直连线。宽度自动居中到父块中轴，长度默认 8pt。

#section-label[Example]

#example-pair(
  ```typ
  #region[
    #cell(fill: rgb("#87CEFA"))[ptr]
  ]
  #connector()
  #target[
    #cell(fill: rgb("#FA8072"))[T]
  ]
  ```,
  [
    #region[#cell(fill: rgb("#87CEFA"))[`ptr`]]
    #connector()
    #target[#cell(fill: rgb("#FA8072"))[`T`]]
  ],
)

#section-label[Parameters]

#params-box("connector",
  ("length", ("length",)),
  ("stroke", ("stroke",)),
  returns: "content",
)

=== `divider`

布局替代方案之间的文字分隔线，斜体居中。典型用法：在枚举的两个变体之间标注
"exclusive or"。

#section-label[Example]

#example-pair(
  ```typ
  #region(fill: rgb("#FAFAD2"))[
    #tag[Tag] #cell(fill: red)[A]
  ]
  #divider(body: [exclusive or])
  #region(fill: rgb("#FAFAD2"))[
    #tag[Tag] #cell(fill: red)[B]
  ]
  ```,
  [
    #region(fill: rgb("#FAFAD2"))[
      #tag[`Tag`] #cell(fill: rgb("#FA8072"))[`A`]
    ]
    #divider(body: [exclusive or])
    #region(fill: rgb("#FAFAD2"))[
      #tag[`Tag`] #cell(fill: rgb("#FA8072"), width: 60pt)[`B`]
    ]
  ],
)

#section-label[Parameters]

#params-box("divider",
  ("body", ("content",)),
  returns: "content",
)

=== `detail`

`region` 下方的说明条。外观是一个紧贴上方区域的窄横条（顶边与 region 无缝相接），
用于"这个区域是 X，顺便说明一下 Y"。

#section-label[Example]

#example-pair(
  ```typ
  #region[
    #cell(fill: rgb("#87CEFA"))[ptr]
    #cell(fill: aqua)[len]
  ]
  #detail[
    Runtime borrow count tracked here.
  ]
  ```,
  [
    #region[
      #cell(fill: rgb("#87CEFA"))[`ptr`]
      #cell(fill: aqua)[`len`]
    ]
    #detail[Runtime borrow count tracked here.]
  ],
)

#section-label[Parameters]

#params-box("detail",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

=== `entry-list`

`target` 内的垂直条目表。典型用途是 vtable、寄存器映射、函数指针表这类"固定长度
的条目序列"。

#section-label[Example]

#example-pair(
  ```typ
  #entry-list(
    label: "(vtable)",
    (
      [`*Drop::drop(&mut T)`],
      [`size`], [`align`],
      [`*Trait::f(&T, …)`],
    ),
  )
  ```,
  [
    #entry-list(
      label: "(vtable)",
      ([`*Drop::drop(&mut T)`], [`size`], [`align`], [`*Trait::f(&T, …)`]),
    )
  ],
)

#section-label[Parameters]

#params-box("entry-list",
  ("entries", ("array",)),
  ("fill",    ("color",)),
  ("label",   ("none", "str", "content")),
  ("width",   ("auto", "length")),
  returns: "content",
)

#param-detail("entries", ("array",))[
  每条是一段 content（包含 raw / text 等），按顺序垂直排列，条目间带浅色分隔线。
]

=== `stack`

最简单的垂直堆叠。每项以独立 positional 参数传入，比一堆 `#v(...)` 分隔的写法更
稳、更好重排。

#section-label[Example]

#example-pair(
  ```typ
  #stack(
    [#region(width: 100pt)[L1]],
    [#region(width: 140pt)[L2]],
    [#region(width: 180pt)[L3]],
  )
  ```,
  [
    #stack(
      [#region(fill: palettes.pastel.blue.lighten(40%), width: 100pt)[
        #text(weight: "bold")[L1]
      ]],
      [#region(fill: palettes.pastel.cyan.lighten(40%), width: 140pt)[
        #text(weight: "bold")[L2]
      ]],
      [#region(fill: palettes.pastel.teal.lighten(40%), width: 180pt)[
        #text(weight: "bold")[L3]
      ]],
    )
  ],
)

#section-label[Parameters]

#params-box("stack",
  ("..items", ("content",)),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

=== `group`

带左上角标题的分组框，语义介于 `region`（单一结构单元，右下小标签）和 `section`
（文档级大卡片）之间。适合"这 N 个子组件属于同一逻辑层 / 模块"。

#section-label[Example]

#example-pair(
  ```typ
  #let cat = palettes.categorical
  #group(label: [业务层 Business],
         fill: cat.at(1).lighten(42%))[
    #region(fill: cat.at(1))[
      Business: 自有平台
    ]
    #v(4pt)
    #region(fill: cat.at(1).lighten(10%))[
      Business: 外部平台同步
    ]
  ]
  ```,
  [
    #group(label: [业务层], fill: palettes.categorical.at(1).lighten(42%),
           width: 100%)[
      #region(fill: palettes.categorical.at(1), width: 100%)[
        #text(weight: "bold", size: 0.85em)[自有平台]
      ]
      #v(3pt)
      #region(fill: palettes.categorical.at(1).lighten(10%), width: 100%)[
        #text(weight: "bold", size: 0.85em)[外部平台同步]
      ]
    ]
  ],
)

#section-label[Parameters]

#params-box("group",
  ("body",          ("content",)),
  ("label",         ("none", "content")),
  ("fill",          ("color",)),
  ("stroke",        ("stroke",)),
  ("dash",          ("none", "str")),
  ("radius",        ("length",)),
  ("width",         ("auto", "length")),
  ("inset",         ("length",)),
  ("content-align", ("alignment",)),
  returns: "content",
)

#param-detail("label", ("none", "content"), default: raw("none", lang: none))[
  左上角小标题；留空则是纯边框。
]

#param-detail("dash", ("none", "str"), default: raw("none", lang: none))[
  边框虚线。`"dashed"` 表示该分组是逻辑边界（不是物理结构），语义更弱。
]

#section-label[Idioms]

可嵌套；用 `fill` 深浅表达层级：

```typ
#group(label: [生态], fill: C.a.lighten(50%))[
  #group(label: [业务层], fill: C.b.lighten(40%))[ ... ]
  #group(label: [基础设施], fill: C.c.lighten(40%))[ ... ]
]
```
