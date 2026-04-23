#import "../../lib.typ": *
#import "../style.typ": *

= 层级树图

*blockcell* 的 `tree` 画自顶向下的层级结构 —— BST、堆、Trie、目录树、JSON、
组织架构。入口只有一个函数：

```typ
#tree(root, ..children)
```

`root` 和每个 `child` 都是 *任意 content* —— `node(...)` / 嵌套 `tree(...)` /
`cell` / `flow-node` / `process` / 甚至 `[纯文本]`，想塞什么都行，可以任意混搭。
其中 `node(...)` 是 tree 专用的节点构造器，预设了 tree 场景下的视觉惯例：
pastel 蓝底、自然高度（文字怎么大盒子就怎么高）、`"circle"` 最小直径 28pt
（让 BST / 堆里单/双位数节点等大）。

#v(6pt)

#align(center)[
  #region(fill: rgb("#E8F5E9"), width: 100%)[
    #text(weight: "bold")[本章涉及图元]
    #v(2pt)
    #grid(
      columns: (84pt, 1fr),
      row-gutter: 4pt,
      text(size: 0.85em, weight: "bold")[主入口],
      text(size: 0.85em)[`tree(root, ..children)` —— 顶层渲染器兼子树构造器],
      text(size: 0.85em, weight: "bold")[便利节点],
      text(size: 0.85em)[`node(body, shape, fill, size)` —— tree 场景的
        默认节点（自然高度、pastel 蓝底、圆形 28pt 下限）],
      text(size: 0.85em, weight: "bold")[连线风格],
      text(size: 0.85em)[`edge-style: "elbow"`（默认，正交折线） /
        `"line"`（对角直线，BST 常用）],
    )
  ]
]

== 快速上手

经典的平衡二叉树 —— 一个函数同时当根构造器和子树构造器：

#wide-example(
  ```typ
  #tree(
    node[root],
    tree(node[L], node[LL], node[LR]),
    tree(node[R], node[RL], node[RR]),
  )
  ```,
  [
    #tree(
      node[root],
      tree(node[L], node[LL], node[LR]),
      tree(node[R], node[RL], node[RR]),
    )
  ],
)

#v(4pt)

读法：最外层 `tree(...)` 是顶层调用，出图；里面的两个 `tree(...)` 作为孩子传入，
被父级当子树处理。*同一个函数，两种身份*，无需区分。

默认风格是正交折线（elbow），适合目录树、组织架构。BST / 堆要对角直线就在
*最外层* 设一次 `edge-style: "line"`，所有嵌套子树自动继承。

== 核心 API

=== `node`

tree 专用的节点构造器。和 atoms 章的 `cell` / `flow-node` 是并列关系 —— 都是
"一个带文字的形状"，但各自面向不同场景：`cell` 贴合内存布局图（0 圆角、4pt 紧
padding），`flow-node` 贴合流程图（28pt 统一高度），`node` 贴合层级树（自然
高度、3pt 圆角、pastel 蓝底，`"circle"` 带 28pt 最小直径）。

返回 content，可以像 `#cell[x]` 一样独立出图，也可以作为 `tree(...)` 的任何
槽位。

#section-label[Example]

#wide-example(
  ```typ
  #node[root]                     // 默认矩形
  #node(shape: "circle")[7]       // 圆形，自动量直径
  #node(shape: "stadium")[start]  // 胶囊
  #node(fill: palettes.pastel.yellow)[dir/]
  ```,
  [
    #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt, align: center + horizon,
      node[root],
      node(shape: "circle")[7],
      node(shape: "stadium")[start],
      node(fill: palettes.pastel.yellow)[dir/],
    )
  ],
)

#section-label[Parameters]

#params-box("node",
  ("body",   ("content",)),
  ("shape",  ("str",)),
  ("fill",   ("color",)),
  ("stroke", ("stroke",)),
  ("radius", ("length",)),
  ("inset",  ("length", "dictionary")),
  ("size",   ("auto", "length")),
  returns: "content",
)

