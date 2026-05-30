#!/usr/bin/env node
'use strict';
// gen-naming-3.js — generates naming prompt files for round-3 leaf functions.
// Usage: node gen-naming-3.js [--scripts-dir ./scripts] [--out-dir ./step-3.naming/prompts]
//                             [--batch-size 8] [--builtins ../ouo/wombat_builtins.inc]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const scriptsDir  = getArg('--scripts-dir', './scripts');
const outDir      = getArg('--out-dir', './step-3.naming/prompts');
const batchSize   = parseInt(getArg('--batch-size', '8'), 10);
const builtinsFile = getArg('--builtins', '../ouo/wombat_builtins.inc');
const symbolsFile  = getArg('--symbols', './symbols.json');
const renamesFile  = getArg('--renames', './renames.json');
const batchesOut   = getArg('--batches', '/tmp/round3_batches.json');

fs.mkdirSync(outDir, { recursive: true });

// ── Load data ─────────────────────────────────────────────────────────────────

const { symbols, inherits: inheritMap } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));
const leaves = Object.values(symbols).filter(s => s.is_leaf && s.is_q);
console.log(`Loaded ${leaves.length} leaf functions`);

const renames = fs.existsSync(renamesFile)
  ? JSON.parse(fs.readFileSync(renamesFile, 'utf8')) : {};

// Build engine API string
let engineApi = '';
if (fs.existsSync(builtinsFile)) {
  const src = fs.readFileSync(builtinsFile, 'utf8');
  const typeChar = { v: 'void', i: 'int', s: 'str', o: 'obj', l: 'list', c: 'loc', q: 'ustr', u: 'any' };
  const lines = [];
  const seen = new Set();
  for (const m of src.matchAll(/\{\.name\s*=\s*"(\w+)".*?\.typeSig\s*=\s*"([^"]+)"/g)) {
    const name = m[1], sig = m[2];
    if (name.startsWith('TK_') || name.startsWith('opr') || seen.has(name)) continue;
    seen.add(name);
    const [ret, ...params] = sig.replace('|', '').split('');
    const pStr = params.map(c => typeChar[c] || c).join(', ');
    const rStr = typeChar[ret] || ret;
    lines.push(rStr === 'void' ? `${name}(${pStr})` : `${rStr} ${name}(${pStr})`);
  }
  engineApi = lines.join('\n');
}

// ── Scan call sites ───────────────────────────────────────────────────────────

const fnQCodes = new Set(leaves.map(l => l.name));
const MAX_CALL_SITES = 5;
const CONTEXT_LINES = 8;
const callSiteMap = {};
for (const q of fnQCodes) callSiteMap[q] = [];

