# Tools Reference

All tools live in `tools/`. Run from the project root with `node tools/<script>` or
from inside `tools/` directly with `node <script>` — either works since all paths are
`__dirname`-relative.

---

## Rename key format

Three formats are used throughout:

| Format | Example | Applies to |
|--------|---------|------------|
| `script.Q` | `blacksmith.Q4S8` | Function or member: replaces in defining script + all inheritors |
| `script.fnQ:localQ` | `blacksmith.Q4S8:Q57Q` | Local/param: replaces only within `Q4S8`'s body in `blacksmith.m` |
| `Q` (bare) | `Q49H` | Global: replaces in all scripts (legacy, avoid for new rounds) |

---

## Extraction

### `extract-symbols.js`

Parses all `.m` files, builds the symbol graph, writes `symbols.json`.

```
node tools/extract-symbols.js [--scripts-dir <dir>] [--out <file>]
```

Defaults: `scripts.interpreted/` → `symbols.json`.

Determines leaf status for every Q-symbol: a function is a leaf when all Q-calls
in its body resolve to named symbols in `renames/renames.json`.

---

## Naming prompt generation

### `gen-naming-3.js`

Generates batch prompts for leaf **functions**. Output goes to `step-N.naming/prompts/`.

```
node tools/gen-naming-3.js [--round N] [--batch-size 8] [--scripts-dir <dir>]
                            [--out-dir <dir>] [--symbols <file>] [--renames <file>]
                            [--builtins <file>]
```

Includes: function source, up to 5 call sites (±8 lines each), engine API reference.

### `gen-naming-members.js`

Generates batch prompts for Q-coded **member variables**. Groups by script.

```
node tools/gen-naming-members.js [--round 9] [--batch-size 6] [--scripts-dir <dir>]
                                  [--out-dir <dir>]
```

### `gen-naming-locals.js`

Generates one prompt per function for Q-coded **locals and params**.

```
node tools/gen-naming-locals.js [--round 10] [--scripts-dir <dir>] [--out-dir <dir>]
```

Includes the full function source plus inheritance chain for context.

---

## Preview generation

### `regen-preview-2.js`

Regenerates the HTML review page from `symbols.json` + agent proposals.

```
node tools/regen-preview-2.js [--proposals <file>] [--round N] [--out <file>]
```

Default proposals: `/tmp/prev_proposals.json`. Output: `preview-round-N.html`.

### `regen-preview-members.js`

Same as above but for member variable renames; groups by script.

```
node tools/regen-preview-members.js [--proposals <file>] [--round 9] [--out <file>]
```

### `gen-preview-2.js`

Older, hardcoded variant for round 2 wave results. Reads from `/tmp/r2_wave*.json`.
Prefer `regen-preview-2.js` for new rounds.

---

## Critique

### `gen-critique.js`

Builds critique prompts for a set of raw proposals. Groups by defining script.

```
node tools/gen-critique.js renames/renames-N-raw.json [--round N] [--batch-size 4]
                            [--scripts-dir <dir>] [--symbols <file>] [--out-dir <dir>]
```

Output: `step-N.critique/prompts/batch-NNN.txt`. Agents write `.critique` JSON files
back to `step-N.critique/`.

### `compile-critique.js`

Merges agent verdicts into a final rename file.

```
node tools/compile-critique.js renames/renames-N-raw.json [--round N]
                                [--critique-dir <dir>] [--out <file>]
```

Default output: `renames/renames-N.json`. Writes a `diff.txt` listing changed entries.

---

## Applying renames

### `apply-renames.js`

Applies a rename file to all scripts and merges into the cumulative mapping.

```
node tools/apply-renames.js renames/renames-N.json [--scripts-dir <dir>] [--mark-unint]
```

- Handles all three key formats in the correct order (scoped → qualified → bare)
- Propagates qualified renames to inheriting scripts
- `--mark-unint` prefixes unresolved leaves with `UNINT_`
- Merges into `renames/renames.json`

### `apply-renames-locals.js`

Applies local/param renames using scoped strategy.

```
node tools/apply-renames-locals.js [--input renames/renames-N-locals.json]
                                    [--scripts-dir <dir>] [--renames <file>] [--dry-run]
```

Keys are `script.qualified.QXXX`. If all functions in a script agree on a name for a
Q-code → global replace within script; otherwise → scoped replace per function body.

---

## Verification

### `verify-renames.js`

Replays `renames/renames.json` forward against originals and diffs against working copies.

```
node tools/verify-renames.js [--orig-dir <dir>] [--scripts-dir <dir>] [--fix]
```

Default orig-dir: `../rundir/scripts.wombat`. Exits 0 on clean match, 1 on mismatch.
`--fix` overwrites working copies with the expected output.

### `reverse-verify.js`

Applies the inverse mapping to working copies and checks the result matches originals.
Proves that `renames/renames.json` is fully reversible.

```
node tools/reverse-verify.js [--orig-dir <dir>] [--scripts-dir <dir>] [--out-dir <dir>]
```

Default out-dir: `/tmp/wombat-reversed`.

---

## Utilities

### `trim-prompts.js`

Strips unused ENGINE API entries from naming prompts to reduce token count.

```
node tools/trim-prompts.js [--in-dir step-10.naming] [--out-dir step-10b] [--batch <NNN>]
```

Copies existing results alongside trimmed prompts.

### `spot-check-inheritors.js`

Validates that a renamed script's symbols are used by their new names in all inheritors.

```
node tools/spot-check-inheritors.js <script-name> [--scripts-dir <dir>]
```

Reports Q-code hits in inheritor files (should be zero after a correct rename).

---

## Orchestration

### `convert-scripts.bash`

End-to-end pipeline: copy scripts → apply renames → verify reversibility → re-extract.

```
bash tools/convert-scripts.bash <SCRIPTS-DIR> <RENAMES-JSON> <DESTINATION>
```

Useful for applying a complete rename set to a fresh copy of the original scripts and
confirming the result is correct in one shot.
