#!/usr/bin/env node
'use strict';
// regen-preview-members.js — HTML preview for Q-coded member variable renames.
// Usage: node regen-preview-members.js [--proposals ./renames-9-critiqued.json]
//                                       [--round 9] [--out ./preview-round-9.html]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const proposalsFile = getArg('--proposals', '/tmp/prev_proposals.json');
const roundLabel    = getArg('--round', '9');
const outFile       = getArg('--out', path.join(__dirname, `../preview-round-${roundLabel}.html`));
const scriptsDir    = getArg('--scripts-dir', path.join(__dirname, '../scripts.interpreted'));

function escHtml(s) {
  return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// ── Load symbols ──────────────────────────────────────────────────────────────

const { symbols } = JSON.parse(fs.readFileSync(path.join(__dirname, '../symbols.json'), 'utf8'));
const members = Object.values(symbols).filter(s => s.is_q && s.kind === 'member');
console.log(`Loaded ${members.length} Q-coded member variables from symbols.json`);

// ── Load proposals ────────────────────────────────────────────────────────────

let proposals = {};
if (fs.existsSync(proposalsFile)) {
  proposals = JSON.parse(fs.readFileSync(proposalsFile, 'utf8'));
  console.log(`Loaded ${Object.keys(proposals).length} proposals`);
} else {
  console.log('No proposals file — building without pre-populated names');
}

// ── Group by script ───────────────────────────────────────────────────────────

const byScript = {};
for (const m of members) {
  if (!byScript[m.script]) byScript[m.script] = [];
  byScript[m.script].push(m);
}
const scriptNames = Object.keys(byScript).sort();
console.log(`Affected scripts: ${scriptNames.length}`);

// ── Build entries ─────────────────────────────────────────────────────────────

// entry: { scriptName, members: [{q, type, proposed, exportKey}], src, lines }
const entries = scriptNames.map(scriptName => {
  const mems = byScript[scriptName];
  const srcPath = path.join(scriptsDir, scriptName + '.m');
  const src = fs.existsSync(srcPath) ? fs.readFileSync(srcPath, 'utf8') : '(not found)';
  const lines = src.split('\n');

  const memberEntries = mems.map(m => ({
    q: m.name,
    type: m.type || 'unknown',
    exportKey: `${scriptName}.${m.name}`,
    proposed: proposals[`${scriptName}.${m.name}`] || '',
  }));

  return { scriptName, members: memberEntries, src, lines };
});

// ── Build defaultRenames ──────────────────────────────────────────────────────

const defaultRenames = {};
for (const { members: mems } of entries) {
  for (const { exportKey, proposed } of mems) {
    if (proposed) defaultRenames[exportKey] = proposed;
  }
}
console.log(`Default renames: ${Object.keys(defaultRenames).length} entries`);

// ── Missing count ─────────────────────────────────────────────────────────────

const missingCount = entries.filter(e => e.members.some(m => !m.proposed)).length;

// ── Render helpers ────────────────────────────────────────────────────────────

const Q_RE = /\b(Q[0-9A-Z]{3})\b/g;

function renderSource(lines, memberQSet) {
  return lines.map((line, i) => {
    const lineNo = String(i + 1).padStart(4);
    // Highlight Q-codes that are in this script's member set
    let escaped = escHtml(line);
    // We need to work on the raw line to find Q-codes, then escape+annotate
    const highlighted = line.replace(Q_RE, (match) => {
      if (memberQSet.has(match)) {
        return `\x00QSTART\x00${match}\x00QEND\x00`;
      }
      return match;
    });
    const escapedHL = escHtml(highlighted)
      .replace(/\x00QSTART\x00/g, '<mark class="q-hit">')
      .replace(/\x00QEND\x00/g, '</mark>');
    return `<span><span class="ln">${lineNo}</span>  ${escapedHL}</span>`;
  }).join('\n');
}

function renderEntry({ scriptName, members: mems, src, lines }, idx) {
  const qSet = new Set(mems.map(m => m.q));
  const srcContent = renderSource(lines, qSet);
  const allProposed = mems.every(m => m.proposed);

  const renameRows = mems.map(({ q, type, exportKey, proposed }) => {
    const uid = `r${idx}_${exportKey.replace(/[.:]/g, '_')}`;
    const missingCls = proposed ? '' : ' row-missing';
    return `<tr class="row-mem${missingCls}" id="row-${uid}">
      <td class="col-exclude">
        <input type="checkbox" class="exclude-cb" id="excl-${uid}"
          data-key="${escHtml(exportKey)}" title="Exclude from export"
          onchange="onExcludeChange(this)" />
      </td>
      <td class="col-q"><code>${escHtml(q)}</code></td>
      <td class="col-role">${escHtml(type)}</td>
      <td class="col-arrow">→</td>
      <td class="col-proposed"><code class="proposed">${proposed ? escHtml(proposed) : '<span class="missing">—</span>'}</code></td>
      <td class="col-custom">
        <input type="text" class="custom-input" id="${uid}"
          data-key="${escHtml(exportKey)}"
          data-proposed="${escHtml(proposed)}"
          placeholder="override…"
          oninput="onCustomInput(this)" />
      </td>
    </tr>`;
  }).join('\n');

  const headerCls = allProposed ? '' : ' entry-missing';

  return `<section class="entry${headerCls}" id="entry-${idx}"
  data-script="${escHtml(scriptName)}"
  data-name="${escHtml(scriptName + ' ' + mems.map(m => m.proposed || m.q).join(' '))}">
  <div class="entry-header">
    <span class="entry-num">#${idx + 1}</span>
    <span class="entry-script">${escHtml(scriptName)}.m</span>
    <span class="entry-count">${mems.length} member${mems.length !== 1 ? 's' : ''}</span>
  </div>

  <div class="table-scroll">
  <table class="renames-table">
    <thead>
      <tr>
        <th class="col-exclude" title="Exclude from export">✕</th>
        <th>Q-name</th><th>Type</th><th></th>
        <th>Proposed</th><th>Override</th>
      </tr>
    </thead>
    <tbody>${renameRows}</tbody>
  </table>
  </div>

  <details class="src-block" open>
    <summary>Source — ${escHtml(scriptName)}.m</summary>
    <div class="code-scroll"><pre class="src-pre">${srcContent}</pre></div>
  </details>
</section>`;
}

console.log(`Building HTML for ${entries.length} script entries…`);
const sections = entries.map((e, i) => {
  if (i % 20 === 0) process.stdout.write(`  ${i}/${entries.length}\r`);
  return renderEntry(e, i);
}).join('\n');
console.log(`  ${entries.length}/${entries.length} — done.`);

const defaultRenamesJson = JSON.stringify(defaultRenames);

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wombat — Round ${roundLabel} Members Preview (${entries.length} scripts)</title>
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
.btn-secondary { background: #333; color: #ccc; }
main { max-width: 1100px; margin: 0 auto; padding: 1rem; display: flex; flex-direction: column; gap: 1rem; }
.entry { background: #fff; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,.12); padding: 1rem 1.25rem; }
.entry-missing { border-left: 4px solid #e55; }
.entry-header { display: flex; align-items: baseline; gap: 0.6rem; margin-bottom: 0.75rem; flex-wrap: wrap; }
.entry-num { font-size: 0.72rem; color: #888; min-width: 2.2rem; }
.entry-script { font-family: monospace; font-size: 0.95rem; font-weight: 600; color: #1a1a5e; }
.entry-count { font-size: 0.75rem; color: #888; }
.table-scroll { overflow-x: auto; margin-bottom: 0.75rem; }
.renames-table { border-collapse: collapse; width: 100%; font-size: 0.82rem; }
.renames-table th { text-align: left; border-bottom: 2px solid #ddd; padding: 0.25rem 0.5rem; color: #555; }
.renames-table td { padding: 0.2rem 0.5rem; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
.row-missing td { background: #fff5f5; }
.row-missing .col-proposed { color: #c00; }
.col-exclude { width: 1.5rem; text-align: center; }
.col-q { font-family: monospace; color: #666; }
.col-role { color: #888; font-size: 0.78rem; }
.col-arrow { color: #aaa; }
.col-proposed code { color: #2a5; font-weight: 600; font-size: 0.88rem; }
.missing { color: #c00; }
.col-custom input { border: 1px solid #ddd; border-radius: 3px; padding: 0.15rem 0.4rem; font-size: 0.82rem; width: 100%; min-width: 120px; font-family: monospace; }
.col-custom input:focus { border-color: #4a9eff; outline: none; }
.col-custom input.overridden { border-color: #e8a020; background: #fffbf0; }
.src-block { margin-top: 0.5rem; }
.src-block summary { cursor: pointer; font-size: 0.8rem; color: #555; padding: 0.25rem 0; user-select: none; }
.src-block summary:hover { color: #333; }
.code-scroll { overflow-x: auto; margin-top: 0.5rem; max-height: 480px; overflow-y: auto; background: #1e1e2e; border-radius: 4px; }
pre.src-pre { font-family: 'Fira Code', 'Cascadia Code', monospace; font-size: 0.78rem; line-height: 1.5; background: transparent; color: #cdd6f4; padding: 0.75rem 1rem; min-width: 100%; display: flex; flex-direction: column; }
pre.src-pre span { display: block; }
.ln { display: inline-block; min-width: 2.8rem; color: #6e6e8e; user-select: none; }
mark.q-hit { background: #ffdd57; color: #222; border-radius: 2px; padding: 0 1px; }
#no-results { display: none; text-align: center; padding: 3rem; color: #888; font-size: 1rem; }
.export-area { background: #1e1e2e; color: #cdd6f4; border-radius: 8px; padding: 1rem; }
.export-area textarea { width: 100%; height: 200px; background: transparent; color: #cdd6f4; border: none; font-family: monospace; font-size: 0.78rem; resize: vertical; outline: none; }
</style>
</head>
<body>
<header>
  <h1>Wombat Round ${roundLabel} — Member Variables</h1>
  <div class="hdr-sub">${entries.length} scripts · ${members.length} members${missingCount > 0 ? ' · <span style="color:#f88">' + missingCount + ' missing proposals</span>' : ' · all proposed'}</div>
  <div class="hdr-search"><input id="search" type="search" placeholder="Filter by script or Q-name…" oninput="filterEntries(this.value)"></div>
  <div id="hdr-count" class="hdr-count"></div>
  <div class="hdr-actions">
    <button class="btn-primary" onclick="exportJSON()">Export JSON</button>
    <button class="btn-secondary" onclick="collapseAll()">Collapse all</button>
    <button class="btn-secondary" onclick="expandAll()">Expand all</button>
  </div>
</header>
<main id="main">
${sections}
<div id="no-results">No entries match the filter.</div>
<details>
  <summary style="cursor:pointer;padding:0.5rem 0;color:#555">Export JSON</summary>
  <div class="export-area">
    <textarea id="export-text" readonly></textarea>
  </div>
</details>
</main>
<script>
const defaultRenames = ${defaultRenamesJson};
let currentRenames = Object.assign({}, defaultRenames);
const excluded = new Set();

function getEffectiveName(key) {
  if (excluded.has(key)) return undefined;
  return currentRenames[key] || defaultRenames[key];
}

function updateExport() {
  const out = {};
  for (const [k, v] of Object.entries(currentRenames)) {
    if (!excluded.has(k) && v) out[k] = v;
  }
  const ta = document.getElementById('export-text');
  if (ta) ta.value = JSON.stringify(out, null, 2);
}

function onCustomInput(input) {
  const key = input.dataset.key;
  const val = input.value.trim();
  if (val) {
    currentRenames[key] = val;
    input.classList.add('overridden');
  } else {
    currentRenames[key] = defaultRenames[key] || '';
    input.classList.remove('overridden');
  }
  const td = input.closest('tr').querySelector('.col-proposed code');
  if (td) td.textContent = currentRenames[key] || '—';
  updateExport();
}

function onExcludeChange(cb) {
  const key = cb.dataset.key;
  if (cb.checked) excluded.add(key);
  else excluded.delete(key);
  updateExport();
}

function exportJSON() {
  const out = {};
  for (const [k, v] of Object.entries(currentRenames)) {
    if (!excluded.has(k) && v) out[k] = v;
  }
  const blob = new Blob([JSON.stringify(out, null, 2)], {type: 'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'renames-${roundLabel}-approved.json';
  a.click();
}

function filterEntries(q) {
  const lq = q.toLowerCase();
  let visible = 0;
  document.querySelectorAll('.entry').forEach(el => {
    const name = (el.dataset.name || '') + ' ' + (el.dataset.script || '');
    const show = !lq || name.toLowerCase().includes(lq);
    el.style.display = show ? '' : 'none';
    if (show) visible++;
  });
  const nr = document.getElementById('no-results');
  if (nr) nr.style.display = visible === 0 ? 'block' : 'none';
  const cnt = document.getElementById('hdr-count');
  if (cnt) cnt.textContent = q ? \`\${visible} of ${entries.length} shown\` : '';
}

function collapseAll() {
  document.querySelectorAll('.src-block').forEach(d => d.open = false);
}
function expandAll() {
  document.querySelectorAll('.src-block').forEach(d => d.open = true);
}

updateExport();
</script>
</body>
</html>`;

fs.writeFileSync(outFile, html);
const size = (html.length / 1024 / 1024).toFixed(1);
console.log(`\nWrote ${outFile} (${size} MB)`);
console.log(`Default renames: ${Object.keys(defaultRenames).length} entries`);
const missing = members.filter(m => !proposals[`${m.script}.${m.name}`]);
console.log(`Missing proposals: ${missing.length}`);
if (missing.length > 0) missing.forEach(m => console.log(`  ${m.script}.${m.name}`));
