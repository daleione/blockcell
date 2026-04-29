#import "../../lib.typ": *
#import "../style.typ": *

== Layer 2 — 容器 <layer2>

这一章介绍把多个图元组织成一个整体时最常用的容器组件。

如果说 #api-ref("layer1-cell", "cell") 是单个方块，那么这一章的组件负责回答这些问题：

- 怎么把多个方块包成一个结构？
- 怎么表示“这个区域指向另一个区域”？
- 怎么把几段内容上下堆叠？
- 怎么给一组内容加标题、说明或分组边界？

如果你是第一次使用，建议先掌握：

1. #api-ref("layer2-region", "region")
2. #api-ref("layer2-target", "target")
3. #api-ref("layer2-connector", "connector")
4. #api-ref("layer2-stack", "stack")
5. #api-ref("layer2-group", "group")

=== `region` <layer2-region>

最常用的容器，用来把多个内容包成一个整体。

常用在这些场景：

- 结构体字段组
- 模块边界
- 一段逻辑区域
- 一组需要统一背景和边框的内容

#section-label[最简单的写法]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
    #cell(fill: palettes.pastel.cyan)[cap]
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.cyan)[len]
      #cell(fill: palettes.pastel.cyan)[cap]
    ]
  ],
)

#section-label[常用参数]

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

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  容器背景色。最常见的做法是给整组内容一个比内部 `cell` 更浅的底色。
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  容器边框样式。需要强调边界时可以加粗或换色。
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  边框线型。常用值是 `none`、`"dashed"`、`"dotted"`。
]

#param-detail("radius", ("length",),
  default: raw("4pt", lang: none))[
  圆角大小。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  容器宽度。需要多块对齐时，通常会显式设置。
]

#param-detail("content-align", ("alignment",),
  default: raw("center", lang: none))[
  容器内部内容对齐方式。
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  右下角的小标签。适合写 `(heap)`、`(stack)`、`(shared)` 这类补充说明。
]

#param-detail("danger", ("bool",),
  default: raw("false", lang: none))[
  用更强的危险样式强调该区域。适合表示错误、越界、受限访问或高风险区域。
]

#param-detail("faded", ("bool",),
  default: raw("false", lang: none))[
  用更弱的样式表示该区域是缺失、占位、零大小或不再有效的内容。
]

#section-label[常用写法]

#example-pair(
  ```typst
  #region(
    fill: palettes.pastel.yellow,
    label: "(heap)",
  )[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.green)[len]
  ]
  ```
,
  [
    #region(
      fill: palettes.pastel.yellow,
      label: "(heap)",
    )[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.green)[len]
    ]
  ],
)

#section-label[状态变体]

#align(center)[
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
  ]
  #h(12pt)
  #region(danger: true)[
    #cell(fill: palettes.pastel.red)[unsafe]
    #cell(fill: palettes.pastel.orange)[meta]
  ]
  #h(12pt)
  #region(faded: true, width: 56pt)[]
]
#v(2pt)
#align(center, text(size: 0.8em, fill: luma(120))[
  普通 #h(42pt) `danger: true` #h(24pt) `faded: true`
])

#section-label[适合在这些情况下用]

- 你想把多个元素包成一个整体
- 你需要一个清楚的结构边界
- 你想给一组内容统一背景和边框
- 你在画结构图、模块图、字段组

#section-label[常和这些一起用]

- 和 `cell` 一起组成结构块
- 和 `schema` 一起组成完整图块
- 和 `connector`、`target` 一起表示引用关系
- 和 `detail` 一起补充说明

=== `target` <layer2-target>

用于表示“被指向的区域”或“目标区域”。

常用来表示：

- 堆对象
- 外部存储区
- 被引用内容
- 下层结构
- 目标资源

通常会和 `connector` 一起使用。

#section-label[最简单的写法]

