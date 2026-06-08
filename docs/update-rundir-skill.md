# Skill: Update renames.json from rundir changes

When `rundir-wip` advances beyond the commit recorded in `renames/rundir.pin`, new or
modified Wombat scripts may carry Q-coded symbols that have never been named. This skill
detects those scripts, expands the set to every inheritor, processes remaining Q-codes
through naming agents, updates `renames/renames.json`, and advances the pin.

**All work happens under `wombat-interpret-minimal/` unless stated otherwise.**
**Never write to `rundir/` or `rundir-wip/` — both are read sources.**
**Never overwrite existing files — create new WIP directories.**

---

## Prerequisites

| Item | Path | Notes |
|------|------|-------|
| Pinned commit | `renames/rundir.pin` | One SHA on one line |
| Working repo | `../rundir-wip/` | Updated via `git -C ../rundir-wip pull` before running |
| Cumulative renames | `renames/renames.json` | Never modified until Step 9 |
| Tools | `tools/` | All tools referenced below live here |

---

## Step 0 — Check for changes

```bash
PINNED=$(cat renames/rundir.pin | tr -d '[:space:]')
CURRENT=$(git -C ../rundir-wip rev-parse HEAD)
echo "Pinned : $PINNED"
echo "Current: $CURRENT"
```

If `PINNED == CURRENT`, print "rundir-wip is at the pinned commit — nothing to process."
and **stop**. This is the normal state when no upstream changes have arrived.

---

## Step 1 — Identify changed scripts

List every `scripts.wombat/*.m` path that changed (added, modified, deleted) between the
pin and the current rundir-wip HEAD, in chronological commit order:

```bash
git -C ../rundir-wip log --reverse --name-only --format="" \
    "${PINNED}..${CURRENT}" -- 'scripts.wombat/' \
  | grep '\.m$' \
  | sort -u \
  > /tmp/wombat-changed-paths.txt

# Convert to bare script names (no path, no extension)
sed 's|scripts\.wombat/||; s/\.m$//' /tmp/wombat-changed-paths.txt \
  > /tmp/wombat-changed-scripts.txt

echo "Changed scripts:"
cat /tmp/wombat-changed-scripts.txt
```

Scripts listed as deleted still need checking — their inheritors may have been removed too,
but if the inheritor file still exists it must be re-verified.

---

## Step 2 — Expand to all inheritors

Build a transitive closure: every script that inherits (directly or indirectly) from any
changed script must also be processed, because qualified renames propagate down the tree.

Run this Node.js script (save it to `/tmp/find-inheritors.mjs` and execute with
`node /tmp/find-inheritors.mjs`):

```js
import { readFileSync, readdirSync } from 'fs';
import { basename } from 'path';

const SCRIPTS_DIR = '../rundir-wip/scripts.wombat';
const changed     = readFileSync('/tmp/wombat-changed-scripts.txt', 'utf8')
                      .trim().split('\n').filter(Boolean);

// Parse every script for its "inherits <parent>;" declaration.
// child → parent  (string → string, using bare script name without .m)
const parentOf = {};
for (const f of readdirSync(SCRIPTS_DIR).filter(f => f.endsWith('.m'))) {
  const src  = readFileSync(`${SCRIPTS_DIR}/${f}`, 'utf8');
  const m    = src.match(/^\s*inherits\s+(\S+)\s*;/m);
  if (m) parentOf[basename(f, '.m')] = m[1];
}

// Transitive closure: collect changed + all descendants
const affected = new Set(changed);
let grew = true;
while (grew) {
  grew = false;
  for (const [child, parent] of Object.entries(parentOf)) {
    if (affected.has(parent) && !affected.has(child)) {
      affected.add(child);
      grew = true;
    }
  }
}

// Topological sort: parents before children
const sorted = [];
const visited = new Set();
function visit(s) {
  if (visited.has(s)) return;
  visited.add(s);
  if (parentOf[s]) visit(parentOf[s]);
  sorted.push(s);
}
for (const s of affected) visit(s);

import { writeFileSync } from 'fs';
writeFileSync('/tmp/wombat-affected-sorted.txt', sorted.join('\n') + '\n');
console.log(`Affected: ${sorted.length} scripts (${changed.length} changed + ${sorted.length - changed.length} inheritors)`);
sorted.forEach(s => console.log('  ', s));
```

---

## Step 3 — Create WIP directory

