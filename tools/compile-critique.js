#!/usr/bin/env node
'use strict';
// compile-critique.js
// Reads all .critique files from step-N.critique/ and the original proposals,
// compiles a final renames-N.json (applying suggestions where verdict="suggest"),
// and writes a diff of changed entries only.
//
// .critique files may be:
//   - A JSON object: { "script": "...", "renames": { key: {verdict,suggestion?,reason?} }, "commentary": "..." }
//   - A JSON array of the above objects (when an agent processed a batch)
//
// Usage:
//   node compile-critique.js renames-N-raw.json [--critique-dir ./step-N.critique]
//   [--out renames-N.json] [--diff step-N.critique/diff.txt]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const proposalsFile = argv.find(a => !a.startsWith('--'));
const round         = getArg('--round', '3');
const critiqueDir   = getArg('--critique-dir', path.join(__dirname, `../step-${round}.critique`));
const outFile       = getArg('--out', path.join(__dirname, `../renames/renames-${round}.json`));
const diffFile      = getArg('--diff', path.join(critiqueDir, 'diff.txt'));

if (!proposalsFile || !fs.existsSync(proposalsFile)) {
  console.error('Usage: compile-critique.js renames-N-raw.json [--critique-dir DIR] [--out FILE] [--diff FILE]');
  process.exit(1);
}
if (!fs.existsSync(critiqueDir)) {
  console.error(`Critique dir not found: ${critiqueDir}`);
  process.exit(1);
}

const proposals = JSON.parse(fs.readFileSync(proposalsFile, 'utf8'));

// ── 1. Load all .critique files ───────────────────────────────────────────────
// Collect: scriptName → { key → { verdict, suggestion?, reason? } }
const critiqueMap = {}; // key → { verdict, suggestion?, reason? }
const commentaries = []; // [ { script, commentary } ] — for reporting

const critiqueFiles = fs.readdirSync(critiqueDir)
  .filter(f => (f.endsWith('.critique') || (f.endsWith('.json') && f !== 'batches.json' && f !== 'diff.json')))
  .map(f => path.join(critiqueDir, f));

let nFiles = 0, nScripts = 0;
for (const fp of critiqueFiles) {
  nFiles++;
  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(fp, 'utf8'));
  } catch (e) {
    console.warn(`  WARN: Could not parse ${fp}: ${e.message}`);
    continue;
  }
  const entries = Array.isArray(parsed) ? parsed : [parsed];
  for (const entry of entries) {
    if (!entry || !entry.renames) continue;
    nScripts++;
    if (entry.commentary && entry.commentary.trim()) {
      commentaries.push({ script: entry.script || '?', text: entry.commentary.trim() });
    }
    for (const [key, crit] of Object.entries(entry.renames)) {
      critiqueMap[key] = crit;
    }
  }
}

console.log(`Loaded ${nFiles} .critique file(s) covering ${nScripts} script(s)`);
console.log(`  ${Object.keys(critiqueMap).length} critique entries for ${Object.keys(proposals).length} proposals`);

// ── 2. Compile final renames ──────────────────────────────────────────────────
const final = {};
const diffs = []; // { key, proposed, final, reason }

let nAccept = 0, nSuggest = 0, nUncritiqued = 0;

for (const [key, proposed] of Object.entries(proposals)) {
  const crit = critiqueMap[key];
  if (!crit) {
    final[key] = proposed;
    nUncritiqued++;
  } else if (crit.verdict === 'suggest' && crit.suggestion && crit.suggestion !== proposed) {
    final[key] = crit.suggestion;
    nSuggest++;
    diffs.push({ key, proposed, final: crit.suggestion, reason: crit.reason || '' });
  } else {
    final[key] = proposed;
    nAccept++;
  }
}

// ── 3. Write final renames JSON ───────────────────────────────────────────────
fs.writeFileSync(outFile, JSON.stringify(final, null, 2));
console.log(`\nWrote ${outFile} (${Object.keys(final).length} entries)`);
console.log(`  Accept: ${nAccept + nUncritiqued} (${nAccept} critiqued+accepted, ${nUncritiqued} uncritiqued)`);
console.log(`  Changed: ${nSuggest}`);

// ── 4. Write diff ─────────────────────────────────────────────────────────────
if (diffs.length === 0) {
  const msg = 'No renames were changed by critique.\n';
  fs.writeFileSync(diffFile, msg);
  console.log(`\nDiff: no changes (${diffFile})`);
} else {
  const maxKeyLen = Math.max(...diffs.map(d => d.key.length));
  const lines = [
    `Changed renames: ${diffs.length} of ${Object.keys(proposals).length} total`,
    '',
    ...diffs.map(d => {
      const pad = ' '.repeat(maxKeyLen - d.key.length);
      const reason = d.reason ? `  // ${d.reason}` : '';
      return `"${d.key}"${pad}  "${d.proposed}" → "${d.final}"${reason}`;
    }),
  ];

  if (commentaries.length > 0) {
    lines.push('', '─'.repeat(60), 'Script commentaries:', '');
    for (const { script, text } of commentaries) {
      lines.push(`  ${script}: ${text}`);
    }
  }

  fs.writeFileSync(diffFile, lines.join('\n') + '\n');
  console.log(`\nDiff written to ${diffFile} (${diffs.length} changed entries)`);

  // Print first few diffs to console
  const preview = diffs.slice(0, 15);
  for (const d of preview) {
    const reason = d.reason ? `  // ${d.reason}` : '';
    console.log(`  "${d.key}": "${d.proposed}" → "${d.final}"${reason}`);
  }
  if (diffs.length > 15) console.log(`  ... and ${diffs.length - 15} more (see ${diffFile})`);
}

// ── 5. Print commentaries ─────────────────────────────────────────────────────
if (commentaries.length > 0) {
  console.log(`\nScript commentaries (${commentaries.length}):`);
  for (const { script, text } of commentaries.slice(0, 20)) {
    console.log(`  ${script}: ${text}`);
  }
  if (commentaries.length > 20) console.log(`  ... and ${commentaries.length - 20} more (see ${diffFile})`);
}