const allScriptFiles = fs.readdirSync(scriptsDir).filter(f => f.endsWith('.m')).sort();
const Q_CALL_RE = /\b(Q[0-9A-Z]{3})\s*\(/g;

process.stdout.write('Scanning call sites');
for (const file of allScriptFiles) {
  const scriptName = path.basename(file, '.m');
  const src = fs.readFileSync(path.join(scriptsDir, file), 'utf8');
  const lines = src.split('\n');
  Q_CALL_RE.lastIndex = 0;
  let m;
  while ((m = Q_CALL_RE.exec(src)) !== null) {
    const q = m[1];
    if (!fnQCodes.has(q)) continue;
    const sites = callSiteMap[q];
    if (sites.length >= MAX_CALL_SITES) continue;
    const before = src.slice(0, m.index);
    const lineIdx = (before.match(/\n/g) || []).length;
    const from = Math.max(0, lineIdx - CONTEXT_LINES);
    const to   = Math.min(lines.length - 1, lineIdx + CONTEXT_LINES);
    sites.push({
      script: scriptName,
      line: lineIdx + 1,
      snippet: lines.slice(from, to + 1).map((l, i) => `${from + i + 1 === lineIdx + 1 ? '→' : ' '} ${String(from + i + 1).padStart(3)}: ${l}`).join('\n'),
    });
  }
}
process.stdout.write(' done.\n');

// ── Build batches ─────────────────────────────────────────────────────────────

// Group leaves by script so related functions appear together
const byScript = {};
for (const leaf of leaves) {
  if (!byScript[leaf.script]) byScript[leaf.script] = [];
  byScript[leaf.script].push(leaf);
}

// Flatten into ordered leaf list (script-grouped)
const orderedLeaves = [];
for (const group of Object.values(byScript)) {
  for (const leaf of group) orderedLeaves.push(leaf);
}

// Split into batches
const batches = [];
for (let i = 0; i < orderedLeaves.length; i += batchSize) {
  batches.push(orderedLeaves.slice(i, i + batchSize));
}

// Save batches manifest for later use
const batchManifest = batches.map(b => b.map(l => ({
  name: l.name,
  script: l.script,
  qualified: l.qualified,
})));
fs.writeFileSync(batchesOut, JSON.stringify(batchManifest, null, 2));
console.log(`Built ${batches.length} batches of up to ${batchSize} leaves`);

// ── Generate prompt files ─────────────────────────────────────────────────────

const SYSTEM_PREAMBLE = `You are naming obfuscated Wombat script functions for a 1998 Ultima Online shard.
Q-codes (Q4P5, Q4NO, etc.) are OSI-internal identifiers. Replace them with concise snake_case names.

RULES:
- ALL names must be snake_case (never camelCase)
- Functions: use verb_noun format describing what the function DOES (e.g. get_owner, collect_metals_from_container)
- Params/locals: short but clear within the function's context (e.g. item, count, target_mobile, i)
- Don't repeat the script name in the name unless necessary for clarity
- Be concise — prefer "count" over "item_count" when context is unambiguous
- Only suggest names for Q-codes in the OUTPUT — do not include already-resolved names

OUTPUT: a single JSON object mapping export keys to snake_case names. Example:
{
  "alchemy.Q4P5": "brew_potion",
  "alchemy.Q4P5:Q4NO": "potion_keg",
  "alchemy.Q4P5:Q47F": "backpack"
}

Keys:
  "script.Q"         → function or member
  "script.fnQ:localQ" → param or local within that function's body

ENGINE API (built-in functions):
${engineApi}

`;

const scriptSourceCache = {};
function getScriptSource(scriptName) {
  if (!scriptSourceCache[scriptName]) {
    const p = path.join(scriptsDir, scriptName + '.m');
    scriptSourceCache[scriptName] = fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '(not found)';
  }
  return scriptSourceCache[scriptName];
}

for (let bi = 0; bi < batches.length; bi++) {
  const batch = batches[bi];
  const batchNum = String(bi + 1).padStart(3, '0');

  // Collect unique scripts in this batch
  const scriptsInBatch = [...new Set(batch.map(l => l.script))];

  let body = '';

  for (const scriptName of scriptsInBatch) {
    const scriptLeaves = batch.filter(l => l.script === scriptName);
    const parentChain = [];
    let cur = inheritMap[scriptName];
    while (cur) { parentChain.push(cur); cur = inheritMap[cur]; }

    body += `\n=== SCRIPT: ${scriptName}.m ===\n`;
    if (parentChain.length > 0) body += `Inherits: ${parentChain.join(' → ')}\n`;

    // Collect all Q-codes to name in this script (from this batch)
    const toName = {};
    for (const leaf of scriptLeaves) {
      const fnKey = `${leaf.script}.${leaf.name}`;
      toName[fnKey] = `function (returns ${leaf.returnType || 'void'})`;
      for (const p of (leaf.params || [])) {
        if (/^Q[0-9A-Z]{3}$/.test(p.name)) {
          toName[`${leaf.script}.${leaf.name}:${p.name}`] = `param (${p.type})`;
        }
      }
      for (const lq of (leaf.q_locals || [])) {
        if (!toName[`${leaf.script}.${leaf.name}:${lq}`]) {
          toName[`${leaf.script}.${leaf.name}:${lq}`] = 'local variable';
        }
      }
    }

    body += '\nQ-CODES TO NAME:\n';
    for (const [key, role] of Object.entries(toName)) {
      body += `  ${key}  [${role}]\n`;
    }

    body += `\n--- FULL SOURCE: ${scriptName}.m ---\n`;
    body += getScriptSource(scriptName);
    body += '\n';

    // Call sites for each function in this batch
    for (const leaf of scriptLeaves) {
      const sites = callSiteMap[leaf.name];
      if (sites && sites.length > 0) {
        body += `\n--- CALL SITES: ${leaf.name} (${sites.length} shown) ---\n`;
        for (const site of sites) {
          body += `[${site.script}.m line ${site.line}]\n${site.snippet}\n\n`;
        }
      }
    }
  }

  const prompt = SYSTEM_PREAMBLE + body;
  const outFile = path.join(outDir, `batch-${batchNum}.txt`);
  fs.writeFileSync(outFile, prompt);
}

console.log(`Wrote ${batches.length} prompt files to ${outDir}`);
console.log(`Batch manifest saved to ${batchesOut}`);
console.log(`\nNext: spawn naming agents reading each prompt file`);
console.log(`Results format: { "script.Q": "name", "script.fnQ:localQ": "name", ... }`);
console.log(`Save combined results as renames-3-raw.json`);