```bash
STAMP=$(date +%Y%m%d-%H%M%S)
SHORT=$(echo "$CURRENT" | cut -c1-7)
WIP="wip/rundir-update-${STAMP}-${SHORT}"
mkdir -p "$WIP/scripts"
echo "WIP: $WIP"
```

Copy every affected script from `rundir-wip/scripts.wombat/` into `$WIP/scripts/`:

```bash
while IFS= read -r script; do
  src="../rundir-wip/scripts.wombat/${script}.m"
  if [ -f "$src" ]; then
    cp "$src" "$WIP/scripts/${script}.m"
  else
    echo "WARNING: $src not found (script may have been deleted)"
  fi
done < /tmp/wombat-affected-sorted.txt
echo "Copied $(ls $WIP/scripts/ | wc -l) scripts to $WIP/scripts/"
```

---

## Step 4 — Apply existing renames to WIP copies

Replay `renames/renames.json` forward against the originals and write the correctly
renamed versions into `$WIP/scripts/`. Uses `verify-renames.js --fix`, which only reads
the renames file — it does **not** modify `renames.json`.

```bash
node tools/verify-renames.js \
  --orig-dir  ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts" \
  --renames   renames/renames.json \
  --fix
```

Exit code 0 = all scripts in `$WIP/scripts/` now match the expected renamed state.
Non-zero = a script diverged from what the renames produce; **stop and investigate**.

---

## Step 5 — Extract symbols for WIP scripts

```bash
node tools/extract-symbols.js \
  --scripts-dir "$WIP/scripts" \
  --out         "$WIP/symbols.json"
```

Find any Q-coded symbols that are **not** yet covered by `renames/renames.json`:

```bash
node - <<'EOF'
const fs = require('fs');
const syms    = JSON.parse(fs.readFileSync(process.env.WIP + '/symbols.json', 'utf8'));
const renames = JSON.parse(fs.readFileSync('renames/renames.json', 'utf8'));

const unresolved = [];
// syms.functions: { "script.QXXX": { ... }, ... }
for (const key of Object.keys(syms.functions || {})) {
  if (!renames[key]) unresolved.push(key);
}
// syms.members, syms.locals — add similar loops if needed
console.log('Unresolved Q-codes:', unresolved.length);
unresolved.slice(0, 20).forEach(k => console.log(' ', k));
fs.writeFileSync(process.env.WIP + '/unresolved.json',
  JSON.stringify(unresolved, null, 2));
EOF
```

(Export `WIP` to the environment before running: `export WIP`)

If `unresolved.length == 0`, **skip to Step 7**.

---

## Step 6 — Spawn naming agents for unresolved Q-codes

Generate naming prompts (functions only; add `--members` / locals pass if needed):

```bash
node tools/gen-naming-3.js \
  --scripts-dir "$WIP/scripts" \
  --symbols     "$WIP/symbols.json" \
  --renames     renames/renames.json \
  --out-dir     "$WIP/naming-prompts" \
  --round       upd
```

Spawn one naming agent per prompt file in `$WIP/naming-prompts/`. Agents can run in
parallel (see `agents.md` for wave protocol). Each agent:
- Reads `$WIP/naming-prompts/batch-NNN.txt`
- Returns JSON: `{ "script.QXXX": "snake_case_name", ... }`
- Writes result to `$WIP/naming-results/batch-NNN.json`

Follow naming conventions in `docs/naming-conventions.md`.
Run critique pass (see `workflow.md §5`) if this is a large batch (>20 functions).

After all agents complete, merge into a single proposals file:

```bash
node -e "
const fs = require('fs');
const dir    = '$WIP/naming-results';
const merged = {};
for (const f of fs.readdirSync(dir).filter(f => f.endsWith('.json')))
  Object.assign(merged, JSON.parse(fs.readFileSync(dir + '/' + f)));
fs.writeFileSync('$WIP/renames-upd-raw.json', JSON.stringify(merged, null, 2) + '\n');
console.log('Merged', Object.keys(merged).length, 'new renames');
"
```

After human review / critique, finalize as `$WIP/renames-upd.json`.

---

## Step 7 — Build fresh final script copies and apply all renames

Copy **all** scripts from `rundir-wip/scripts.wombat/` to a fresh destination
(not just the affected ones — the final set must be complete for verification):

```bash
mkdir -p "$WIP/scripts.final"
cp ../rundir-wip/scripts.wombat/*.m "$WIP/scripts.final/"
```

Apply the existing `renames/renames.json` to the full fresh copy:

```bash
node tools/verify-renames.js \
  --orig-dir    ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" \
  --renames     renames/renames.json \
  --fix
```