#example-pair(
  ```typst
  #target(fill: palettes.pastel.blue, label: "(heap)", width: 120pt)[
    #cell(fill: palettes.pastel.red)[T]
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #target(fill: palettes.pastel.blue, label: "(heap)", width: 120pt)[
      #cell(fill: palettes.pastel.red)[T]
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[常用参数]

#params-box("target",
  ("body",  ("content",)),
  ("fill",  ("color",)),
  ("label", ("none", "str", "content")),
  ("width", ("auto", "length")),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("rgb(\"#FDECDC\")", lang: none))[
  目标区域背景色。通常会使用柔和、较浅的颜色。
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  右下角标签。常见写法有 `(heap)`、`(static)`、`(shared)`。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  目标区域宽度。需要和上方结构对齐时，通常会显式设置。
]

#section-label[适合在这些情况下用]

- 你想表达“这里是被指向的内容”
- 你在画指针、引用、堆对象
- 你需要把主结构和目标结构区分开

#section-label[常和这些一起用]

- 和 `connector` 一起连接上方结构
- 和 `linked-schema` 一起表达“字段区 → 目标区”
- 和 `cell` 一起表示目标区域内部字段

=== `connector` <layer2-connector>

用于连接上方结构和下方目标区域的简单竖线。

最常见的用法是：

- `region` 到 `target`
- 上层结构到下层结构
- 字段区到目标区

#section-label[最简单的写法]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
  ]
  #connector()
  #target[
    #cell(fill: palettes.pastel.red)[T]
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
    ]
    #connector()
    #target[
      #cell(fill: palettes.pastel.red)[T]
    ]
  ],
)

#section-label[常用参数]

#params-box("connector",
  ("length", ("length",)),
  ("stroke", ("stroke",)),
  returns: "content",
)

#param-detail("length", ("length",),
  default: raw("8pt", lang: none))[
  连接线长度。需要更紧凑或更松散的上下间距时可以调整。
]

#param-detail("stroke", ("stroke",),
  default: raw("1pt + palettes.base.border-soft", lang: none))[
  连接线样式。可以通过颜色或粗细表达不同语义。
]

#section-label[适合在这些情况下用]

- 你只需要简单的上下连接
- 你在表达“上方结构指向下方目标”
- 你不需要复杂自由连线

=== `divider` <layer2-divider>

用于分隔两种或多种互斥布局。

常用在这些场景：

- 枚举变体
- 互斥结构
- 两种替代方案
- “A 或 B” 这类说明

#section-label[最简单的写法]

#example-pair(
  ```typst
  #region(fill: palettes.pastel.yellow)[
    #tag[Tag] #cell(fill: palettes.pastel.red)[A]
  ]
  #divider(body: [exclusive or])
  #region(fill: palettes.pastel.yellow)[
    #tag[Tag] #cell(fill: palettes.pastel.red)[B]
  ]
  ```
,
  [
    #region(fill: palettes.pastel.yellow)[
      #tag[Tag] #cell(fill: palettes.pastel.red)[A]
    ]
    #divider(body: [exclusive or])
    #region(fill: palettes.pastel.yellow)[
      #tag[Tag] #cell(fill: palettes.pastel.red)[B]
    ]
  ],
)

#section-label[常用参数]

#params-box("divider",
  ("body", ("content",)),
  returns: "content",
)

#section-label[适合在这些情况下用]

- 你想明确表示“这两种布局不会同时出现”
- 你在画枚举、分支结构、替代方案
- 你需要一个比普通文字更清楚的分隔方式

=== `detail` <layer2-detail>

用于在一个区域下方补充一条说明。

常用在这些场景：

- 解释该区域的作用
- 补充实现含义或运行时含义
- 给结构图增加一条简短说明

#section-label[最简单的写法]

#example-pair(
  ```typst
  #region[
    #cell(fill: palettes.pastel.blue)[ptr]
    #cell(fill: palettes.pastel.cyan)[len]
  ]
  #detail[
    Runtime borrow count tracked here.
  ]
  ```
,
  [
    #region[
      #cell(fill: palettes.pastel.blue)[ptr]
      #cell(fill: palettes.pastel.cyan)[len]
    ]
    #detail[
      Runtime borrow count tracked here.
    ]
  ],
)

#section-label[常用参数]

#params-box("detail",
  ("body", ("content",)),
  ("fill", ("color",)),
  returns: "content",
)

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  说明条背景色。通常保持柔和，不要抢走主结构的视觉重点。
]

#section-label[适合在这些情况下用]

- 你想给一个区域补一条简短说明
- 说明应该紧贴结构，而不是单独写成正文
- 你希望图本身就能自解释

=== `entry-list` <layer2-entry-list>

用于显示一列条目。

常用在这些场景：

- vtable
- 函数表
- 寄存器条目
- 固定顺序的列表型结构

#section-label[最简单的写法]

#example-pair(
  ```typst
  #entry-list(
    label: "(vtable)",
    (
      [drop],
      [size],
      [align],
      [call],
    ),
  )
  ```
,
  [
    #entry-list(
      label: "(vtable)",
      (
        [drop],
        [size],
        [align],
        [call],
      ),
    )
  ],
)

#section-label[常用参数]

#params-box("entry-list",
  ("entries", ("array",)),
  ("fill",    ("color",)),
  ("label",   ("none", "str", "content")),
  ("width",   ("auto", "length")),
  returns: "content",
)

#param-detail("entries", ("array",))[
  条目数组。每一项都是一段内容，按顺序垂直排列。
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  条目区域背景色。
]

#param-detail("label", ("none", "str", "content"),
  default: raw("none", lang: none))[
  右下角标签。适合写 `(vtable)`、`(table)`、`(map)`。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  整体宽度。需要和其他结构对齐时可以显式设置。
]

#section-label[适合在这些情况下用]

- 你想表达一列固定顺序的条目
- 你需要比多个 `cell` 竖排更紧凑的列表结构
- 你在画表项、函数表、映射表

=== `stack` <layer2-stack>

最简单的垂直堆叠容器。

常用在这些场景：

- 把多个图块上下排列
- 做层级结构
- 避免反复手写很多 `#v(...)`
- 让多个独立块保持统一间距

