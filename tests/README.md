# blockcell snapshot tests

Lightweight visual regression tests for `blockcell`. Each fixture compiles a
tiny Typst document, renders it to PNG, and compares the output against a
committed reference image.

## Layout

```
tests/
├── _template.typ          # shared page setup (import as `/tests/_template.typ`)
├── atoms/                 # Layer 1
│   ├── cell/
│   │   ├── test.typ
│   │   └── ref/
│   │       └── 1.png
│   └── ...
├── containers/            # Layer 2
├── composites/            # Layer 3
├── flows/                 # branch / switch / flow-loop / flow-col
├── seq/                   # seq-lane fixtures
└── states/                # state-chain fixtures
```

- `test.typ` — minimal document, one fixture per behavior.
- `ref/<N>.png` — committed reference image(s). One per page.

## Writing a new fixture

1. Create `tests/<module>/<name>/test.typ`.
2. Start from this template:

   ```typ
   #import "/lib.typ": *
   #import "/tests/_template.typ": setup
   #show: setup

   // Exercise the feature — keep it small and focused.
   #cell[A] #cell[B] #cell[C]
   ```

3. Generate the reference: `./scripts/test.sh --update tests/<module>/<name>`
4. Inspect `tests/<module>/<name>/ref/1.png` before committing.

## Running

```bash
./scripts/test.sh                  # run every fixture, diff against ref/
./scripts/test.sh atoms            # run one subtree
./scripts/test.sh atoms/cell       # run one fixture
./scripts/test.sh --update         # (re)generate ref/ for all fixtures
./scripts/test.sh --update atoms   # update only one subtree
```

Exit code is non-zero if any fixture fails to compile or its rendered output
differs from the committed reference.

## Conventions

- **Keep fixtures tight.** Each test should cover one feature or one
  parameter axis. Combine variants only when they visually belong together.
- **Single page per fixture.** `_template.typ` sets `height: auto` so most
  fixtures produce one page. If you produce multiple pages, commit every
  `ref/<N>.png`.
- **No fonts in the source.** Rely on the runner's environment fonts. This
  avoids snapshots churning when a developer machine doesn't have an exotic
  font installed.
- **Stable content.** Avoid time-based or randomized content. Never embed
  `datetime.today()` etc.

## Known limitations

- **Font rendering is environment-sensitive.** Snapshots rendered on macOS
  may differ from Linux by a few pixels even with the same Typst version.
  Treat unexpected failures on a fresh machine as a font-resolution issue,
  not a regression. The project-level CI should pin a known-good font set
  (follow-up: issue 1.2 in `docs/improvement-report.md`).
- **No perceptual diff yet.** The runner performs byte-exact comparison. A
  future upgrade to [`tytanic`](https://github.com/typst-community/tytanic)
  or ImageMagick's `compare` would give a tolerance knob.

## Why not tytanic?

`tytanic` is the community tool for Typst snapshot tests and would be the
natural next step. It adds a Rust toolchain dependency that not every
contributor has ready to go. The current bash runner works with a
stock `typst` install plus POSIX utilities; switching to tytanic later is
a directory-rename away since the layout above is compatible.