If new renames were produced in Step 6, layer them on top (this also merges them into
`renames/renames.json` — that is intentional at this step):

```bash
# Only run if Step 6 produced renames-upd.json
node tools/apply-renames.js "$WIP/renames-upd.json" \
  --scripts-dir "$WIP/scripts.final"
```

---

## Step 8 — Verify round-trip

**Forward pass** — confirm every script in `scripts.final` exactly matches what
replaying `renames/renames.json` against originals produces:

```bash
node tools/verify-renames.js \
  --orig-dir    ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" \
  --renames     renames/renames.json
# Must exit 0
```

**Reverse pass** — apply the inverse mapping; result must match originals byte-for-byte:

```bash
node tools/reverse-verify.js \
  --orig-dir    ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" \
  --out-dir     "$WIP/scripts.reversed"
# Must exit 0
```

If either check fails, **do not advance the pin**. Investigate the mismatch, fix
`renames/renames.json` or the new renames, and re-run from Step 7.

---

## Step 9 — Advance the pin

Both verification passes must have exited 0 before this step.

```bash
git -C ../rundir-wip rev-parse HEAD > renames/rundir.pin
echo "Pin advanced to: $(cat renames/rundir.pin)"
```

---

## Step 10 — Record in LOG.md

Append a brief entry at the top of the project `LOG.md`:

```
## <YYYY-MM-DD> — rundir update <short-hash>
- Changed scripts: <comma-separated list>
- Inheritors included: <count>
- New renames added: <count from Step 6, or 0>
- Verification: PASS (forward + reverse)
- WIP dir: wombat-interpret-minimal/<WIP>
```

---

## Quick-reference command sequence

```bash
# From wombat-interpret-minimal/
PINNED=$(cat renames/rundir.pin | tr -d '[:space:]')
CURRENT=$(git -C ../rundir-wip rev-parse HEAD)

[ "$PINNED" = "$CURRENT" ] && echo "Up to date." && exit 0

STAMP=$(date +%Y%m%d-%H%M%S)
SHORT=$(echo "$CURRENT" | cut -c1-7)
WIP="wip/rundir-update-${STAMP}-${SHORT}"
mkdir -p "$WIP/scripts" "$WIP/scripts.final"

# Steps 1-2: find changed + inheritors → /tmp/wombat-affected-sorted.txt
git -C ../rundir-wip log --reverse --name-only --format="" "${PINNED}..${CURRENT}" -- 'scripts.wombat/' \
  | grep '\.m$' | sort -u | sed 's|scripts\.wombat/||;s/\.m$//' > /tmp/wombat-changed-scripts.txt
node /tmp/find-inheritors.mjs   # see Step 2 for script

# Step 3: copy affected scripts
while IFS= read -r s; do
  [ -f "../rundir-wip/scripts.wombat/${s}.m" ] && cp "../rundir-wip/scripts.wombat/${s}.m" "$WIP/scripts/"
done < /tmp/wombat-affected-sorted.txt

# Step 4: apply existing renames to WIP copies
node tools/verify-renames.js --orig-dir ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts" --renames renames/renames.json --fix

# Step 5: extract symbols, find unresolved
node tools/extract-symbols.js --scripts-dir "$WIP/scripts" --out "$WIP/symbols.json"
# (check WIP/unresolved.json — if empty, skip to Step 7)

# Step 6 (if unresolved): generate prompts, spawn agents, merge results
node tools/gen-naming-3.js --scripts-dir "$WIP/scripts" --symbols "$WIP/symbols.json" \
  --renames renames/renames.json --out-dir "$WIP/naming-prompts" --round upd
# ... spawn agents, write WIP/naming-results/batch-NNN.json ...
# ... merge into WIP/renames-upd.json ...

# Step 7: fresh full copy + apply all renames
cp ../rundir-wip/scripts.wombat/*.m "$WIP/scripts.final/"
node tools/verify-renames.js --orig-dir ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" --renames renames/renames.json --fix
# if new renames: node tools/apply-renames.js "$WIP/renames-upd.json" --scripts-dir "$WIP/scripts.final"

# Step 8: verify
node tools/verify-renames.js --orig-dir ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" --renames renames/renames.json
node tools/reverse-verify.js --orig-dir ../rundir-wip/scripts.wombat \
  --scripts-dir "$WIP/scripts.final" --out-dir "$WIP/scripts.reversed"

# Step 9: advance pin (only on clean verification)
git -C ../rundir-wip rev-parse HEAD > renames/rundir.pin
```