#section-label[最简单的写法]

#example-pair(
  ```typst
  #stack(
    [#region(width: 100pt)[L1]],
    [#region(width: 140pt)[L2]],
    [#region(width: 180pt)[L3]],
  )
  ```
,
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

#section-label[常用参数]

#params-box("stack",
  ("..items", ("content",)),
  ("gap",     ("length",)),
  ("align",   ("alignment",)),
  returns: "content",
)

#param-detail("..items", ("content",))[
  需要上下排列的内容项。
]

#param-detail("gap", ("length",),
  default: raw("6pt", lang: none))[
  各项之间的垂直间距。
]

#param-detail("align", ("alignment",),
  default: raw("center", lang: none))[
  堆叠内容的对齐方式。
]

#section-label[适合在这些情况下用]

- 你想把多个块上下排列
- 你需要比手写多个 `#v(...)` 更稳定的写法
- 你在画缓存层次、分层结构、逐层展开的图

#section-label[常和这些一起用]

- 和 `region` 一起做层级结构
- 和 `group` 一起做更大的分组
- 和 `section` 一起做完整卡片内容

=== `group` <layer2-group>

用于给一组内容加一个更明确的分组边界和标题。

常用在这些场景：

- 逻辑模块分组
- 子系统边界
- 同一层级下的多个相关块
- 需要标题的分组框

它比 `region` 更适合“包住多个独立子块”，而不是表示单一结构单元。

#section-label[最简单的写法]

#example-pair(
  ```typst
  #group(label: [业务层], fill: palettes.categorical.at(1).lighten(42%))[
    #region(fill: palettes.categorical.at(1))[自有平台]
    #v(3pt)
    #region(fill: palettes.categorical.at(1).lighten(10%))[外部平台同步]
  ]
  ```
,
  [
    #group(
      label: [业务层],
      fill: palettes.categorical.at(1).lighten(42%),
      width: 100%,
    )[
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

#section-label[常用参数]

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

#param-detail("label", ("none", "content"),
  default: raw("none", lang: none))[
  左上角标题。适合写模块名、层级名、分组名。
]

#param-detail("fill", ("color",),
  default: raw("palettes.base.surface", lang: none))[
  分组背景色。通常会用比内部块更浅的颜色。
]

#param-detail("stroke", ("stroke",),
  default: raw("0.5pt + palettes.base.border-soft", lang: none))[
  分组边框样式。
]

#param-detail("dash", ("none", "str"),
  default: raw("none", lang: none))[
  边框线型。用虚线时，通常表示更弱的逻辑边界。
]

#param-detail("radius", ("length",),
  default: raw("6pt", lang: none))[
  圆角大小。
]

#param-detail("width", ("auto", "length"),
  default: raw("auto", lang: none))[
  分组宽度。
]

#param-detail("inset", ("length",),
  default: raw("10pt", lang: none))[
  分组边框与内部内容之间的间距。
]

#param-detail("content-align", ("alignment",),
  default: raw("center", lang: none))[
  分组内部内容对齐方式。
]

#section-label[适合在这些情况下用]

- 你想把多个独立块归为一个逻辑组
- 你需要一个带标题的分组边界
- 你在画系统分层、模块边界、业务域分组

#section-label[常和这些一起用]

- 和 `region` 一起做多层结构
- 和 `stack` 一起做上下分组
- 和 `section` 一起做更完整的文档级卡片

#section-label[嵌套分组]

#example-pair(
  ```typst
  #group(label: [系统], fill: palettes.pastel.blue.lighten(45%))[
    #group(label: [业务层], fill: palettes.pastel.green.lighten(40%))[
      #region[Service A]
      #v(3pt)
      #region[Service B]
    ]
  ]
  ```
,
  [
    #group(label: [系统], fill: palettes.pastel.blue.lighten(45%), width: 100%)[
      #group(label: [业务层], fill: palettes.pastel.green.lighten(40%), width: 100%)[
        #region(width: 100%)[Service A]
        #v(3pt)
        #region(width: 100%)[Service B]
      ]
    ]
  ],
)

== 本章小结 <layer2-summary>

如果你只想先记住最常用的几个容器组件，可以先记这几个：

- `region`：最常用的结构容器
- `target`：被指向的目标区域
- `connector`：上下连接线
- `stack`：垂直堆叠
- `group`：带标题的逻辑分组

接下来如果你想直接使用更完整的图表模式，请继续看下一章：*Layer 3 — 组合*。
