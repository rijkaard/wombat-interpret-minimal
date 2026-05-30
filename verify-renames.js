#!/usr/bin/env node
'use strict';
// verify-renames.js
// Verifies correctness of applied renames by replaying renames.json forward
// against the originals in ../rundir/scripts.wombat/ and diffing the result
// against the working copies in ./scripts/.
//
// Handles all three key formats (mirrors apply-renames.js exactly):
//   "script.Q"          — qualified: applied in defining script + inheritors
//   "script.fnQ:localQ" — scoped: applied only within fnQ's body in script
//   "Q"                 — bare: applied in all scripts
//
// Usage: node verify-renames.js [--orig-dir PATH] [--scripts-dir PATH] [--fix]
//   --orig-dir    path to original plain-text scripts  (default: ../rundir/scripts.wombat)
//   --scripts-dir path to working copies               (default: ./scripts)
//   --fix         overwrite working copies with the expected output

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const origDir    = getArg('--orig-dir',    '../rundir/scripts.wombat');
const scriptsDir = getArg('--scripts-dir', './scripts');
const fixMode    = argv.includes('--fix');
const renamesFile  = getArg('--renames',  './renames.json');
const symbolsFile  = getArg('--symbols',  './symbols.json');

if (!fs.existsSync(renamesFile)) { console.error('renames.json not found'); process.exit(1); }
if (!fs.existsSync(symbolsFile)) { console.error('symbols.json not found — run extract-symbols.js first'); process.exit(1); }
if (!fs.existsSync(origDir))     { console.error('Original scripts dir not found:', origDir); process.exit(1); }

const renames = JSON.parse(fs.readFileSync(renamesFile, 'utf8'));
const { inherits: inheritMap } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));

function ancestors(script) {
  const chain = new Set();
  let cur = inheritMap[script];
  while (cur) { chain.add(cur); cur = inheritMap[cur]; }
  return chain;
}

const allScripts = fs.readdirSync(scriptsDir)
  .filter(f => f.endsWith('.m'))
  .map(f => path.basename(f, '.m'));

// Build scopedMap and globalMap (same as apply-renames.js)
const scopedMap = {}; // defScript -> fnQ -> localQ -> newName
const globalMap = {}; // script -> Q -> newName
for (const s of allScripts) globalMap[s] = {};

for (const [key, newName] of Object.entries(renames)) {
  const colonIdx = key.indexOf(':');
  if (colonIdx > 0) {
    const dotIdx = key.indexOf('.');
    if (dotIdx < 0 || dotIdx > colonIdx) { console.warn(`Ignoring malformed scoped key: ${key}`); continue; }
    const defScript = key.slice(0, dotIdx);
    const fnQ = key.slice(dotIdx + 1, colonIdx);
    const localQ = key.slice(colonIdx + 1);
    if (!scopedMap[defScript]) scopedMap[defScript] = {};
    if (!scopedMap[defScript][fnQ]) scopedMap[defScript][fnQ] = {};
    scopedMap[defScript][fnQ][localQ] = newName;
  } else {
    const dotIdx = key.indexOf('.');
    if (dotIdx > 0 && key[0] !== '@') {
      const defScript = key.slice(0, dotIdx);
      const qName = key.slice(dotIdx + 1);
      for (const s of allScripts) {
        if (s === defScript || ancestors(s).has(defScript)) {
          globalMap[s][qName] = newName;
        }
      }
    } else {
      for (const s of allScripts) globalMap[s][key] = newName;
    }
  }
}

