# Wombat Interpretation — Round Workflow

Progressive disambiguation of all Q-style symbols across the 1,633 Wombat source scripts.
Each round resolves a batch of leaf symbols; newly named functions unlock the next tier.

Originals live at `../rundir/scripts.wombat/` and are **never modified**.

---

## Directory layout

```
scripts.interpreted/   Working copies of plain-text .m files (renamed in-place each round)
renames/
  renames.json         Cumulative approved renames (grows each round, never shrinks)
  renames-N-raw.json   Agent proposals for round N (intermediate, not committed)
  renames-N.json       Final renames for round N after critique (committed)
symbols.json           Current symbol graph (regenerated each round, not committed)
preview-round-N.html   Agent-proposed review page (committed — used for human review)
tools/                 All processing scripts (see docs/tools-reference.md)
```

---

## Round workflow

### 1 — Extract symbols

```
node tools/extract-symbols.js
```

Reads all `scripts.interpreted/*.m`, writes `symbols.json`:
- All Q-style symbols with kind, type, params, q_calls, q_locals
- Inheritance graph
- Leaf status: a Q-named symbol where all Q-calls in its body resolve to named symbols

### 2 — Generate naming prompts

For **functions** (rounds 1–N):
```
node tools/gen-naming-3.js --round N --batch-size 8
```

For **member variables**:
```
node tools/gen-naming-members.js --round N --batch-size 6
```

For **local variables and params**:
```
node tools/gen-naming-locals.js --round N
```

Each script writes one prompt file per batch to `step-N.naming/prompts/batch-NNN.txt`.

### 3 — Spawn naming agents

For each prompt file, spawn a Claude agent. The agent reads the prompt and returns a JSON object:

```json
{ "script.Q4S8": "collect_metals", "script.Q4S8:Q57Q": "container" }
```

Keys follow the rename key format (see [tools-reference.md](tools-reference.md#rename-key-format)).
Collect all agent results and merge into `renames/renames-N-raw.json`.

All agents for a round can be spawned in parallel.

### 4 — Generate preview HTML

```
node tools/regen-preview-2.js --proposals renames/renames-N-raw.json --round N
```

Produces `preview-round-N.html` — a self-contained review page with:
- **Source block** (foldable, verbatim with tabs/newlines, dark theme)
- **Call sites** (foldable, ±10 lines, matching line highlighted in amber)
- **Renames table**: proposed name + override input field (sessionStorage-persisted)
- **Export button**: downloads the final JSON using overrides where set, proposed names otherwise

For member variables use `regen-preview-members.js --round N`.

### 5 — (Optional) Critique pass

Generate critique prompts:
```
node tools/gen-critique.js renames/renames-N-raw.json --round N
```

Spawn critique agents on `step-N.critique/prompts/*.txt`. Each agent returns verdicts
(`accept` or `suggest` with an alternative). Then compile:
```
node tools/compile-critique.js renames/renames-N-raw.json --round N
```

Outputs `renames/renames-N.json` with suggestions applied where the agent flagged them.

### 6 — Apply renames

```
node tools/apply-renames.js renames/renames-N.json
```

- Updates all `scripts.interpreted/*.m` in-place using inheritance-aware substitution
- Merges new entries into cumulative `renames/renames.json`
- Optional `--mark-unint` prefixes unapproved leaves with `UNINT_`

For local variable renames:
```
node tools/apply-renames-locals.js --input renames/renames-N-locals.json
```

### 7 — Verify

Round-trip correctness check (replays renames against originals):
```
node tools/verify-renames.js
```

Reversibility check (applies inverse mapping, diffs against originals):
```
node tools/reverse-verify.js
```

Both exit 0 on clean, 1 on mismatch. `verify-renames.js --fix` overwrites working
copies with the expected output.

### 8 — Commit + repeat

```
git add scripts.interpreted/ renames/ preview-round-N.html
git commit -m "Round N: M renames applied"
```

Go back to step 1. Newly named functions unlock the next tier of leaves.

---

## Inheritance semantics

A qualified rename `"witness.Q49H": "foo"` applies in `witness.m` and every script that
`inherits witness` (transitively). A bare rename `"Q49H": "foo"` applies in all scripts.
Qualified takes precedence over bare when both are present.

---

## Stats by round

| Round | Q-symbols | Resolved | Leaves |
|-------|-----------|----------|--------|
| 0 (baseline) | 1,182 | 0 | 542 |
| 1 (after) | 1,165 | — | 535 |
