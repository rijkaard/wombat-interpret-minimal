#!/usr/bin/env node
'use strict';
// reverse-verify.js
// Verifies reversibility by applying the INVERSE of renames.json to working
// copies, writing results to a temp dir, then diffing against the originals.
//
// Inverse key derivation:
//   qualified "script.Q" → newName   ⟹  qualified "script.newName" → Q
//   scoped "script.fnQ:localQ" → localNewName
//                               ⟹  scoped "script.fnNewName:localNewName" → localQ
//                                   (where fnNewName = renames["script.fnQ"])
//   bare "Q" → newName             ⟹  bare "newName" → Q
//   locals "script.funcSig.QXXX" → name
//                               ⟹  within funcSig body: name → QXXX
//
// Inverse application ORDER:
//   Step 0: locals inverse (name → Q within funcSig body, funcSig is new name)
//   Step 1: scoped inverse (localNewName → localQ within fnNewName body)
//   Step 2: global inverse (newName → Q everywhere)
//
// Usage: node reverse-verify.js [--orig-dir PATH] [--scripts-dir PATH] [--out-dir PATH]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const origDir    = getArg('--orig-dir',    '../rundir/scripts.wombat');
const scriptsDir = getArg('--scripts-dir', './scripts');
const outDir     = getArg('--out-dir',     '/tmp/wombat-reversed');
const renamesFile = getArg('--renames',   './renames.json');
const symbolsFile = getArg('--symbols',   './symbols.json');

if (!fs.existsSync(renamesFile)) { console.error('renames.json not found'); process.exit(1); }
if (!fs.existsSync(symbolsFile)) { console.error('symbols.json not found'); process.exit(1); }
if (!fs.existsSync(origDir))     { console.error('Original scripts dir not found:', origDir); process.exit(1); }

fs.mkdirSync(outDir, { recursive: true });

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

// Build a lookup for qualified entries: "script.fnQ" → fnNewName
// (needed to derive fnNewName for scoped inverse keys)
const qualifiedNewName = {}; // "script.Q" → newName
for (const [key, newName] of Object.entries(renames)) {
  if (!key.includes(':') && key.includes('.') && key[0] !== '@') {
    qualifiedNewName[key] = newName;
  }
}

// Build inverse scopedMap and globalMap
//   inverseScopedMap[defScript][fnNewName][localNewName] = localQ
//   inverseGlobalMap[script][newName] = Q
const inverseScopedMap = {};
const inverseGlobalMap = {};
for (const s of allScripts) inverseGlobalMap[s] = {};

for (const [key, newName] of Object.entries(renames)) {
  const colonIdx = key.indexOf(':');
  if (colonIdx > 0) {
    // Scoped: "script.fnQ:localQ" → localNewName
    const dotIdx = key.indexOf('.');
    if (dotIdx < 0 || dotIdx > colonIdx) continue;
    const defScript = key.slice(0, dotIdx);
    const fnQ       = key.slice(dotIdx + 1, colonIdx);
    const localQ    = key.slice(colonIdx + 1);
    // fnNewName: look up qualified rename for this function
    const fnNewName = qualifiedNewName[`${defScript}.${fnQ}`] || fnQ;
    // localNewName = newName (value of the scoped entry)
    const localNewName = newName;
    if (!inverseScopedMap[defScript]) inverseScopedMap[defScript] = {};
    if (!inverseScopedMap[defScript][fnNewName]) inverseScopedMap[defScript][fnNewName] = {};
    inverseScopedMap[defScript][fnNewName][localNewName] = localQ;
  } else {
    const dotIdx = key.indexOf('.');
    if (dotIdx > 0 && key[0] !== '@') {
      const rest = key.slice(dotIdx + 1);
      // Skip three-part dot keys: "script.funcSig.QXXX"
      // These are applied by apply-renames-locals.js (not apply-renames.js),
      // so convert-scripts.bash never applies them — nothing to invert.
      if (rest.includes('.')) continue;
      // Qualified: "script.Q" → newName  ⟹  inverse in same scripts
      const defScript = key.slice(0, dotIdx);
      const qName     = rest;
      for (const s of allScripts) {
        if (s === defScript || ancestors(s).has(defScript)) {
          inverseGlobalMap[s][newName] = qName;
        }
      }
    } else {
      // Bare: apply inverse in all scripts
      for (const s of allScripts) {
        inverseGlobalMap[s][newName] = key;
      }
    }
  }
}