// Apply scoped replacements within a single function body (same as apply-renames.js)
const Q_RE_BODY = /\bQ[0-9A-Z]{3}\b/g;
function applyInFunctionBody(src, fnName, localMap) {
  const esc = fnName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const headerRe = new RegExp(`\\bfunction\\s+\\w+\\s+${esc}\\s*\\(`);
  const matchResult = headerRe.exec(src);
  if (!matchResult) return [src, 0];
  let i = matchResult.index + matchResult[0].length;
  let parenDepth = 1;
  while (i < src.length && parenDepth > 0) {
    if (src[i] === '(') parenDepth++;
    else if (src[i] === ')') parenDepth--;
    i++;
  }
  while (i < src.length && src[i] !== '{') i++;
  if (i >= src.length) return [src, 0];
  const bodyStart = i + 1;
  let depth = 1;
  let j = bodyStart;
  while (j < src.length && depth > 0) {
    if (src[j] === '{') depth++;
    else if (src[j] === '}') depth--;
    j++;
  }
  const bodyEnd = j - 1;
  const before = src.slice(0, bodyStart);
  const body = src.slice(bodyStart, bodyEnd);
  const after = src.slice(bodyEnd);
  let count = 0;
  Q_RE_BODY.lastIndex = 0;
  const newBody = body.replace(Q_RE_BODY, m => {
    if (localMap[m]) { count++; return localMap[m]; }
    return m;
  });
  return [before + newBody + after, count];
}

const Q_RE = /\bQ[0-9A-Z]{3}\b/g;

let nOk = 0, nMismatch = 0, nMissingOrig = 0;
const mismatches = [];

for (const script of allScripts) {
  const origPath = path.join(origDir, script + '.m');
  const workPath = path.join(scriptsDir, script + '.m');

  if (!fs.existsSync(origPath)) { nMissingOrig++; continue; }

  const orig = fs.readFileSync(origPath, 'utf8');
  const work = fs.readFileSync(workPath, 'utf8');

  let expected = orig;

  // Step 1: scoped replacements (same order as apply-renames.js)
  if (scopedMap[script]) {
    for (const [fnQ, localMap] of Object.entries(scopedMap[script])) {
      let [newSrc, n] = applyInFunctionBody(expected, fnQ, localMap);
      if (n === 0) {
        // Try renamed function name (in case the function was renamed in a prior round)
        const fnRenamed = globalMap[script][fnQ] || renames[`${script}.${fnQ}`] || renames[fnQ];
        if (fnRenamed && fnRenamed !== fnQ) {
          [newSrc, n] = applyInFunctionBody(expected, fnRenamed, localMap);
        }
      }
      expected = newSrc;
    }
  }

  // Step 2: global replacements
  const subMap = globalMap[script];
  if (Object.keys(subMap).length > 0) {
    Q_RE.lastIndex = 0;
    expected = expected.replace(Q_RE, m => subMap[m] ?? m);
  }

  if (expected === work) {
    nOk++;
  } else {
    nMismatch++;
    const expLines  = expected.split('\n');
    const workLines = work.split('\n');
    const diffLines = [];
    const maxLen = Math.max(expLines.length, workLines.length);
    for (let i = 0; i < maxLen; i++) {
      if (expLines[i] !== workLines[i]) {
        diffLines.push({ line: i + 1, expected: expLines[i] ?? '(missing)', actual: workLines[i] ?? '(missing)' });
      }
    }
    mismatches.push({ script, diffLines });
    if (fixMode) fs.writeFileSync(workPath, expected);
  }
}

if (mismatches.length > 0) {
  for (const { script, diffLines } of mismatches) {
    console.log(`\n\x1b[31m✗ ${script}.m\x1b[0m (${diffLines.length} differing line${diffLines.length !== 1 ? 's' : ''})`);
    for (const d of diffLines.slice(0, 10)) {
      console.log(`  L${d.line}`);
      console.log(`    expected: ${d.expected}`);
      console.log(`    actual  : ${d.actual}`);
    }
    if (diffLines.length > 10) console.log(`  ... and ${diffLines.length - 10} more`);
  }
}

console.log(`\n${'─'.repeat(50)}`);
console.log(`OK:                ${nOk}`);
console.log(`Mismatches:        ${nMismatch}${fixMode && nMismatch > 0 ? ' (fixed)' : ''}`);
console.log(`Missing originals: ${nMissingOrig}`);

if (nMismatch > 0 && !fixMode) {
  console.log('\nRun with --fix to overwrite working copies with expected output.');
  process.exit(1);
} else {
  process.exit(0);
}
