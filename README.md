# wombat-interpret-minimal

Lean toolchain for progressively renaming Q-style obfuscated identifiers across the
1,633 Wombat source scripts from the June 1998 Ultima Online shard.

Q-style names (`Q[0-9A-Z]{3}`, e.g. `Q4S8`, `Q49H`) are OSI-internal identifiers with
no readable meaning. This project resolves them iteratively: each round names the current
set of "leaf" functions (those whose Q-call dependencies are already resolved), which
unlocks the next tier.

---

## Basic Usage

To apply all the changed to the scripts:

```
bash ./convert-scripts.bash ../rundir-wip/scripts.wombat /tmp/uo/wip
```

You'll find:

- `/tmp-uo/wip/symbols.json`: contains inheritance info on the scripts
- `/tmp-uo/wip/renames.json`: a copy of the renames applied
- `/tmp-uo/wip/scripts.interpreted`: scripts where all the renames have been applied
- `/tmp-uo/wip/scripts.enum`: scripts where all the enums have also been substituted

---

## Layout

```
scripts.interpreted/   Working copies of the 1,633 .m source files (renamed in-place)
renames/
  renames.json         Cumulative approved renames (~2,200 entries across all rounds)
  renames-N-raw.json   Agent proposals for round N (intermediate)
  renames-N.json       Final renames for round N after critique
symbols.json           Current symbol graph — regenerated each round, not committed
tools/                 All processing scripts (extraction, naming, preview, apply, verify)
docs/                  Detailed documentation
```

Originals are at `../rundir/scripts.wombat/` and are never modified.

---

## Applying renames

To apply an existing rename file to the working scripts:

```bash
# 1. Generate symbol graph
node tools/extract-symbols.js

# 2. Apply the rename file (merges into renames/renames.json)
node tools/apply-renames.js renames/renames-N.json

# 2b. apply the local renames
node tools/apply-renames-local.js ...

# 3. Verify correctness (round-trip against originals)
node tools/verify-renames.js
```

To apply a complete set end-to-end (copy → apply → verify) in one shot:

```bash
bash tools/convert-scripts.bash <scripts-dir> <renames-file> <destination>
```

---

## Running a naming round

1. Extract symbols: `node tools/extract-symbols.js`
2. Generate prompts: `node tools/gen-naming-3.js --round N`
3. Spawn naming agents on each `step-N.naming/prompts/batch-NNN.txt`
4. Collect results → `renames/renames-N-raw.json`
5. Preview: `node tools/regen-preview-2.js --proposals renames/renames-N-raw.json --round N`
6. (Optional) Critique: `node tools/gen-critique.js` + `node tools/compile-critique.js`
7. Apply: `node tools/apply-renames.js renames/renames-N.json`
8. Verify: `node tools/verify-renames.js && node tools/reverse-verify.js`
9. Commit and repeat

---

## Enumerations

```
node tools/gen-scripts-enum.mjs \
  --enums   ../wombat-ext/compiler/enumerations.h \
  --annots  ../wombat-ext/compiler/enum-annotations.txt \
  --in      ./scripts \
  --out     ./scripts-enum

```

---

## Stats (baseline)

- 1,633 scripts
- 1,182 Q-symbols (functions, members, locals, params)
- 542 leaf functions at baseline
- ~2,200 entries in `renames/renames.json` after current rounds

---

## Documentation

- [docs/workflow.md](docs/workflow.md) — full round-by-round process
- [docs/tools-reference.md](docs/tools-reference.md) — CLI flags and defaults for every tool
- [docs/naming-conventions.md](docs/naming-conventions.md) — snake_case rules with examples
