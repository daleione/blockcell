#import "/lib.typ": *
#import "/tests/_template.typ": setup
#show: setup

#lane(
  name: [Thread 1],
  items: (
    (label: [`Mutex<u32>`], fill: palettes.pastel.green),
    (label: [`Cell<u32>`],  fill: palettes.pastel.yellow),
    (label: [`Rc<u32>`],    fill: palettes.pastel.orange),
  ),
)
