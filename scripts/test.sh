#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# blockcell snapshot test runner
# ----------------------------------------------------------------------------
# Compiles every tests/**/test.typ to PNG and byte-compares against
# tests/**/ref/*.png. Use --update to (re)generate the ref/ directory.
#
# Usage:
#   scripts/test.sh                 # run all fixtures
#   scripts/test.sh atoms           # run fixtures under tests/atoms
#   scripts/test.sh atoms/cell      # run one fixture
#   scripts/test.sh --update        # update every fixture's ref/
#   scripts/test.sh --update atoms  # update only a subtree
# ----------------------------------------------------------------------------

set -euo pipefail

# Resolve project root (one dir above scripts/).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(dirname "$script_dir")"
cd "$root_dir"

update=0
filter=""
for arg in "$@"; do
  case "$arg" in
    --update|-u) update=1 ;;
    -h|--help)
      sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "error: unknown flag '$arg'" >&2
      exit 2
      ;;
    *) filter="$arg" ;;
  esac
done

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst not on PATH" >&2
  exit 2
fi

# Discover fixtures (skip the _template helper).
all_fixtures=()
while IFS= read -r line; do
  all_fixtures+=("$line")
done < <(find tests -type f -name 'test.typ' -not -path 'tests/_template.typ' | sort)

if [[ -z "$filter" ]]; then
  fixtures=("${all_fixtures[@]}")
else
  fixtures=()
  for f in "${all_fixtures[@]}"; do
    case "$f" in
      "tests/$filter"/*|"tests/$filter/test.typ") fixtures+=("$f") ;;
    esac
  done
  if [[ ${#fixtures[@]} -eq 0 ]]; then
    echo "error: no fixtures matched 'tests/$filter'" >&2
    exit 2
  fi
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

pass=0
fail=0
update_count=0
failed_names=()

for fixture in "${fixtures[@]}"; do
  # tests/<module>/<name>/test.typ → tests/<module>/<name>
  dir="$(dirname "$fixture")"
  name="${dir#tests/}"
  ref_dir="$dir/ref"
  fixture_tmp="$tmp_dir/${name//\//_}"
  mkdir -p "$fixture_tmp"
  out_tmpl="$fixture_tmp/page-{p}.png"

  # Compile — fail fast on syntax errors.
  if ! typst compile --root . --format png --ppi 144 "$fixture" "$out_tmpl" \
        >"$tmp_dir/compile.log" 2>&1; then
    echo "FAIL [compile] $name"
    sed 's/^/  /' "$tmp_dir/compile.log"
    failed_names+=("$name (compile)")
    ((fail++)) || true
    continue
  fi

  # Gather the pages Typst produced (isolated per-fixture dir, so the glob
  # is unambiguous).
  pages=()
  while IFS= read -r line; do
    pages+=("$line")
  done < <(ls "$fixture_tmp"/page-*.png 2>/dev/null | sort)
  if [[ ${#pages[@]} -eq 0 ]]; then
    # Single-page: Typst may have written exactly the template name.
    single="${out_tmpl/\{p\}/1}"
    [[ -f "$single" ]] && pages=("$single")
  fi
  if [[ ${#pages[@]} -eq 0 ]]; then
    echo "FAIL [no output] $name"
    failed_names+=("$name (no output)")
    ((fail++)) || true
    continue
  fi

  if [[ $update -eq 1 ]]; then
    rm -rf "$ref_dir"
    mkdir -p "$ref_dir"
    i=1
    for page in "${pages[@]}"; do
      cp "$page" "$ref_dir/$i.png"
      ((i++)) || true
    done
    echo "UPDATE     $name  (${#pages[@]} page$([[ ${#pages[@]} -ne 1 ]] && echo s))"
    ((update_count++)) || true
    continue
  fi

  # Diff mode.
  if [[ ! -d "$ref_dir" ]]; then
    echo "FAIL [no ref] $name   (run: scripts/test.sh --update $name)"
    failed_names+=("$name (no ref)")
    ((fail++)) || true
    continue
  fi

  diff_ok=1
  i=1
  for page in "${pages[@]}"; do
    ref="$ref_dir/$i.png"
    if [[ ! -f "$ref" ]] || ! cmp -s "$page" "$ref"; then
      diff_ok=0
      break
    fi
    ((i++)) || true
  done
  # Detect extra ref pages (e.g. fixture dropped a page).
  ref_count="$(find "$ref_dir" -maxdepth 1 -name '*.png' -type f | wc -l | tr -d ' ')"
  if [[ $ref_count -ne ${#pages[@]} ]]; then
    diff_ok=0
  fi

  if [[ $diff_ok -eq 1 ]]; then
    echo "PASS       $name"
    ((pass++)) || true
  else
    echo "FAIL [diff] $name   (review + scripts/test.sh --update $name to accept)"
    failed_names+=("$name (diff)")
    ((fail++)) || true
  fi
done

echo
if [[ $update -eq 1 ]]; then
  echo "Updated $update_count fixture$([[ $update_count -ne 1 ]] && echo s)."
  exit 0
fi

echo "$pass passed, $fail failed (of ${#fixtures[@]} fixture$([[ ${#fixtures[@]} -ne 1 ]] && echo s))"
if [[ $fail -gt 0 ]]; then
  printf '  - %s\n' "${failed_names[@]}"
  exit 1
fi
