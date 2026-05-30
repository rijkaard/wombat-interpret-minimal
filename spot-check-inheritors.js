#!/usr/bin/env node
'use strict';
// spot-check-inheritors.js
// Verifies that all functions/members renamed on a given script are called
// by their new names (not Q-codes) in all scripts that inherit from it,
// including transitive inheritors (through middleman scripts).
//
// Usage: node spot-check-inheritors.js <script-name> [--scripts-dir ./scripts]
//   e.g. node spot-check-inheritors.js spelskil

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const targetScript = argv.find(a => !a.startsWith('--'));
const scriptsDir   = getArg('--scripts-dir', './scripts');
const renamesFile  = getArg('--renames', './renames.json');
const symbolsFile  = getArg('--symbols', './symbols.json');

if (!targetScript) {
  console.error('Usage: spot-check-inheritors.js <script-name> [--scripts-dir ./scripts]');
  process.exit(1);
}

const renames = JSON.parse(fs.readFileSync(renamesFile, 'utf8'));
const { inherits: inheritMap } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));

// Collect all function/member Q-codes renamed on the target script
const prefix = targetScript + '.';
const fnRenames = Object.entries(renames)
  .filter(([k]) => k.startsWith(prefix) && !k.includes(':'))
  .map(([k, v]) => ({ q: k.slice(prefix.length), name: v }));

if (fnRenames.length === 0) {
  console.log('No function/member renames found for', targetScript);
  process.exit(0);
}
console.log(`Checking ${fnRenames.length} renamed functions/members on ${targetScript}.m`);

// Build reverse inheritance map: parent -> [children]
const children = {};
for (const [child, parent] of Object.entries(inheritMap)) {
  if (!children[parent]) children[parent] = [];
  children[parent].push(child);
}

// BFS to get all transitive inheritors
const queue = [targetScript];
const visited = new Set([targetScript]);
while (queue.length) {
  const cur = queue.shift();
  for (const c of (children[cur] || [])) {
    if (!visited.has(c)) { visited.add(c); queue.push(c); }
  }
}
visited.delete(targetScript);
const inheritors = [...visited].sort();
console.log(`Scanning ${inheritors.length} inheriting scripts (${(children[targetScript] || []).length} direct, ${inheritors.length - (children[targetScript] || []).length} transitive)\n`);

// Build match pattern
const qMap = Object.fromEntries(fnRenames.map(e => [e.q, e.name]));
const allScriptsToCheck = [targetScript, ...inheritors];

let totalHits = 0;
const failedScripts = [];

for (const script of allScriptsToCheck) {
  const p = path.join(scriptsDir, script + '.m');
  if (!fs.existsSync(p)) continue;
  const src = fs.readFileSync(p, 'utf8');
  const lines = src.split('\n');
  const scriptHits = [];
  for (let i = 0; i < lines.length; i++) {
    const pat = new RegExp('\\b(' + fnRenames.map(e => e.q).join('|') + ')\\b', 'g');
    let m;
    while ((m = pat.exec(lines[i])) !== null) {
      scriptHits.push({ line: i + 1, q: m[1], newName: qMap[m[1]], text: lines[i].trim() });
    }
  }
  if (scriptHits.length > 0) {
    totalHits += scriptHits.length;
    failedScripts.push({ script, scriptHits });
  }
}

if (failedScripts.length === 0) {
  console.log(`PASS: No ${targetScript} Q-codes found in any of the ${allScriptsToCheck.length} scripts checked.`);
  process.exit(0);
} else {
  console.log(`FAIL: ${failedScripts.length} scripts still contain Q-codes that should be renamed:\n`);
  for (const { script, scriptHits } of failedScripts) {
    const label = script === targetScript ? ' (defining script)' : '';
    console.log(`  \x1b[31m${script}.m${label}\x1b[0m`);
    for (const h of scriptHits) {
      console.log(`    L${h.line}: ${h.q} (should be ${h.newName})`);
      console.log(`      ${h.text}`);
    }
  }
  console.log(`\nTotal occurrences: ${totalHits}`);
  process.exit(1);
}
