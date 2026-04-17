// ============================================================================
// Example 2: Rust Cells — Interior Mutability & Shared Ownership
// ============================================================================
// Faithfully reproduces the cheats.rs "Standard Library Types" section:
// UnsafeCell, Cell, RefCell, OnceCell, LazyCell, atomics, Rc, Arc, Mutex, Cow.

#import "../lib.typ": *

#set page(width: 780pt, height: auto, margin: 20pt)
#set text(size: 10pt)

#let C = palettes.rust
#let sub = sub-label

// Type cell (salmon, generic T)
#let tc(body, ..args) = cell(body, fill: C.any, ..args)

// Cell-wrapped: gold wrap around a cell (matching .celled CSS — double border)
#let celled(body, fill: C.any, ..args) = wrap(
  stroke: 3pt + C.cell-border,
  cell(body, fill: fill, ..args),
)

// Gold outer wrapper for cell-family enums (OnceCell, LazyCell)
#let cell-enum-wrap(body) = wrap(stroke: 3pt + C.cell-border, radius: 5pt, inset: 4pt, body)

// Pointer & sized fields
#let ptr-field(l: [ptr]) = cell(fill: C.ptr, width: 55pt)[#l#sub[2/4/8]]
#let sized-field(l: [len]) = cell(fill: C.sized, width: 55pt)[#l#sub[2/4/8]]
#let payload-field(l: [meta]) = cell(fill: rgb("#F5F5F5"), dash: "dashed", width: 55pt)[#l#sub[2/4/8]]

// =========================================================================

= Cells

#v(8pt)

// All Cell schemas flow inline (horizontal), matching the original
#schema(title: raw("UnsafeCell<T>"), desc: [Magic type allowing\ aliased mutability.])[
  #region(fill: C.cell-bg)[
    #tc([`T`], expandable: true)
  ]
]#schema(title: raw("Cell<T>"), desc: [Allows `T`'s\ to move in\ and out.])[
  #region[
    #celled([`T`], expandable: true)
  ]
]#schema(title: raw("RefCell<T>"), desc: [Also support dynamic\ borrowing of `T`. Like `Cell` this\ is `Send`, but not `Sync`.])[
  #region[
    #celled([`borrowed`], fill: C.sized)
    #celled([`T`], expandable: true)
  ]
]#schema(title: raw("OnceCell<T>"), desc: [Initialized at most once.])[
  #cell-enum-wrap[
    #region(fill: C.enum-bg, width: 120pt)[
      #set align(left)
      #tag[`Tag`]
    ]
    #divider(body: [or])
    #region(fill: C.enum-bg, width: 120pt)[
      #set align(left)
      #tag[`Tag`]
      #tc([`T`], width: 55pt)
    ]
  ]
]#schema(title: raw("LazyCell<T, F>"), desc: [Initialized on first access.])[
  #cell-enum-wrap[
    #region(fill: C.enum-bg)[
      #set align(left)
      #tag[`Tag`]
      #tc([`Uninit<F>`])
    ]
    #divider(body: [or])
    #region(fill: C.enum-bg)[
      #set align(left)
      #tag[`Tag`]
      #tc([`Init<T>`])
    ]
    #divider(body: [or])
    #region(fill: C.enum-bg)[
      #set align(left)
      #tag[`Tag`]
      #tc([`Poisoned`])
    ]
  ]
]

#v(16pt)

= Standard Library Types

#v(8pt)

#schema(title: raw("ManuallyDrop<T>"), desc: [Prevents `T::drop()`\ from being called.])[
  #region[
    #tc([`T`], expandable: true, width: 70pt)
  ]
]#schema(title: raw("AtomicUsize"), desc: [Other atomics similarly.])[
  #region(fill: C.atomic.lighten(60%))[
    #cell(fill: C.atomic, width: 55pt)[`usize`#sub[2/4/8]]
  ]
]#schema(title: raw("Option<T>"), desc: [Tag may be omitted for\ certain `T`, e.g., `NonNull`.])[
  #region(fill: C.enum-bg)[
    #set align(left)
    #tag[`Tag`]
  ]
  #divider(body: [or])
  #region(fill: C.enum-bg)[
    #tag[`Tag`]
    #tc([`T`], width: 70pt)
  ]
]#schema(title: raw("Result<T, E>"), desc: [Either some error `E`\ or value of `T`.])[
  #region(fill: C.enum-bg)[
    #set align(left)
    #tag[`Tag`]
    #tc([`E`], width: 35pt)
  ]
  #divider(body: [or])
  #region(fill: C.enum-bg)[
    #set align(left)
    #tag[`Tag`]
    #tc([`T`], width: 70pt)
  ]
]#schema(title: raw("MaybeUninit<T>"), desc: [Only legal way to work with\ uninitialized data.])[
  #region(fill: C.enum-bg)[
    #cell(fill: C.uninit, width: 70pt)[`Undefined`]
  ]
  #divider(body: [unsafe or])
  #region(fill: C.enum-bg)[
    #tc([`T`], width: 70pt)
  ]
]

#v(16pt)

= Shared Ownership

If the type does not contain a `Cell` for `T`, these are often combined with
one of the Cell types above to allow shared de-facto mutability.

#v(8pt)

#linked-schema(
  title: raw("Rc<T>"),
  width: 160pt,
  desc: [Share ownership of `T` in same thread. Needs nested `Cell` or `RefCell` to allow mutation.],
  fields: (ptr-field(), payload-field()),
  target-fill: C.heap,
  target-label: "(heap)",
  target-width: 130pt,
  {
    celled([`strng`], fill: C.sized)
    celled([`weak`], fill: C.sized)
    v(2pt)
    tc([`T`], expandable: true)
  },
)#linked-schema(
  title: raw("Arc<T>"),
  width: 160pt,
  desc: [Same, but allow sharing between threads if `T` is `Send` and `Sync`.],
  fields: (ptr-field(), payload-field()),
  target-fill: C.heap,
  target-label: "(heap)",
  target-width: 130pt,
  {
    cell([`strng`], fill: C.sized, stroke: 3pt + C.atomic)
    cell([`weak`], fill: C.sized, stroke: 3pt + C.atomic)
    v(2pt)
    tc([`T`], expandable: true)
  },
)#schema(title: [#raw("Mutex<T>") / #raw("RwLock<T>")], width: 200pt, desc: [Inner fields depend on platform. Needs `Arc` to share between decoupled threads.])[
  #region[
    #cell(fill: rgb("#F5F5F5"), dash: "dashed")[`inner`]
    #cell([`poison`], fill: C.sized, stroke: 3pt + C.atomic)
    #celled([`T`], expandable: true)
  ]
]#schema(title: raw("Cow<'a, T>"), width: 140pt, desc: [Holds read-only reference to some `T`, or owns its `ToOwned` analog.])[
  #region(fill: C.enum-bg, width: 120pt)[
    #set align(left)
    #tag[`Tag`]
    #tc([`T::Owned`], width: 60pt)
  ]
  #divider(body: [or])
  #region(fill: C.enum-bg, width: 120pt)[
    #set align(left)
    #tag[`Tag`]
    #cell(fill: C.ptr, width: 40pt)[`ptr`#sub[2/4/8]]
  ]
  #connector()
  #align(center, target(tc([`T`], expandable: true)))
]