#param-detail("shape", ("str",), default: raw("\"rect\"", lang: none))[
  `"rect"` / `"circle"` / `"stadium"`（胶囊）。`"circle"` 在 `size: auto` 时
  直径下限 28pt —— 一棵 BST 里混 `1`、`8`、`10`、`14`，无需 `size:` 就等大。
  需要菱形等其它形状直接用 `flow-node(shape: "diamond")` 当 content 塞给 `tree`。
]

#param-detail("size", ("auto", "length"), default: raw("auto", lang: none))[
  固定圆直径或矩形/胶囊宽度。`auto` 自适应 body；三位数以上手动统一时用：
  ```typ
  #let c(body) = node(shape: "circle", size: 36pt, body)
  #tree(c[100], c[250], c[999])
  ```
]

#param-detail("fill", ("color",),
  default: raw("palettes.pastel.blue", lang: none))[
  节点底色。目录树惯例：`palettes.pastel.yellow` 给目录，`palettes.pastel.blue`
  给文件。
]

#param-detail("stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  节点边线。和其它 atoms 保持一致的默认。
]

#param-detail("inset", ("length", "dictionary"),
  default: raw("(x: 8pt, y: 4pt)", lang: none))[
  文字到节点边缘的内边距。比 `flow-node` (`10pt × 6pt`) 紧 —— tree 节点通常
  很短（一个名字/数字），贴合更紧不至于浪费画面空间。
]

#param-detail("radius", ("length",), default: raw("3pt", lang: none))[
  矩形圆角。`stadium` 强制 999pt（胶囊），`circle` 强制 50%，此参数不影响。
]

=== `tree`

层级树的渲染器。第一个位置参数是根，其余位置参数是孩子。*每个槽位都是 content*
—— `node(...)`、嵌套 `tree(...)`、`cell` / `flow-node` / `process`、纯文本，
全都能塞，还可以混用。

#section-label[Example]

#wide-example(
  ```typ
  #tree(
    node(shape: "circle")[8],
    tree(node(shape: "circle")[3],
      node(shape: "circle")[1],
      node(shape: "circle")[6],
    ),
    tree(node(shape: "circle")[10],
      node(shape: "circle")[9],
      node(shape: "circle")[14],
    ),
    edge-style: "line",   // BST 惯例：对角直线
  )
  ```,
  [
    #tree(
      node(shape: "circle")[8],
      tree(node(shape: "circle")[3],
        node(shape: "circle")[1],
        node(shape: "circle")[6],
      ),
      tree(node(shape: "circle")[10],
        node(shape: "circle")[9],
        node(shape: "circle")[14],
      ),
      edge-style: "line",
    )
  ],
)

#section-label[Parameters]

#params-box("tree",
  ("root",        ("content",)),
  ("..children",  ("content",)),
  ("x-gap",       ("length",)),
  ("y-gap",       ("length",)),
  ("edge-style",  ("auto", "str")),
  ("edge-stroke", ("stroke",)),
  returns: "content",
)

#param-detail("edge-style", ("auto", "str"),
  default: raw("auto", lang: none))[
  连线风格，三种取值：

  - `"elbow"` —— *正交折线*：父底→共享横向汇流线→子顶。目录树、组织架构、
    JSON 层级的标准风格。
  - `"line"` —— *对角直线*：父底→子顶。BST / 堆常用。
  - `auto`（默认）—— 从外层 `tree(...)` 继承，外层没设就用 `"elbow"`。

  *只要在最外层设一次，嵌套子树全部自动继承*，不用每层都写 `edge-style:`。
]

#param-detail("x-gap", ("length",), default: raw("16pt", lang: none))[
  兄弟子树/叶子的水平间距。子树宽时留大点避免视觉拥挤。
]

#param-detail("y-gap", ("length",), default: raw("22pt", lang: none))[
  父子纵向间距。elbow 模式下，`y-gap / 2` 处画那条横向汇流线。
]