// Build inverse locals map from three-part dot keys: "script.funcSig.QXXX" → name
//   inverseLocalsMap[script][funcSig][name] = qcode
// NOTE: funcSig may contain colons (e.g. trigger filters like @time("min:**")).
// Distinguish from colon-scoped keys by checking lastColon vs lastDot:
//   colon-scoped: "script.fnQ:localQ" → lastColon > lastDot
//   three-part:   "script.funcSig.QXXX" → lastDot > lastColon (or no colon)
const inverseLocalsMap = {};
for (const [key, newName] of Object.entries(renames)) {
  const lastDot = key.lastIndexOf('.');
  if (lastDot < 0) continue;
  const lastColon = key.lastIndexOf(':');
  if (lastColon > lastDot) continue; // colon-scoped key — skip
  const qcode = key.slice(lastDot + 1);
  if (!/^Q[0-9A-Z]{3}$/.test(qcode)) continue;
  const firstDot = key.indexOf('.');
  if (firstDot === lastDot) continue; // two-part dot key
  const script  = key.slice(0, firstDot);
  const funcSig = key.slice(firstDot + 1, lastDot);
  if (!inverseLocalsMap[script]) inverseLocalsMap[script] = {};
  if (!inverseLocalsMap[script][funcSig]) inverseLocalsMap[script][funcSig] = {};
  inverseLocalsMap[script][funcSig][newName] = qcode;
}

