#!/usr/bin/env node
'use strict';
// regen-preview-2.js
// Regenerates preview-round-2.html from symbols.json + extracted proposals.
// Key format fix: functions always "script.Q", locals/params "script.fnQ:localQ".
//
// Usage: node regen-preview-2.js [--proposals /tmp/prev_proposals.json]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const proposalsFile = getArg('--proposals', '/tmp/prev_proposals.json');
const roundLabel    = getArg('--round', '2');
const outOverride   = getArg('--out', '');

function escHtml(s) {
  return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// ── 1. Load symbols ───────────────────────────────────────────────────────────

const { symbols, inherits: inheritMap } = JSON.parse(fs.readFileSync('./symbols.json', 'utf8'));
const leaves = Object.values(symbols).filter(s => s.is_leaf && s.is_q);
console.log(`Loaded ${leaves.length} leaf functions from symbols.json`);

// ── 2. Load previous proposals ────────────────────────────────────────────────

let oldProposals = {};
if (fs.existsSync(proposalsFile)) {
  oldProposals = JSON.parse(fs.readFileSync(proposalsFile, 'utf8'));
  console.log(`Loaded ${Object.keys(oldProposals).length} previous proposals`);
} else {
  console.log('No proposals file found — building without pre-populated names');
}

// Helper: look up a proposal for a Q-code, trying qualified then bare
function getProposal(script, q, fnQ) {
  // For function Q-codes: try "script.Q" then bare "Q"
  if (!fnQ) return oldProposals[`${script}.${q}`] || oldProposals[q] || '';
  // For locals/params: old format was bare "Q", new format is "script.fnQ:Q"
  // Also try "script.fnQ:Q" in case we already have new-format proposals
  return oldProposals[`${script}.${fnQ}:${q}`] || oldProposals[q] || '';
}

// ── 3. Build leaf entries with qNames ─────────────────────────────────────────

// Each entry: { leaf, qNames: [{q, role, exportKey, proposed}] }
const entries = leaves.map(leaf => {
  const qNames = [];

  // The function itself
  qNames.push({
    q: leaf.name,
    role: 'function',
    exportKey: `${leaf.script}.${leaf.name}`,
    proposed: getProposal(leaf.script, leaf.name, null),
  });

  // Q-params
  for (const p of (leaf.params || [])) {
    if (/^Q[0-9A-Z]{3}$/.test(p.name)) {
      qNames.push({
        q: p.name,
        role: 'param',
        exportKey: `${leaf.script}.${leaf.name}:${p.name}`,
        proposed: getProposal(leaf.script, p.name, leaf.name),
      });
    }
  }

  // Q-locals
  for (const lq of (leaf.q_locals || [])) {
    // Avoid duplicates if a local also appears in params
    if (!qNames.find(e => e.q === lq)) {
      qNames.push({
        q: lq,
        role: 'local',
        exportKey: `${leaf.script}.${leaf.name}:${lq}`,
        proposed: getProposal(leaf.script, lq, leaf.name),
      });
    }
  }

  return { leaf, qNames };
});

// ── 4. Build defaultRenames map ───────────────────────────────────────────────

const defaultRenames = {};
for (const { qNames } of entries) {
  for (const { exportKey, proposed } of qNames) {
    if (proposed && !defaultRenames[exportKey]) defaultRenames[exportKey] = proposed;
  }
}
console.log(`Default renames: ${Object.keys(defaultRenames).length} entries`);

// ── 5. Scan call sites ────────────────────────────────────────────────────────

const scriptsDir = path.join(__dirname, 'scripts');
const scriptFiles = fs.readdirSync(scriptsDir).filter(f => f.endsWith('.m')).sort();
const functionQCodes = new Set(leaves.map(l => l.name));
const MAX_CALL_SITES = 6;
const CONTEXT = 10;

const callSiteMap = {};
for (const q of functionQCodes) callSiteMap[q] = [];

const scriptSrcCache = {}; // scriptName -> { src, lines }

console.log(`Scanning ${scriptFiles.length} scripts for call sites…`);
const Q_CALL_RE = /\b(Q[0-9A-Z]{3})\s*\(/g;
let filesDone = 0;
for (const file of scriptFiles) {
  const scriptName = path.basename(file, '.m');
  const src = fs.readFileSync(path.join(scriptsDir, file), 'utf8');
  const lines = src.split('\n');
  scriptSrcCache[scriptName] = { src, lines };
  Q_CALL_RE.lastIndex = 0;
  let m;
  while ((m = Q_CALL_RE.exec(src)) !== null) {
    const q = m[1];
    if (!functionQCodes.has(q)) continue;
    const sites = callSiteMap[q];
    if (sites.length >= MAX_CALL_SITES) continue;
    // Skip the function's own definition header (function <type> Q4XX(...))
    const preceding = src.slice(Math.max(0, m.index - 40), m.index);
    if (/\bfunction\b/.test(preceding)) continue;
    const before = src.slice(0, m.index);
    const lineIdx = (before.match(/\n/g) || []).length;
    const from = Math.max(0, lineIdx - CONTEXT);
    const to   = Math.min(lines.length - 1, lineIdx + CONTEXT);
    sites.push({ script: scriptName, line: lineIdx + 1, lines: lines.slice(from, to + 1), startLine: from + 1, hitOffset: lineIdx - from });
  }
  filesDone++;
  if (filesDone % 200 === 0) process.stdout.write(`  ${filesDone}/${scriptFiles.length}\r`);
}
console.log(`  ${filesDone}/${scriptFiles.length} — done.`);

// ── 6. Render HTML ────────────────────────────────────────────────────────────

function extractFunctionSource(scriptName, fnName) {
  const cached = scriptSrcCache[scriptName];
  if (!cached) return null;
  const { src } = cached;
  const esc = fnName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const headerRe = new RegExp(`\\bfunction\\s+\\w+\\s+${esc}\\s*\\(`);
  const m = headerRe.exec(src);
  if (!m) return null;
  const before = src.slice(0, m.index);
  const startLineIdx = (before.match(/\n/g) || []).length;
  let i = m.index + m[0].length;
  let parenDepth = 1;
  while (i < src.length && parenDepth > 0) {
    if (src[i] === '(') parenDepth++;
    else if (src[i] === ')') parenDepth--;
    i++;
  }
  while (i < src.length && src[i] !== '{') i++;
  if (i >= src.length) return null;
  let depth = 1;
  let j = i + 1;
  while (j < src.length && depth > 0) {
    if (src[j] === '{') depth++;
    else if (src[j] === '}') depth--;
    j++;
  }
  return { lines: src.slice(m.index, j).split('\n'), startLine: startLineIdx + 1 };
}

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
  const more = sites.length === MAX_CALL_SITES ? ` <span class="cs-more">(first ${MAX_CALL_SITES} shown)</span>` : '';
  return `<div class="callsites-section">
  <div class="callsites-header">Called from <span class="cs-count">${sites.length}</span> location${sites.length !== 1 ? 's' : ''}${more}</div>
  ${blocks}
</div>`;
}

function renderEntry({ leaf, qNames }, idx) {
  const fnEntry = qNames.find(e => e.role === 'function');
  const fnProposed = fnEntry?.proposed || '???';

  const renameRows = qNames.map(({ q, role, exportKey, proposed }) => {
    const uid = `r${idx}_${exportKey.replace(/[.:]/g, '_')}`;
    const rowCls = role === 'function' ? 'row-fn' : 'row-var';
    return `<tr class="${rowCls}" id="row-${uid}">
      <td class="col-exclude">
        <input type="checkbox" class="exclude-cb" id="excl-${uid}"
          data-key="${escHtml(exportKey)}" title="Exclude from export"
          onchange="onExcludeChange(this)" />
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
          oninput="onCustomInput(this)" />
      </td>
    </tr>`;
  }).join('\n');

  const rawSrc = extractFunctionSource(leaf.script, leaf.name);
  let srcContent;
  if (rawSrc) {
    const numbered = rawSrc.lines.map((line, li) => {
      const lineNo = rawSrc.startLine + li;
      return `<span><span class="ln">${String(lineNo).padStart(4)}</span>  ${escHtml(line)}</span>`;
    }).join('\n');
    srcContent = numbered;
  } else {
    srcContent = escHtml(leaf.source);
  }

  return `<section class="entry" id="entry-${idx}"
  data-script="${escHtml(leaf.script)}"
  data-q="${escHtml(leaf.name)}"
  data-name="${escHtml(leaf.name + ' ' + fnProposed)}">
  <div class="entry-header">
    <span class="entry-num">#${idx + 1}</span>
    <span class="entry-script">${escHtml(leaf.script)}.m</span>
    <span class="entry-qname"><code>${escHtml(leaf.name)}</code></span>
    <span class="entry-arrow">→</span>
    <span class="entry-proposed"><strong>${escHtml(fnProposed)}</strong></span>
  </div>

  <details class="src-block">
    <summary>Source <span class="src-type">${escHtml(leaf.returnType || '')}</span></summary>
    <div class="code-scroll"><pre class="src-pre">${srcContent}</pre></div>
  </details>

  ${renderCallSites(leaf.name)}

  <div class="table-scroll">
  <table class="renames-table">
    <thead>
      <tr>
        <th class="col-exclude" title="Exclude from export">✕</th>
        <th>Q-name</th><th>Role</th><th></th>
        <th>Proposed</th><th>Override</th>
      </tr>
    </thead>
    <tbody>${renameRows}</tbody>
  </table>
  </div>
</section>`;
}

console.log(`Building HTML for ${entries.length} entries…`);
const sections = entries.map((e, i) => {
  if (i % 50 === 0) process.stdout.write(`  ${i}/${entries.length}\r`);
  return renderEntry(e, i);
}).join('\n');
console.log(`  ${entries.length}/${entries.length} — done.`);

const missingCount = entries.filter(({ qNames }) => {
  const fn = qNames.find(e => e.role === 'function');
  return !fn?.proposed;
}).length;

const defaultRenamesJson = JSON.stringify(defaultRenames);

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wombat — Round ${roundLabel} Preview (${entries.length} functions)</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: system-ui, sans-serif; font-size: 14px; background: #f0f2f5; color: #222; }
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
main { max-width: 960px; margin: 0 auto; padding: 1.2rem 1rem; }
.entry { background: #fff; border-radius: 8px; margin-bottom: 1.5rem; box-shadow: 0 1px 4px rgba(0,0,0,.1); overflow: clip; }
.entry.hidden { display: none; }
.entry-header { padding: 0.7rem 1.1rem; background: #f8f9ff; border-bottom: 1px solid #e8e8ef; display: flex; align-items: center; gap: 0.55rem; flex-wrap: wrap; }
.entry-num { font-size: 0.7rem; background: #e0e7ff; color: #3730a3; padding: 0.12rem 0.4rem; border-radius: 3px; font-weight: bold; }
.entry-script { font-family: monospace; font-size: 0.8rem; color: #666; }
.entry-qname code { font-family: monospace; font-size: 0.9rem; color: #c00; font-weight: bold; }
.entry-arrow { color: #bbb; }
.entry-proposed strong { font-family: monospace; font-size: 0.9rem; color: #16a34a; }
.src-block > summary, .callsite-block > summary { padding: 0.4rem 1.1rem; cursor: pointer; font-size: 0.76rem; color: #4a9eff; background: #fafbff; border-bottom: 1px solid #eee; user-select: none; display: flex; align-items: center; gap: 0.5rem; }
.src-block > summary:hover, .callsite-block > summary:hover { background: #f0f5ff; }
.src-type { font-family: monospace; color: #888; font-size: 0.7rem; }
.code-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; border-bottom: 1px solid #2a2a3e; }
.src-pre { padding: 0.8rem 1.1rem; font-family: 'Courier New', monospace; font-size: 12px; line-height: 1.55; background: #1e1e2e; color: #cdd6f4; white-space: pre; tab-size: 4; display: flex; flex-direction: column; min-width: max-content; }
.src-pre span { display: block; }
.cs-scroll { overflow-x: auto; -webkit-overflow-scrolling: touch; border-bottom: 1px solid #2a2a3a; }
.cs-pre { padding: 0.6rem 1.1rem 0.6rem 2rem; font-family: 'Courier New', monospace; font-size: 11.5px; line-height: 1.5; background: #1a1a26; color: #cdd6f4; white-space: pre; tab-size: 4; display: flex; flex-direction: column; min-width: max-content; }
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
@media (max-width: 640px) {
  header { padding: 0.5rem 0.8rem; gap: 0.4rem; }
  header h1 { font-size: 0.85rem; }
  .hdr-actions { margin-left: 0; width: 100%; justify-content: flex-end; }
  button { padding: 0.3rem 0.55rem; font-size: 0.73rem; }
  main { padding: 0.7rem 0.4rem; }
}
#json-out { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.6); z-index: 50; align-items: center; justify-content: center; }
#json-out.visible { display: flex; }
.json-modal { background: #1e1e2e; color: #cdd6f4; border-radius: 8px; padding: 1.5rem; max-width: 640px; width: 95%; max-height: 82vh; display: flex; flex-direction: column; gap: 1rem; }
.json-modal h2 { font-size: 0.92rem; color: #eee; }
.json-modal pre { font-size: 11.5px; overflow-y: auto; flex: 1; white-space: pre; }
.json-modal-actions { display: flex; gap: 0.5rem; justify-content: flex-end; }
#toast { position: fixed; bottom: 1.5rem; right: 1.5rem; background: #222; color: #fff; padding: 0.6rem 1rem; border-radius: 6px; display: none; font-size: 0.8rem; z-index: 100; }
#no-results { display: none; text-align: center; padding: 3rem; color: #999; font-size: 0.9rem; }
.key-format-note { font-size: 0.68rem; color: #777; padding: 0.15rem 0.5rem; background: #f5f5ff; border-radius: 3px; font-family: monospace; }
</style>
</head>
<body>
<header>
  <h1>Wombat Interpret — Round ${roundLabel} Preview</h1>
  <div class="hdr-sub">${entries.length} leaf functions · ${missingCount > 0 ? missingCount + ' missing proposals' : 'all proposed'}</div>
  <div class="hdr-search"><input id="search" type="search" placeholder="Filter by script, Q-name, or proposed…" oninput="filterEntries(this.value)"></div>
  <div class="hdr-count" id="hdr-count">${entries.length} shown</div>
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
    const match = !term || el.dataset.script.includes(term) || el.dataset.q.toLowerCase().includes(term) || el.dataset.name.toLowerCase().includes(term);
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

const outFile = outOverride || path.join(__dirname, `preview-round-${roundLabel}.html`);
fs.writeFileSync(outFile, html);
const size = (fs.statSync(outFile).size / 1024 / 1024).toFixed(1);
console.log(`\nWrote ${outFile} (${size} MB)`);
console.log(`Default renames: ${Object.keys(defaultRenames).length} entries`);
console.log(`Missing proposals: ${missingCount}`);
