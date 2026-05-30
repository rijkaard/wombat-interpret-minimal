#!/usr/bin/env node
'use strict';
// gen-naming-members.js — generates naming prompt files for Q-coded member variables.
// Usage: node gen-naming-members.js [--scripts-dir ./scripts] [--out-dir ./step-N.naming/prompts]
//                                   [--batch-size 6] [--builtins ../ouo/wombat_builtins.inc]
//                                   [--round 9]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const scriptsDir   = getArg('--scripts-dir', './scripts');
const outDir       = getArg('--out-dir', './step-9.naming/prompts');
const batchSize    = parseInt(getArg('--batch-size', '6'), 10);
const builtinsFile = getArg('--builtins', '../ouo/wombat_builtins.inc');
const symbolsFile  = getArg('--symbols', './symbols.json');
const renamesFile  = getArg('--renames', './renames.json');
const roundLabel   = getArg('--round', '9');
const batchesOut   = getArg('--batches', `/tmp/round${roundLabel}_batches.json`);

fs.mkdirSync(outDir, { recursive: true });

// ── Load data ─────────────────────────────────────────────────────────────────

const { symbols } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));
const members = Object.values(symbols).filter(s => s.is_q && s.kind === 'member');
console.log(`Loaded ${members.length} Q-coded member variables`);

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

// ── Group members by script ───────────────────────────────────────────────────

const byScript = {};
for (const m of members) {
  if (!byScript[m.script]) byScript[m.script] = [];
  byScript[m.script].push(m);
}

// Flatten: one script per batch entry (scripts are the unit, not individual members)
const scriptNames = Object.keys(byScript).sort();
console.log(`Affected scripts: ${scriptNames.length}`);

// Split into batches of batchSize scripts each
const batches = [];
for (let i = 0; i < scriptNames.length; i += batchSize) {
  batches.push(scriptNames.slice(i, i + batchSize));
}

// Save batches manifest
const batchManifest = batches.map(scriptGroup =>
  scriptGroup.map(s => ({ script: s, members: byScript[s].map(m => m.name) }))
);
fs.writeFileSync(batchesOut, JSON.stringify(batchManifest, null, 2));
console.log(`Built ${batches.length} batches of up to ${batchSize} scripts`);

// ── Script source cache ───────────────────────────────────────────────────────

const scriptSourceCache = {};
function getScriptSource(scriptName) {
  if (!scriptSourceCache[scriptName]) {
    const p = path.join(scriptsDir, scriptName + '.m');
    scriptSourceCache[scriptName] = fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '(not found)';
  }
  return scriptSourceCache[scriptName];
}

// ── Generate prompt files ─────────────────────────────────────────────────────

const SYSTEM_PREAMBLE = `You are naming obfuscated Wombat script member variables for a 1998 Ultima Online shard.
Q-codes (Q4P5, Q4NO, etc.) are OSI-internal identifiers. Replace them with concise snake_case names.

RULES:
- ALL names must be snake_case (never camelCase)
- Members are instance variables — use noun or noun_phrase format describing WHAT the variable holds
- Be concise — prefer "target" over "target_object" when context is unambiguous
- Don't repeat the script name unless necessary for clarity
- Only suggest names for Q-codes in the OUTPUT — do not include already-resolved names

OUTPUT: a single JSON object mapping export keys to snake_case names. Example:
{
  "alchemy.Q5K3": "reagent_list",
  "alchemy.Q5JY": "keg_obj"
}

Keys:
  "script.Q"  → script-level member variable

ENGINE API (built-in functions, for context):
${engineApi}

`;

for (let bi = 0; bi < batches.length; bi++) {
  const batch = batches[bi];
  const batchNum = String(bi + 1).padStart(3, '0');

  let body = '';

  for (const scriptName of batch) {
    const scriptMembers = byScript[scriptName];

    body += `\n=== SCRIPT: ${scriptName}.m ===\n`;
    body += '\nQ-CODED MEMBERS TO NAME:\n';
    for (const m of scriptMembers) {
      body += `  ${scriptName}.${m.name}  [member, type: ${m.type || 'unknown'}]\n`;
    }

    body += `\n--- FULL SOURCE: ${scriptName}.m ---\n`;
    body += getScriptSource(scriptName);
    body += '\n';
  }

  const prompt = SYSTEM_PREAMBLE + body;
  const outFile = path.join(outDir, `batch-${batchNum}.txt`);
  fs.writeFileSync(outFile, prompt);
}

console.log(`Wrote ${batches.length} prompt files to ${outDir}`);
console.log(`Batch manifest saved to ${batchesOut}`);
console.log(`\nNext: spawn naming agents reading each prompt file`);
console.log(`Results format: { "script.Q": "name", ... }`);
console.log(`Save combined results as renames-${roundLabel}-raw.json`);
