# wombat-interpret

Progressive disambiguation of all Q-style symbols across the 1,633 Wombat source scripts.

## Directory layout

```
scripts/          Plain-text .m files (copied from rundir/scripts.wombat/)
symbols.json      Current symbol graph (regenerated each round)
renames.json      Cumulative approved renames (grows each round)
report-N.html     Self-contained HTML for round N review
renames-N.json    Approved renames for round N (produced in browser)
```

## Workflow

### Setup (done once)
```
cp ../rundir/scripts.wombat/*.m scripts/
```

### Each round

1. **Extract symbols**
   ```
   node extract-symbols.js
   ```
   Reads all `scripts/*.m`, outputs `symbols.json`:
   - All Q-style symbols with kind, type, dependencies
   - Marks leaf functions (no unresolved Q-calls in body)

2. **Generate report**
   ```
   node generate-report.js --round N
   ```
   Outputs `report-N.html` — open in browser:
   - One section per script
   - Each leaf symbol shown with source (foldable)
   - Text inputs for proposed names
   - "Export renames.json" button downloads `renames-N.json`

3. **Review** in browser, enter names, click Export

4. **Apply renames**
   ```
   node apply-renames.js renames-N.json
   ```
   - Updates all `scripts/*.m` in place
   - Adds `UNINT_Q*` prefix to approved-but-unnamed leaves (if `--mark-unint`)
   - Merges into cumulative `renames.json`

5. **Repeat** from step 1 — newly named functions unlock the next tier of leaves

## Q-symbol pattern

`Q[0-9A-Z]{3}` — Q followed by exactly 3 uppercase alphanumeric chars.

## Leaf definition

A function is a **leaf** when every Q-name it calls resolves to a named symbol.
Local variable Q-names (declared inside the function body) do not count toward deps.

## Stats (round 1 baseline)

- 1,633 scripts
- 1,182 Q-symbols total (1,182 unresolved)
- **542 leaf functions** ready for round 1
- **278 Q-members** (always trivially leaf — name from usage context)
- **640 non-leaf functions** (have Q-function call dependencies still to resolve)
