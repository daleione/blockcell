#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#entry-list(
  label: "(vtable)",
  ([`*Drop::drop(&mut T)`], [`size`], [`align`], [`*Trait::f(&T, …)`]),
)