// Replace names outside of string literals only.
// Wombat strings are "..."; this splits on them and only replaces in non-string segments.
function replaceOutsideStrings(src, pat, replFn) {
  const segments = src.split(/(\"[^\"]*\")/);
  return segments.map((seg, i) => {
    if (i % 2 === 1) return seg; // inside a string literal — leave alone
    return seg.replace(pat, replFn);
  }).join('');
}

function escapeRE(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

// Find the character range [start, end) for a named function or trigger,
// including the header/signature line through the closing brace.
// funcSig: plain function name, or "@triggerName" / "@triggerName(filter)" for triggers.
// Returns { start, end } (end is exclusive — past the closing '}') or null.
function findBodyRange(src, funcSig) {
  let headerRe;
  if (funcSig.startsWith('@')) {
    const inner = funcSig.slice(1);
    const pi = inner.indexOf('(');
    if (pi >= 0) {
      const tname  = escapeRE(inner.slice(0, pi));
      const filter = escapeRE(inner.slice(pi + 1, inner.lastIndexOf(')')));
      headerRe = new RegExp(`\\btrigger\\s+${tname}\\s*\\(\\s*${filter}\\s*\\)`);
    } else {
      headerRe = new RegExp(`\\btrigger\\s+${escapeRE(inner)}\\b`);
    }
  } else {
    headerRe = new RegExp(`\\bfunction\\b[^{;]*\\b${escapeRE(funcSig)}\\s*\\(`);
  }
  const m = headerRe.exec(src);
  if (!m) return null;
  const rangeStart = m.index;
  let i = m.index + m[0].length;
  while (i < src.length && src[i] !== '{') i++;
  if (i >= src.length) return null;
  let depth = 1; let j = i + 1;
  while (j < src.length && depth > 0) {
    if (src[j] === '{') depth++;
    else if (src[j] === '}') depth--;
    j++;
  }
  return { start: rangeStart, end: j };
}

// Apply inverse within a function body: find function by fnName (the renamed name
// in the working copy), replace occurrences of keys in localMap with their values.
// Returns [newSrc, count].
function applyInverseInBody(src, fnName, localMap) {
  const esc = fnName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const headerRe = new RegExp(`\\bfunction\\s+\\w+\\s+${esc}\\s*\\(`);
  const hm = headerRe.exec(src);
  if (!hm) return [src, 0];

  const paramStart = hm.index + hm[0].length; // right after '('
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

  const names = Object.keys(localMap).sort((a, b) => b.length - a.length);
  const pat = new RegExp('\\b(' + names.map(n => n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ')\\b', 'g');

  let count = 0;
  const replFn = tok => { if (localMap[tok]) { count++; return localMap[tok]; } return tok; };

  const newParams = replaceOutsideStrings(src.slice(paramStart, paramEnd), pat, replFn);
  const newBody   = replaceOutsideStrings(src.slice(bodyStart, bodyEnd),   pat, replFn);

  return [
    src.slice(0, paramStart) + newParams + src.slice(paramEnd, bodyStart) + newBody + src.slice(bodyEnd),
    count
  ];
}

// Apply inverse to one script's source content.
// ORDER:
//   Step 0: locals inverse (name → Q within funcSig body — undoes apply-renames-locals.js)
//   Step 1: scoped inverse (localNewName → localQ within fnNewName body — undoes apply-renames.js colon keys)
//   Step 2: global inverse (newName → Q globally — undoes apply-renames.js qualified/bare keys)
// Global inverse is string-aware to avoid reversing English words in string literals.
function applyInverse(script, src) {
  let out = src;
  let totalCount = 0;

  // Step 0: locals inverse (name → Q within funcSig scope, including signature).
  if (inverseLocalsMap[script]) {
    for (const [funcSig, localMap] of Object.entries(inverseLocalsMap[script])) {
      const range = findBodyRange(out, funcSig);
      if (!range) continue;
      const { start, end } = range;
      const names = Object.keys(localMap).sort((a, b) => b.length - a.length);
      if (names.length === 0) continue;
      const pat = new RegExp('\\b(' + names.map(escapeRE).join('|') + ')\\b', 'g');
      let count = 0;
      const newSegment = replaceOutsideStrings(out.slice(start, end), pat, m => {
        if (localMap[m]) { count++; return localMap[m]; }
        return m;
      });
      out = out.slice(0, start) + newSegment + out.slice(end);
      totalCount += count;
    }
  }

  // Step 1: scoped inverse (localNewName → localQ within fnNewName's body).
  // fnNewName is the renamed function name present in the working copy.
  if (inverseScopedMap[script]) {
    for (const [fnNewName, localMap] of Object.entries(inverseScopedMap[script])) {
      const [newSrc, n] = applyInverseInBody(out, fnNewName, localMap);
      out = newSrc;
      totalCount += n;
    }
  }

  // Step 2: global inverse (newName → Q), skipping string literals.
  const gMap = inverseGlobalMap[script];
  if (gMap && Object.keys(gMap).length > 0) {
    const names = Object.keys(gMap).sort((a, b) => b.length - a.length);
    const pat = new RegExp('\\b(' + names.map(n => n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ')\\b', 'g');
    let count = 0;
    out = replaceOutsideStrings(out, pat, m => {
      if (gMap[m]) { count++; return gMap[m]; }
      return m;
    });
    totalCount += count;
  }

  return [out, totalCount];
}

// Process all scripts
let nOk = 0, nMismatch = 0, nMissingOrig = 0;
const mismatches = [];
let totalReplacements = 0;

console.log(`Applying inverse renames to ${allScripts.length} scripts → ${outDir}`);
for (const script of allScripts) {
  const workPath = path.join(scriptsDir, script + '.m');
  const origPath = path.join(origDir,    script + '.m');
  const outPath  = path.join(outDir,     script + '.m');

  if (!fs.existsSync(origPath)) { nMissingOrig++; continue; }

  const workSrc = fs.readFileSync(workPath, 'utf8');
  const [reversed, n] = applyInverse(script, workSrc);
  totalReplacements += n;
  fs.writeFileSync(outPath, reversed);

  const orig = fs.readFileSync(origPath, 'utf8');
  if (reversed === orig) {
    nOk++;
  } else {
    nMismatch++;
    const expLines = orig.split('\n');
    const revLines = reversed.split('\n');
    const diffLines = [];
    const maxLen = Math.max(expLines.length, revLines.length);
    for (let i = 0; i < maxLen; i++) {
      if (expLines[i] !== revLines[i]) {
        diffLines.push({ line: i + 1, orig: expLines[i] ?? '(missing)', reversed: revLines[i] ?? '(missing)' });
      }
    }
    mismatches.push({ script, diffLines });
  }
}

if (mismatches.length > 0) {
  for (const { script, diffLines } of mismatches) {
    console.log(`\n\x1b[31m✗ ${script}.m\x1b[0m (${diffLines.length} differing line${diffLines.length !== 1 ? 's' : ''})`);
    for (const d of diffLines.slice(0, 10)) {
      console.log(`  L${d.line}`);
      console.log(`    orig    : ${d.orig}`);
      console.log(`    reversed: ${d.reversed}`);
    }
    if (diffLines.length > 10) console.log(`  ... and ${diffLines.length - 10} more`);
  }
}

console.log(`\n${'─'.repeat(50)}`);
console.log(`Inverse replacements: ${totalReplacements}`);
console.log(`OK:                   ${nOk}`);
console.log(`Mismatches:           ${nMismatch}`);
console.log(`Missing originals:    ${nMissingOrig}`);
console.log(`Reversed files in:    ${outDir}`);

process.exit(nMismatch > 0 ? 1 : 0);
