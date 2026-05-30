#!/usr/bin/env node
'use strict';
// apply-renames.js
// Applies a rename mapping (renames-N.json) to all Wombat scripts.
//
// Key formats in the JSON:
//   "script.Q"          — function or member: replace in defining script + all inheritors
//   "script.fnQ:localQ" — local/param: replace only within fnQ's body in script.m
//   "Q"                 — bare (legacy): replace in all scripts (use sparingly)
//
// Usage: node apply-renames.js renames-N.json [--scripts-dir ./scripts] [--mark-unint]

const fs = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const renameFile = argv.find(a => !a.startsWith('--'));
const scriptsDir = getArg('--scripts-dir', './scripts');
const markUnint = argv.includes('--mark-unint');
const symbolsFile = getArg('--symbols', './symbols.json');

if (!renameFile || !fs.existsSync(renameFile)) {
  console.error('Usage: node apply-renames.js renames-N.json [--scripts-dir ./scripts] [--mark-unint]');
  process.exit(1);
}

const newRenames = JSON.parse(fs.readFileSync(renameFile, 'utf8'));

let renames = {};
if (fs.existsSync('./renames.json')) {
  renames = JSON.parse(fs.readFileSync('./renames.json', 'utf8'));
}
Object.assign(renames, newRenames);

let symbols = {};
let inheritMap = {};
if (fs.existsSync(symbolsFile)) {
  const data = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));
  symbols = data.symbols;
  inheritMap = data.inherits;
}

if (markUnint) {
  for (const [qual, sym] of Object.entries(symbols)) {
    if (sym.is_leaf && sym.is_q && !renames[qual] && !renames[sym.name]) {
      renames[qual] = 'UNINT_' + sym.name;
    }
  }
}

// Build inheritance chains: script -> set of all ancestors
function ancestors(script) {
  const chain = new Set();
  let cur = inheritMap[script];
  while (cur) {
    chain.add(cur);
    cur = inheritMap[cur];
  }
  return chain;
}

const allScripts = fs.readdirSync(scriptsDir).filter(f => f.endsWith('.m')).map(f => path.basename(f, '.m'));

// Classify each rename key into one of three categories:
//   scoped[defScript][fnQ][localQ] = newName  — body-scoped (script.fnQ:localQ)
//   global[script][Q] = newName               — script-wide (script.Q or bare Q)

const scopedMap = {}; // defScript -> fnQ -> localQ -> newName
const globalMap = {}; // script -> Q -> newName
for (const s of allScripts) globalMap[s] = {};

for (const [key, newName] of Object.entries(renames)) {
  const colonIdx = key.indexOf(':');
  if (colonIdx > 0) {
    // Scoped local/param: "script.fnQ:localQ"
    const dotIdx = key.indexOf('.');
    if (dotIdx < 0 || dotIdx > colonIdx) {
      console.warn(`Ignoring malformed scoped key: ${key}`);
      continue;
    }
    const defScript = key.slice(0, dotIdx);
    const fnQ = key.slice(dotIdx + 1, colonIdx);
    const localQ = key.slice(colonIdx + 1);
    if (!scopedMap[defScript]) scopedMap[defScript] = {};
    if (!scopedMap[defScript][fnQ]) scopedMap[defScript][fnQ] = {};
    scopedMap[defScript][fnQ][localQ] = newName;
  } else {
    const dotIdx = key.indexOf('.');
    if (dotIdx > 0 && key[0] !== '@') {
      // Qualified: "script.Q" — apply in defining script + inheritors
      const defScript = key.slice(0, dotIdx);
      const qName = key.slice(dotIdx + 1);
      for (const script of allScripts) {
        if (script === defScript || ancestors(script).has(defScript)) {
          globalMap[script][qName] = newName;
        }
      }
    } else {
      // Bare: apply in all scripts (legacy)
      for (const script of allScripts) {
        globalMap[script][key] = newName;
      }
    }
  }
}

// Replace Q-codes within a single function body.
// Finds the function identified by fnName (Q-code or renamed name), then replaces
// only within its braced body. Returns [newSrc, count].
const Q_RE_BODY = /\bQ[0-9A-Z]{3}\b/g;

function applyInFunctionBody(src, fnName, localMap) {
  const esc = fnName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const headerRe = new RegExp(`\\bfunction\\s+\\w+\\s+${esc}\\s*\\(`);
  const matchResult = headerRe.exec(src);
  if (!matchResult) return [src, 0];

  const paramStart = matchResult.index + matchResult[0].length; // right after '('
  let i = paramStart;
  let parenDepth = 1;
  while (i < src.length && parenDepth > 0) {
    if (src[i] === '(') parenDepth++;
    else if (src[i] === ')') parenDepth--;
    i++;
  }
  const paramEnd = i - 1; // position of closing ')'

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

  const replFn = m => { if (localMap[m]) { count++; return localMap[m]; } return m; };
  let count = 0;

  Q_RE_BODY.lastIndex = 0;
  const newParams = src.slice(paramStart, paramEnd).replace(Q_RE_BODY, replFn);
  Q_RE_BODY.lastIndex = 0;
  const newBody = src.slice(bodyStart, bodyEnd).replace(Q_RE_BODY, replFn);

  return [
    src.slice(0, paramStart) + newParams + src.slice(paramEnd, bodyStart) + newBody + src.slice(bodyEnd),
    count
  ];
}

// Apply substitutions to each script file.
// Order: scoped (body-local) first, then global (script-wide), so function names
// can still be found by their Q-code when we locate their body.
let totalReplacements = 0;
const Q_RE = /\bQ[0-9A-Z]{3}\b/g;

for (const script of allScripts) {
  const hasScopedWork = scopedMap[script] && Object.keys(scopedMap[script]).length > 0;
  const hasGlobalWork = Object.keys(globalMap[script]).length > 0;
  if (!hasScopedWork && !hasGlobalWork) continue;

  const filePath = path.join(scriptsDir, script + '.m');
  if (!fs.existsSync(filePath)) continue;

  let src = fs.readFileSync(filePath, 'utf8');
  let count = 0;

  // Step 1: scoped replacements within function bodies
  if (hasScopedWork) {
    for (const [fnQ, localMap] of Object.entries(scopedMap[script])) {
      // Try by original Q-name first; if not found, try the renamed name (previous round)
      let [newSrc, n] = applyInFunctionBody(src, fnQ, localMap);
      if (n === 0) {
        const fnRenamed = globalMap[script][fnQ] || renames[`${script}.${fnQ}`] || renames[fnQ];
        if (fnRenamed && fnRenamed !== fnQ) {
          [newSrc, n] = applyInFunctionBody(src, fnRenamed, localMap);
        }
      }
      src = newSrc;
      count += n;
    }
  }

  // Step 2: global replacements across the whole script
  if (hasGlobalWork) {
    const subMap = globalMap[script];
    Q_RE.lastIndex = 0;
    const newSrc = src.replace(Q_RE, m => {
      if (subMap[m]) { count++; return subMap[m]; }
      return m;
    });
    src = newSrc;
  }

  if (count > 0) {
    fs.writeFileSync(filePath, src);
    totalReplacements += count;
    console.log(`  ${script}.m: ${count} replacements`);
  }
}

fs.writeFileSync('./renames.json', JSON.stringify(renames, null, 2));
console.log(`\nApplied ${totalReplacements} replacements across ${allScripts.length} scripts.`);
console.log(`Cumulative renames saved to renames.json (${Object.keys(renames).length} entries).`);
console.log(`\nRun: node extract-symbols.js && node regen-preview-2.js --proposals renames-N-critiqued.json`);