#param-detail("edge-stroke", ("stroke",),
  default: raw("0.8pt + palettes.base.border", lang: none))[
  连线笔触。可调粗细 / 颜色 / 虚实，比如用淡灰色弱化背景子树。
]

== 常用模式

#section-label[目录树（elbow 默认）]

elbow 风格的目录树 —— 文件夹黄色、文件蓝色，通过 `fill:` 区分。外层无需设
`edge-style:`，用默认 `"elbow"` 即可。

#wide-example(
  ```typ
  #tree(
    node(fill: palettes.pastel.yellow)[src/],
    node(fill: palettes.pastel.blue)[atoms.typ],
    tree(node(fill: palettes.pastel.yellow)[composites/],
      node(fill: palettes.pastel.blue)[grid.typ],
      node(fill: palettes.pastel.blue)[flex.typ],
    ),
    node(fill: palettes.pastel.blue)[palettes.typ],
  )
  ```,
  [
    #tree(
      node(fill: palettes.pastel.yellow)[src/],
      node(fill: palettes.pastel.blue)[atoms.typ],
      tree(node(fill: palettes.pastel.yellow)[composites/],
        node(fill: palettes.pastel.blue)[grid.typ],
        node(fill: palettes.pastel.blue)[flex.typ],
      ),
      node(fill: palettes.pastel.blue)[palettes.typ],
    )
  ],
)

#section-label[JSON 层级（混合叶子和子树）]

`tree` 的孩子可以 *混搭叶子和子树*。JSON 的"对象→字段、数组→索引"天然这样
组合：

#wide-example(
  ```typ
  #tree(
    node(fill: palettes.status.info.fill)[JSON],
    tree(node[obj], node[a: 1], node[b: "x"]),
    node[null],
    tree(node[arr], node[0], node[1], node[2]),
  )
  ```,
  [
    #tree(
      node(fill: palettes.status.info.fill)[JSON],
      tree(node[obj], node[a: 1], node[b: "x"]),
      node[null],
      tree(node[arr], node[0], node[1], node[2]),
    )
  ],
)

#section-label[与 atoms 互操作]

`tree` 的槽位本来就是 content —— `node` 和 `cell` / `tag` / `process` /
`flow-node` 本质上是同一件东西（都是 `flow-node` 的薄别名或其衍生），可以在同一
棵树里任意混用。下面这棵"支付回调"用 `process` 当根、`cell` / `tag` / `flow-node`
做叶子，没一个 `node(...)`：

#wide-example(
  ```typ
  #tree(
    process[支付回调],
    cell(fill: palettes.status.info.fill)[业务处理],
    tag[副作用],
    flow-node(shape: "stadium", fill: palettes.pastel.red)[退款],
  )
  ```,
  [
    #tree(
      process[支付回调],
      cell(fill: palettes.status.info.fill)[业务处理],
      tag[副作用],
      flow-node(shape: "stadium", fill: palettes.pastel.red)[退款],
    )
  ],
)

#v(4pt)

连线从 root 底部中心引出，落到每个孩子顶部中心 —— 对矩形/胶囊/圆完全贴合；
菱形等带尖角的形状会让端点略微悬空，这时用 `node` 或 `shape: "rect"`。

== 局限

- *非紧致布局* —— 兄弟子树按 `x-gap` 均匀间距，不会像 Reingold-Tilford /
  tidy-tree 那样挤压重叠。密集树建议拆小或手调 `x-gap`。
- *不做自动路由* —— 只有 `"line"` 和 `"elbow"` 两种连线，没有曲线、没有
  绕障。跨层引用用 `edge()` 或直接 `place(line(...))`。
- *仅支持 top-down* —— 横向树用 `rotate(-90deg)` 勉强模拟，但标签也会转。
- *整棵树不可分页* —— 内部用 `block(breakable: false)` 保证绝对定位不被
  切断。超高/超宽的树建议拆成多张。
