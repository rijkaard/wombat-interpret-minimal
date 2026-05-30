#!/usr/bin/env node
'use strict';
// apply-renames-locals.js — applies local/param Q-code renames from round-10 results.
// Keys are "script.qualified.QXXX" (qualified includes @ prefix for triggers).
// Strategy: if all functions in a script agree on a name for a Q-code → global replace;
//           if they disagree → scoped replace per function body.
// Usage: node apply-renames-locals.js [--input renames-10-final.json]
//                                      [--scripts-dir ./scripts]
//                                      [--renames renames.json] [--dry-run]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const inputFile  = getArg('--input',   './renames-10-final.json');
const scriptsDir = getArg('--scripts-dir', './scripts');
const renamesFile = getArg('--renames', './renames.json');
const dryRun     = argv.includes('--dry-run');

if (!fs.existsSync(inputFile)) {
  console.error(`Input file not found: ${inputFile}`);
  process.exit(1);
}

const newRenames = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
console.log(`Loaded ${Object.keys(newRenames).length} rename entries`);

// ── Parse key: "script.qualified.QXXX" ───────────────────────────────────────
// qualified is everything between first "." and last ".Q[0-9A-Z]{3}"

const Q_KEY_RE = /^(.+?)\.(.+)\.(Q[0-9A-Z]{3})$/;

function parseKey(key) {
  const m = Q_KEY_RE.exec(key);
  if (!m) return null;
  return { script: m[1], qualified: `${m[1]}.${m[2]}`, funcSig: m[2], qcode: m[3] };
}

// ── Group renames by script ───────────────────────────────────────────────────

const byScript = {};
for (const [key, name] of Object.entries(newRenames)) {
  const parsed = parseKey(key);
  if (!parsed) { console.warn(`Unrecognised key: ${key}`); continue; }
  const { script, funcSig, qcode } = parsed;
  if (!byScript[script]) byScript[script] = {};
  if (!byScript[script][qcode]) byScript[script][qcode] = [];
  byScript[script][qcode].push({ funcSig, name, key });
}

// ── Function body locator ─────────────────────────────────────────────────────

function findFunctionRange(lines, funcSig) {
  // funcSig: "@trigger_name", "@trigger_name(filter)", "function_name"
  let headerRE;
  if (funcSig.startsWith('@')) {
    const inner = funcSig.slice(1);
    const parenIdx = inner.indexOf('(');
    if (parenIdx >= 0) {
      const name   = escapeRE(inner.slice(0, parenIdx));
      const filter = escapeRE(inner.slice(parenIdx + 1, inner.lastIndexOf(')')));
      headerRE = new RegExp(`^\\s*trigger\\s+${name}\\s*\\(${filter}\\)`);
    } else {
      const name = escapeRE(inner);
      headerRE = new RegExp(`^\\s*trigger\\s+${name}\\s*(\\{|$)`);
    }
  } else {
    const name = escapeRE(funcSig);
    headerRE = new RegExp(`\\bfunction\\b[^{;]*\\b${name}\\s*\\(`);
  }

  let startIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (headerRE.test(lines[i])) { startIdx = i; break; }
  }
  if (startIdx < 0) return null;

  let i = startIdx, depth = 0, started = false;
  while (i < lines.length) {
    const opens  = (lines[i].match(/\{/g) || []).length;
    const closes = (lines[i].match(/\}/g) || []).length;
    depth += opens - closes;
    if (opens > 0) started = true;
    i++;
    if (started && depth === 0) break;
    if (i - startIdx > 600) break;
  }
  return { start: startIdx, end: i - 1 };
}

function escapeRE(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ── Apply renames to a script file ───────────────────────────────────────────

function applyToFile(scriptName, qcodeMap) {
  const filePath = path.join(scriptsDir, scriptName + '.m');
  if (!fs.existsSync(filePath)) {
    console.warn(`  SKIP: file not found: ${filePath}`);
    return 0;
  }

  let lines = fs.readFileSync(filePath, 'utf8').split('\n');
  const Q_WORD = /\bQ[0-9A-Z]{3}\b/g;
  let totalReplaced = 0;

  for (const [qcode, entries] of Object.entries(qcodeMap)) {
    // Always scoped — replace only within the specific function body
    for (const { funcSig, name } of entries) {
      const range = findFunctionRange(lines, funcSig);
      if (!range) {
        console.warn(`  WARN: function not found: ${scriptName}.${funcSig}`);
        continue;
      }
      const re = new RegExp(`\\b${qcode}\\b`, 'g');
      let count = 0;
      for (let i = range.start; i <= range.end; i++) {
        lines[i] = lines[i].replace(re, () => { count++; return name; });
      }
      totalReplaced += count;
    }
  }

  if (!dryRun) fs.writeFileSync(filePath, lines.join('\n'));
  return totalReplaced;
}

// ── Main ──────────────────────────────────────────────────────────────────────

const cumRenames = fs.existsSync(renamesFile)
  ? JSON.parse(fs.readFileSync(renamesFile, 'utf8')) : {};

let filesChanged = 0, totalReplacements = 0;

for (const [scriptName, qcodeMap] of Object.entries(byScript)) {
  const n = applyToFile(scriptName, qcodeMap);
  if (n > 0) {
    filesChanged++;
    totalReplacements += n;
    if (!dryRun) console.log(`  ${scriptName}.m: ${n} replacements`);
  }
}

// Merge into cumulative renames.json
if (!dryRun) {
  Object.assign(cumRenames, newRenames);
  fs.writeFileSync(renamesFile, JSON.stringify(cumRenames, null, 2));
  console.log(`\nUpdated renames.json: now ${Object.keys(cumRenames).length} entries`);
}

console.log(`\n${dryRun ? '[DRY RUN] ' : ''}Files changed: ${filesChanged}`);
console.log(`Total replacements: ${totalReplacements}`);
