# Wombat Interpretation — Streamlined Process

Progressive disambiguation of all Q-style symbols across the 1,633 Wombat source scripts.
Each round resolves a batch of leaf symbols; newly named functions unlock the next tier.

---

## Directory layout

```
scripts/            Working copies of plain-text .m files (renamed in-place each round)
renames.json        Cumulative approved renames (grows each round)
verify-renames.js   Round-trip correctness check against originals
extract-symbols.js  Symbol extractor → symbols.json
generate-report.js  Full-listing HTML report → report-N.html
apply-renames.js    Applies renames-N.json to scripts + merges into renames.json
gen-preview.js      Agent-powered preview HTML with call sites → preview-round-N.html
symbols.json        Current symbol graph (regenerated each round, not committed)
report-N.html       Full listing HTML (regenerated each round, not committed)
preview-round-N.html  Agent-proposed preview (committed — used for review)
```

Originals live at `../rundir/scripts.wombat/` and are never modified.

---

## Naming convention

**All introduced names must use `snake_case`.**  
No camelCase, no PascalCase. This applies to function names, parameter names, local variable names, and member names.

---

## Round workflow

### 1 — Extract symbols
```
node extract-symbols.js
```
Reads all `scripts/*.m`, writes `symbols.json`:
- All Q-style symbols with kind, type, params, q_calls, q_locals
- Inheritance graph
- Leaf status: Q-named function where all q_calls resolve to named symbols

### 2 — Spawn agents for leaf functions

For each new leaf function, spawn a Claude agent with the raw function source and the script context. The agent returns a JSON object mapping every Q-name in the function (function name + params + locals) to a proposed `snake_case` name. Call sites (±10 lines, across all scripts) are extracted separately for context.

Agent prompt template:
```
You are analyzing a function from the 1998 Ultima Online server scripting language "Wombat".
Q-style names are obfuscated OSI identifiers. Propose human-readable snake_case names.

Script: `<script_name>.m`
Context: <brief description of what this script does>

Raw source:
```
<verbatim function source with tabs and newlines>
```

Q-names to rename:
- <QXXX> — the function itself
- <QYYY> — parameter (type)
- <QZZZ> — local variable (type)
...

Respond with ONLY a JSON object. No explanation, no markdown fences.
{"QXXX": "snake_name", ...}
```

All agents for a round can be spawned in parallel (use a single message with multiple Agent tool calls).

### 3 — Generate preview HTML
```
node gen-preview.js
```
Produces `preview-round-N.html` — a self-contained review page with:
- **Source block** (foldable, verbatim with tabs/newlines, dark theme)
- **Call sites** (foldable, ±10 lines, matching line highlighted in amber)
- **Renames table**: proposed name + override input field (sessionStorage-persisted)
- **Export button**: downloads `renames-N.json` using overrides where set, proposed names otherwise
- **Responsive layout**: compact header on mobile, all code blocks horizontally scrollable

Send the HTML file for review.

### 4 — Review + export
Open `preview-round-N.html` in a browser. Enter override names where the agent proposal is wrong or unclear. Click **Download renames-N.json**.

### 5 — Apply renames
```
node apply-renames.js renames-N.json
```
- Updates all `scripts/*.m` in-place using inheritance-aware substitution
- Merges into cumulative `renames.json`
- Optional `--mark-unint` prefixes unapproved leaves with `UNINT_`

### 6 — Verify
```
node verify-renames.js
```
Replays `renames.json` forward against originals (`../rundir/scripts.wombat/`) and diffs against working copies. Reports any discrepancies. Exits 0 on clean, 1 on mismatch. Use `--fix` to overwrite working copies with the expected output.

### 7 — Commit + repeat
```
git add scripts/ renames.json preview-round-N.html
git commit -m "Round N: <N> renames applied"
```
Then go back to step 1. Newly named functions unlock the next tier of leaves.

---

## gen-preview.js — implementation notes

The script is currently hardcoded for the round-1 batch of 10 functions. For subsequent rounds it needs:
1. Read `symbols.json` to get the current leaf set
2. For each leaf, extract raw source by scanning the actual `.m` file (preserves exact whitespace)
3. Extract call sites (±10 lines) across all `scripts/*.m` using `\bQNAME\s*\(` regex
4. Spawn one agent per leaf, collect proposed renames (all in parallel)
5. Render HTML

**Raw source extraction** — do not use the `tokensToSource` reconstructed source from `symbols.json`. Instead scan the `.m` file for `function TYPE QNAME(` and slice the actual text to the matching `}`. This preserves tabs and newlines exactly.

**Call site extraction** — search all `scripts/*.m` for the Q-name (or its resolved name if renamed) followed by `(`. Group by script, extract ±10 line window, record hit line offset for highlighting.

---

## apply-renames.js — inheritance semantics

A qualified rename `"witness.Q49H": "foo"` applies only in `witness.m` and scripts that `inherits witness`. A bare rename `"Q49H": "foo"` applies in all scripts. Qualified takes precedence over bare when both are present.

---

## Stats by round

| Round | Q-symbols | Resolved | Leaves |
|-------|-----------|----------|--------|
| 0 (baseline) | 1,182 | 0 | 542 |
| 1 (after) | 1,165 | — | 535 |
