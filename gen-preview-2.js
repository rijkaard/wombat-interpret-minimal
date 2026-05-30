#!/usr/bin/env node
'use strict';
// gen-preview-2.js — generates preview-round-2.html from wave agent results + call sites
// Usage: node gen-preview-2.js

const fs   = require('fs');
const path = require('path');

function escHtml(s) {
  return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// ── 1. Load wave results ──────────────────────────────────────────────────────

const wave1  = JSON.parse(fs.readFileSync('/tmp/r2_wave1_results.json',  'utf8'));
const wave2  = JSON.parse(fs.readFileSync('/tmp/r2_wave2_results.json',  'utf8'));
const wave34 = JSON.parse(fs.readFileSync('/tmp/r2_wave34_results.json', 'utf8'));
// allWaves["batch_00"]["Q5GF"] = "proposed_name"
const allWaves = Object.assign({}, wave1, wave2, wave34);

// ── 2. Load batches ───────────────────────────────────────────────────────────

const batches = JSON.parse(fs.readFileSync('/tmp/round2_batches.json', 'utf8'));
// Flatten: each leaf knows its batchIdx
const allLeaves = [];
for (let i = 0; i < batches.length; i++) {
  for (const leaf of batches[i]) {
    allLeaves.push({ ...leaf, batchIdx: i });
  }
}
console.log(`Loaded ${allLeaves.length} leaves across ${batches.length} batches.`);

// ── 3. Determine which function Q-codes appear in multiple scripts ─────────────

const fnQCodeScripts = new Map(); // Q-code → Set of scripts where it's a function
for (const leaf of allLeaves) {
  if (!fnQCodeScripts.has(leaf.name)) fnQCodeScripts.set(leaf.name, new Set());
  fnQCodeScripts.get(leaf.name).add(leaf.script);
}

// ── 4. Build per-leaf rename entry list ──────────────────────────────────────

// For each leaf, build an array of {exportKey, q, proposed, role, isFn}
// exportKey: what goes in renames-2.json as the key
//   - function appearing in >1 script → "script.Q" (qualified)
//   - function in only 1 script → "Q" (bare)
//   - params/locals → "Q" (bare) always

function makeLookup(leaf) {
  const batchKey = 'batch_' + String(leaf.batchIdx).padStart(2, '0');
  return allWaves[batchKey] || {};
}

// ── 5. Extract call sites ─────────────────────────────────────────────────────

const scriptsDir = path.join(__dirname, 'scripts');
const scriptFiles = fs.readdirSync(scriptsDir).filter(f => f.endsWith('.m')).sort();

const functionQCodes = new Set(allLeaves.map(l => l.name));
const MAX_CALL_SITES = 6;
const CONTEXT = 10;

// callSiteMap[q] = [{script, line, lines, startLine, hitOffset}]
const callSiteMap = {};
for (const q of functionQCodes) callSiteMap[q] = [];

console.log(`Scanning ${scriptFiles.length} scripts for call sites of ${functionQCodes.size} function Q-codes…`);
const Q_CALL_RE = /\b(Q[0-9A-Z]{3})\s*\(/g;
let filesDone = 0;
for (const file of scriptFiles) {
  const scriptName = path.basename(file, '.m');
  const src = fs.readFileSync(path.join(scriptsDir, file), 'utf8');
  const lines = src.split('\n');
  Q_CALL_RE.lastIndex = 0;
  let m;
  while ((m = Q_CALL_RE.exec(src)) !== null) {
    const q = m[1];
    if (!functionQCodes.has(q)) continue;
    const sites = callSiteMap[q];
    if (sites.length >= MAX_CALL_SITES) continue;
    // Compute line number from character offset
    const before = src.slice(0, m.index);
    const lineIdx = (before.match(/\n/g) || []).length;
    const from = Math.max(0, lineIdx - CONTEXT);
    const to   = Math.min(lines.length - 1, lineIdx + CONTEXT);
    sites.push({
      script: scriptName,
      line: lineIdx + 1,
      lines: lines.slice(from, to + 1),
      startLine: from + 1,
      hitOffset: lineIdx - from,
    });
  }
  filesDone++;
  if (filesDone % 200 === 0) process.stdout.write(`  ${filesDone}/${scriptFiles.length}\r`);
}
console.log(`  ${filesDone}/${scriptFiles.length} — done.`);

// ── 6. Render HTML ────────────────────────────────────────────────────────────

function renderCallSites(q) {
  const sites = callSiteMap[q];
  if (!sites || sites.length === 0) return '';

  const blocks = sites.map(site => {
    const numbered = site.lines.map((line, li) => {
      const lineNo = site.startLine + li;
      const isHit = li === site.hitOffset;
      const cls = isHit ? ' class="hit-line"' : '';
      return `<span${cls}><span class="ln">${String(lineNo).padStart(4)}</span>  ${escHtml(line)}</span>`;
    }).join('\n');
    return `<details class="callsite-block">
  <summary><span class="cs-script">${escHtml(site.script)}.m</span> <span class="cs-line">line ${site.line}</span></summary>
  <div class="cs-scroll"><pre class="cs-pre">${numbered}</pre></div>
</details>`;
  }).join('\n');

  const more = (callSiteMap[q].length === MAX_CALL_SITES)
    ? ` <span class="cs-more">(first ${MAX_CALL_SITES} shown)</span>` : '';

  return `<div class="callsites-section">
  <div class="callsites-header">Called from <span class="cs-count">${sites.length}</span> location${sites.length !== 1 ? 's' : ''}${more}</div>
  ${blocks}
</div>`;
}

function renderEntry(leaf, idx) {
  const lookup = makeLookup(leaf);
  const isMultiScript = (fnQCodeScripts.get(leaf.name) || new Set()).size > 1;

  // Build rename rows
  const renameRows = leaf.qNames.map(({q, role}) => {
    const isFn = (role === 'function');
    const proposed = lookup[q] || '';
    // Export key — always script-qualified or function-body-scoped:
    //   function  → "script.Q"         (apply in defining script + inheritors)
    //   local/param → "script.fnQ:localQ"  (apply only within that function body)
    //   member    → "script.Q"         (apply in defining script + inheritors)
    let exportKey;
    if (role === 'local' || role === 'param') {
      exportKey = `${leaf.script}.${leaf.name}:${q}`;
    } else {
      exportKey = `${leaf.script}.${q}`;
    }
    const uid = `r${idx}_${exportKey.replace(/\./g, '_')}`;
    return `<tr class="${isFn ? 'row-fn' : 'row-var'}" id="row-${uid}">
      <td class="col-exclude">
        <input type="checkbox" class="exclude-cb" id="excl-${uid}"
          data-key="${escHtml(exportKey)}"
          title="Exclude from export"
          onchange="onExcludeChange(this)"
        />
      </td>
      <td class="col-q"><code>${escHtml(q)}</code></td>
      <td class="col-role">${escHtml(role)}</td>
      <td class="col-arrow">→</td>
      <td class="col-proposed"><code class="proposed">${escHtml(proposed) || '<span class="missing">—</span>'}</code></td>
      <td class="col-custom">
        <input type="text" class="custom-input" id="${uid}"
          data-key="${escHtml(exportKey)}"
          data-proposed="${escHtml(proposed)}"
          placeholder="override…"
          oninput="onCustomInput(this)"
        />
      </td>
    </tr>`;
  }).join('\n');

  const fnQName = leaf.name;
  const fnRename = lookup[fnQName] || '???';
  const scriptDataAttr = `data-script="${escHtml(leaf.script)}"`;
  const qDataAttr = `data-q="${escHtml(fnQName)}"`;
  const nameDataAttr = `data-name="${escHtml(fnQName + ' ' + fnRename)}"`;

  return `<section class="entry" id="entry-${idx}" ${scriptDataAttr} ${qDataAttr} ${nameDataAttr}>
  <div class="entry-header">
    <span class="entry-num">#${idx + 1}</span>
    <span class="entry-script">${escHtml(leaf.script)}.m</span>
    <span class="entry-qname"><code>${escHtml(fnQName)}</code></span>
    <span class="entry-arrow">→</span>
    <span class="entry-proposed"><strong>${escHtml(fnRename)}</strong></span>
  </div>

  <details class="src-block">
    <summary>Source <span class="src-type">${escHtml(leaf.returnType || '')}</span></summary>
    <div class="code-scroll"><pre class="src-pre">${escHtml(leaf.source)}</pre></div>
  </details>

  ${renderCallSites(fnQName)}

  <div class="table-scroll">
  <table class="renames-table">
    <thead>
      <tr>
        <th class="col-exclude" title="Exclude from export">✕</th>
        <th>Q-name</th><th>Role</th><th></th>
        <th>Proposed</th>
        <th>Override</th>
      </tr>
    </thead>
    <tbody>
      ${renameRows}
    </tbody>
  </table>
  </div>
</section>`;
}

// Build the default renames map (for JS export logic)
// exportKey → proposed (may be empty)
const defaultRenames = {};
for (const leaf of allLeaves) {
  const lookup = makeLookup(leaf);
  const isMultiScript = (fnQCodeScripts.get(leaf.name) || new Set()).size > 1;
  for (const {q, role} of leaf.qNames) {
    const proposed = lookup[q] || '';
    if (!proposed) continue;
    let exportKey;
    if (role === 'local' || role === 'param') {
      exportKey = `${leaf.script}.${leaf.name}:${q}`;
    } else {
      exportKey = `${leaf.script}.${q}`;
    }
    if (!defaultRenames[exportKey]) defaultRenames[exportKey] = proposed;
  }
}

console.log(`Building HTML for ${allLeaves.length} entries…`);
const sections = allLeaves.map((leaf, i) => {
  if (i % 50 === 0) process.stdout.write(`  ${i}/${allLeaves.length}\r`);
  return renderEntry(leaf, i);
}).join('\n');
console.log(`  ${allLeaves.length}/${allLeaves.length} — done.`);

const defaultRenamesJson = JSON.stringify(defaultRenames);

const missingCount = allLeaves.filter(leaf => {
  const lookup = makeLookup(leaf);
  return !lookup[leaf.name];
}).length;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wombat — Round 2 Preview (${allLeaves.length} functions)</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; font-size: 14px; background: #f0f2f5; color: #222; }

/* ── Header ── */
header { background: #1a1a2e; color: #eee; padding: 0.75rem 1.5rem; position: sticky; top: 0; z-index: 10; display: flex; align-items: center; gap: 1rem; flex-wrap: wrap; }
header h1 { font-size: 1rem; white-space: nowrap; }
.hdr-sub { font-size: 0.78rem; color: #999; white-space: nowrap; }
.hdr-search { flex: 1 1 200px; min-width: 140px; max-width: 340px; }
.hdr-search input { width: 100%; padding: 0.35rem 0.7rem; border: 1px solid #444; border-radius: 4px; background: #2a2a40; color: #eee; font-size: 0.82rem; outline: none; }
.hdr-search input:focus { border-color: #4a9eff; }
.hdr-count { font-size: 0.78rem; color: #777; white-space: nowrap; }
.hdr-actions { margin-left: auto; display: flex; gap: 0.5rem; }
button { cursor: pointer; padding: 0.38rem 0.85rem; border: none; border-radius: 4px; font-size: 0.8rem; }
.btn-primary { background: #4a9eff; color: #fff; }
.btn-secondary { background: #555; color: #eee; }
.btn-sm { padding: 0.25rem 0.5rem; font-size: 0.72rem; }

/* ── Entry card ── */
main { max-width: 960px; margin: 0 auto; padding: 1.2rem 1rem; }
.entry { background: #fff; border-radius: 8px; margin-bottom: 1.5rem; box-shadow: 0 1px 4px rgba(0,0,0,.1); overflow: clip; }
.entry.hidden { display: none; }
.entry-header { padding: 0.7rem 1.1rem; background: #f8f9ff; border-bottom: 1px solid #e8e8ef; display: flex; align-items: center; gap: 0.55rem; flex-wrap: wrap; }
.entry-num { font-size: 0.7rem; background: #e0e7ff; color: #3730a3; padding: 0.12rem 0.4rem; border-radius: 3px; font-weight: bold; }
.entry-script { font-family: monospace; font-size: 0.8rem; color: #666; }
.entry-qname code { font-family: monospace; font-size: 0.9rem; color: #c00; font-weight: bold; }
.entry-arrow { color: #bbb; }
.entry-proposed strong { font-family: monospace; font-size: 0.9rem; color: #16a34a; }

/* ── Source block ── */
.src-block > summary,
.callsite-block > summary { padding: 0.4rem 1.1rem; cursor: pointer; font-size: 0.76rem; color: #4a9eff; background: #fafbff; border-bottom: 1px solid #eee; user-select: none; display: flex; align-items: center; gap: 0.5rem; }
.src-block > summary:hover,
.callsite-block > summary:hover { background: #f0f5ff; }
.src-type { font-family: monospace; color: #888; font-size: 0.7rem; }
.code-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; border-bottom: 1px solid #2a2a3e; }
.src-pre { padding: 0.8rem 1.1rem; font-family: 'Courier New', monospace; font-size: 12px; line-height: 1.55; background: #1e1e2e; color: #cdd6f4; white-space: pre; tab-size: 4; min-width: max-content; }
.cs-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; border-bottom: 1px solid #2a2a3a; }
.cs-pre { padding: 0.6rem 1.1rem 0.6rem 2rem; font-family: 'Courier New', monospace; font-size: 11.5px; line-height: 1.5; background: #1a1a26; color: #cdd6f4; white-space: pre; tab-size: 4; display: flex; flex-direction: column; min-width: max-content; }

/* ── Call sites ── */
.callsites-section { border-bottom: 1px solid #eee; }
.callsites-header { padding: 0.45rem 1.1rem; font-size: 0.78rem; color: #555; background: #fffdf0; border-bottom: 1px solid #f0ebe0; }
.callsites-header .cs-count { font-weight: bold; color: #b45309; }
.cs-more { color: #aaa; font-style: italic; }
.callsite-block > summary { background: #fffdf5; border-bottom: 1px solid #f0ece0; padding-left: 2rem; }
.callsite-block > summary:hover { background: #fff8e8; }
.callsite-block:last-child > summary { border-bottom: none; }
.callsite-block[open] > summary { border-bottom: 1px solid #f0ece0; }
.cs-script { font-family: monospace; font-size: 0.8rem; color: #92400e; }
.cs-line { font-size: 0.73rem; color: #aaa; }
.cs-pre span { display: block; }
.cs-pre .hit-line { background: #3a3000; color: #fde68a; border-left: 3px solid #f59e0b; padding-left: 4px; margin-left: -7px; }
.ln { color: #555; display: inline-block; width: 3ch; margin-right: 0.5rem; text-align: right; user-select: none; font-size: 10px; }
.hit-line .ln { color: #d97706; }

/* ── Renames table ── */
.table-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; }
.renames-table { width: 100%; border-collapse: collapse; min-width: 480px; }
.renames-table th { font-size: 0.7rem; color: #888; font-weight: 600; padding: 0.38rem 0.9rem; text-align: left; border-bottom: 1px solid #f0f0f0; background: #fafafa; }
.renames-table td { padding: 0.38rem 0.9rem; border-bottom: 1px solid #f5f5f5; vertical-align: middle; }
.renames-table tr:last-child td { border-bottom: none; }
.row-fn { background: #fefff5; }
.col-q code { font-family: monospace; font-size: 0.82rem; color: #c00; }
.col-role { font-size: 0.72rem; color: #888; white-space: nowrap; }
.col-arrow { color: #bbb; width: 14px; }
.col-proposed code.proposed { font-family: monospace; font-size: 0.83rem; color: #166534; }
.missing { color: #e05; font-size: 0.8rem; }
.col-custom { min-width: 160px; }
.custom-input { padding: 0.22rem 0.4rem; border: 1px solid #ddd; border-radius: 4px; font-family: monospace; font-size: 0.8rem; width: 100%; color: #1d4ed8; }
.custom-input.has-value { border-color: #3b82f6; background: #eff6ff; }
.col-exclude { width: 26px; text-align: center; color: #bbb; font-size: 0.7rem; }
.exclude-cb { cursor: pointer; width: 13px; height: 13px; accent-color: #e05; }
tr.excluded { opacity: 0.35; }
tr.excluded td { text-decoration: line-through; }
tr.excluded .exclude-cb { opacity: 1; }
tr.excluded .custom-input { text-decoration: none; }

/* ── Responsive ── */
@media (max-width: 640px) {
  header { padding: 0.5rem 0.8rem; gap: 0.4rem; }
  header h1 { font-size: 0.85rem; }
  .hdr-actions { margin-left: 0; width: 100%; justify-content: flex-end; }
  button { padding: 0.3rem 0.55rem; font-size: 0.73rem; }
  main { padding: 0.7rem 0.4rem; }
}

/* ── JSON modal ── */
#json-out { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.6); z-index: 50; align-items: center; justify-content: center; }
#json-out.visible { display: flex; }
.json-modal { background: #1e1e2e; color: #cdd6f4; border-radius: 8px; padding: 1.5rem; max-width: 640px; width: 95%; max-height: 82vh; display: flex; flex-direction: column; gap: 1rem; }
.json-modal h2 { font-size: 0.92rem; color: #eee; }
.json-modal pre { font-size: 11.5px; overflow-y: auto; flex: 1; white-space: pre; }
.json-modal-actions { display: flex; gap: 0.5rem; justify-content: flex-end; }
#toast { position: fixed; bottom: 1.5rem; right: 1.5rem; background: #222; color: #fff; padding: 0.6rem 1rem; border-radius: 6px; display: none; font-size: 0.8rem; z-index: 100; }
#no-results { display: none; text-align: center; padding: 3rem; color: #999; font-size: 0.9rem; }
</style>
</head>
<body>
<header>
  <h1>Wombat Interpret — Round 2 Preview</h1>
  <div class="hdr-sub">${allLeaves.length} leaf functions · ${missingCount > 0 ? missingCount + ' missing proposals' : 'all proposed'}</div>
  <div class="hdr-search"><input id="search" type="search" placeholder="Filter by script, Q-name, or proposed…" oninput="filterEntries(this.value)"></div>
  <div class="hdr-count" id="hdr-count">${allLeaves.length} shown</div>
  <div class="hdr-actions">
    <button class="btn-secondary btn-sm" onclick="collapseAll()">Collapse all</button>
    <button class="btn-secondary" onclick="showJson()">View JSON</button>
    <button class="btn-primary" onclick="downloadJson()">Download renames-2.json</button>
  </div>
</header>
<main>
${sections}
<div id="no-results">No entries match the filter.</div>
</main>

<div id="json-out">
  <div class="json-modal">
    <h2>renames-2.json <span style="font-weight:normal;font-size:0.78rem;color:#777">(overrides applied)</span></h2>
    <pre id="json-pre"></pre>
    <div class="json-modal-actions">
      <button class="btn-secondary" onclick="document.getElementById('json-out').classList.remove('visible')">Close</button>
      <button class="btn-primary" onclick="downloadJson()">Download</button>
    </div>
  </div>
</div>

<div id="toast"></div>

<script>
const defaultRenames = ${defaultRenamesJson};

// Restore sessionStorage state
document.querySelectorAll('.custom-input').forEach(inp => {
  const saved = sessionStorage.getItem('o2:' + inp.dataset.key);
  if (saved) { inp.value = saved; inp.classList.add('has-value'); }
});
document.querySelectorAll('.exclude-cb').forEach(cb => {
  if (sessionStorage.getItem('x2:' + cb.dataset.key) === '1') {
    cb.checked = true;
    cb.closest('tr').classList.add('excluded');
  }
});

function onCustomInput(inp) {
  const k = 'o2:' + inp.dataset.key;
  if (inp.value.trim()) { sessionStorage.setItem(k, inp.value.trim()); inp.classList.add('has-value'); }
  else { sessionStorage.removeItem(k); inp.classList.remove('has-value'); }
}

function onExcludeChange(cb) {
  const row = cb.closest('tr');
  if (cb.checked) { row.classList.add('excluded'); sessionStorage.setItem('x2:' + cb.dataset.key, '1'); }
  else { row.classList.remove('excluded'); sessionStorage.removeItem('x2:' + cb.dataset.key); }
}

function buildRenames() {
  const excluded = new Set([...document.querySelectorAll('.exclude-cb:checked')].map(cb => cb.dataset.key));
  const out = {};
  for (const [k, v] of Object.entries(defaultRenames)) {
    if (!excluded.has(k) && v) out[k] = v;
  }
  document.querySelectorAll('.custom-input').forEach(inp => {
    const val = inp.value.trim();
    if (val && !excluded.has(inp.dataset.key)) out[inp.dataset.key] = val;
  });
  return out;
}

function showJson() {
  document.getElementById('json-pre').textContent = JSON.stringify(buildRenames(), null, 2);
  document.getElementById('json-out').classList.add('visible');
}

function downloadJson() {
  const renames = buildRenames();
  const overrideCount = document.querySelectorAll('.custom-input.has-value').length;
  const excludeCount  = document.querySelectorAll('.exclude-cb:checked').length;
  const blob = new Blob([JSON.stringify(renames, null, 2)], {type: 'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'renames-2.json';
  a.click();
  const parts = [];
  if (overrideCount) parts.push(overrideCount + ' overridden');
  if (excludeCount)  parts.push(excludeCount + ' excluded');
  showToast('Downloaded renames-2.json — ' + Object.keys(renames).length + ' renames' + (parts.length ? ' (' + parts.join(', ') + ')' : ''));
  document.getElementById('json-out').classList.remove('visible');
}

document.getElementById('json-out').addEventListener('click', e => {
  if (e.target === document.getElementById('json-out'))
    document.getElementById('json-out').classList.remove('visible');
});

function filterEntries(q) {
  const term = q.trim().toLowerCase();
  const entries = document.querySelectorAll('.entry');
  let shown = 0;
  entries.forEach(el => {
    const script = el.dataset.script || '';
    const qcode  = el.dataset.q || '';
    const name   = el.dataset.name || '';
    const match  = !term || script.includes(term) || qcode.toLowerCase().includes(term) || name.toLowerCase().includes(term);
    el.classList.toggle('hidden', !match);
    if (match) shown++;
  });
  document.getElementById('hdr-count').textContent = shown + ' shown';
  document.getElementById('no-results').style.display = (shown === 0) ? 'block' : 'none';
}

function collapseAll() {
  document.querySelectorAll('details[open]').forEach(d => d.removeAttribute('open'));
}

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.style.display = 'block';
  setTimeout(() => t.style.display = 'none', 3500);
}
</script>
</body>
</html>`;

const outFile = path.join(__dirname, 'preview-round-2.html');
fs.writeFileSync(outFile, html);
const size = (fs.statSync(outFile).size / 1024 / 1024).toFixed(1);
console.log(`\nWrote ${outFile} (${size} MB)`);
console.log(`Default renames: ${Object.keys(defaultRenames).length} entries`);
console.log(`Missing proposals: ${missingCount}`);
