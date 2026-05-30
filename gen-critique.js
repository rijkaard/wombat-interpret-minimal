#!/usr/bin/env node
'use strict';
// gen-critique.js
// Prepares agent critique contexts for a set of proposed renames.
// Groups by defining script, builds one context per script (or small batch),
// then spawns agents to critique and write step-N.critique/<script>.critique files.
//
// Usage:
//   node gen-critique.js renames-N-raw.json [--round N] [--batch-size K]
//   [--scripts-dir ./scripts] [--symbols ./symbols.json]
//   [--out-dir ./step-N.critique]
//
// Each .critique file is JSON:
// {
//   "script": "...",
//   "renames": {
//     "key": { "proposed": "...", "verdict": "accept|suggest",
//              "suggestion": "...", "reason": "..." }
//   },
//   "commentary": "..."
// }

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const proposalsFile = argv.find(a => !a.startsWith('--'));
const round        = getArg('--round', '3');
const batchSize    = parseInt(getArg('--batch-size', '4'), 10);
const scriptsDir   = getArg('--scripts-dir', './scripts');
const symbolsFile  = getArg('--symbols', './symbols.json');
const outDir       = getArg('--out-dir', `./step-${round}.critique`);
const builtinsFile = getArg('--builtins', '../ouo/wombat_builtins.inc');

if (!proposalsFile || !fs.existsSync(proposalsFile)) {
  console.error('Usage: gen-critique.js renames-N-raw.json [options]');
  process.exit(1);
}

fs.mkdirSync(outDir, { recursive: true });

const proposals = JSON.parse(fs.readFileSync(proposalsFile, 'utf8'));
const { inherits: inheritMap } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));

// ── 1. Build compact engine API ───────────────────────────────────────────────
let engineApi = '(engine-api.txt not found — run with correct --builtins path)';
if (fs.existsSync(builtinsFile)) {
  const builtinsSrc = fs.readFileSync(builtinsFile, 'utf8');
  const typeChar = { v: 'void', i: 'int', s: 'str', o: 'obj', l: 'list', c: 'loc', q: 'ustr', u: 'any' };
  const lines = [];
  const seen = new Set();
  for (const m of builtinsSrc.matchAll(/\{\.name\s*=\s*"(\w+)".*?\.typeSig\s*=\s*"([^"]+)"/g)) {
    const name = m[1], sig = m[2];
    if (name.startsWith('TK_') || name.startsWith('opr') || seen.has(name)) continue;
    seen.add(name);
    const [ret, ...params] = sig.replace('|', '').split('');
    const pStr = params.map(c => typeChar[c] || c).join(', ');
    const rStr = typeChar[ret] || ret;
    lines.push(rStr === 'void' ? `${name}(${pStr})` : `${rStr} ${name}(${pStr})`);
  }
  engineApi = lines.join('\n');
} else if (fs.existsSync('./engine-api.txt')) {
  engineApi = fs.readFileSync('./engine-api.txt', 'utf8');
}

// ── 2. Group proposals by defining script ─────────────────────────────────────
const byScript = {}; // defScript -> { qualified: {key->proposed}, scoped: {key->proposed} }
for (const [key, proposed] of Object.entries(proposals)) {
  const colonIdx = key.indexOf(':');
  const dotIdx   = key.indexOf('.');
  if (dotIdx < 0) continue; // bare key — skip (shouldn't appear in new proposals)
  const defScript = key.slice(0, dotIdx);
  if (!byScript[defScript]) byScript[defScript] = { qualified: {}, scoped: {} };
  if (colonIdx > 0) byScript[defScript].scoped[key] = proposed;
  else              byScript[defScript].qualified[key] = proposed;
}

const scriptNames = Object.keys(byScript).sort();
console.log(`Proposals for ${scriptNames.length} defining scripts, ${Object.keys(proposals).length} total entries`);

// ── 3. Load script source ─────────────────────────────────────────────────────
function loadScript(name) {
  const p = path.join(scriptsDir, name + '.m');
  return fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : `// ${name}.m not found`;
}

function ancestorChain(script) {
  const chain = [];
  let cur = inheritMap[script];
  while (cur) { chain.push(cur); cur = inheritMap[cur]; }
  return chain;
}

// ── 4. Build agent prompt for a set of scripts ────────────────────────────────
function buildPrompt(scripts) {
  const sections = [];
  for (const script of scripts) {
    const group = byScript[script];
    const qualifiedEntries = Object.entries(group.qualified);
    const scopedEntries    = Object.entries(group.scoped);

    const ancestors = ancestorChain(script);
    let ancestorSrcs = '';
    for (const anc of ancestors) {
      ancestorSrcs += `\n--- INHERITED: ${anc}.m ---\n${loadScript(anc)}\n`;
    }

    const renameList = [
      ...qualifiedEntries.map(([k, v]) => `  "${k}": "${v}"   // function or member`),
      ...scopedEntries.map(([k, v]) => {
        const dotIdx = k.indexOf('.');
        const colonIdx = k.indexOf(':');
        const fnQ = k.slice(dotIdx + 1, colonIdx);
        return `  "${k}": "${v}"   // local/param in ${fnQ}`;
      }),
    ].join('\n');

    sections.push(`
=== SCRIPT: ${script}.m ===
Inherits: ${ancestors.length > 0 ? ancestors.join(' → ') : '(none)'}

PROPOSED RENAMES:
{
${renameList}
}

--- SOURCE: ${script}.m ---
${loadScript(script)}
${ancestorSrcs}`);
  }

  return `You are critiquing proposed Wombat script rename changes for a 1998 UO server.
The Q-codes (Q4SW, Q5NC, etc.) are OSI-internal identifiers being replaced with readable snake_case names.
Convention: all names must be snake_case.

Your job: review each proposed rename. For each entry either ACCEPT it or SUGGEST a better name.
Only suggest when the proposed name is wrong, misleading, too verbose, or inconsistent.

OUTPUT: one JSON object per script, written to stdout as a JSON array. Format:
[
  {
    "script": "scriptname",
    "commentary": "one sentence overall note, or empty string if no issues",
    "renames": {
      "key": { "verdict": "accept" }
      // OR:
      "key": { "verdict": "suggest", "suggestion": "better_name", "reason": "brief reason" }
    }
  }
]

Rules:
- verdict is ALWAYS either "accept" or "suggest" — never omit an entry
- suggestion must be snake_case, concise, accurate to what the code does
- reason must be one sentence max
- Do not suggest names that clash with existing renamed symbols or engine functions
- Locals/params: prefer short names scoped to the function's purpose (e.g. "i", "count", "result" are fine if unambiguous in context)
- Functions: prefer verb_noun format where the verb describes the action

ENGINE API (built-in functions available to all scripts):
${engineApi}

${sections.join('\n\n')}

Respond ONLY with the JSON array.`;
}

// ── 5. Build and save batches ─────────────────────────────────────────────────
const batches = [];
for (let i = 0; i < scriptNames.length; i += batchSize) {
  const batchScripts = scriptNames.slice(i, i + batchSize);
  batches.push({ scripts: batchScripts, prompt: buildPrompt(batchScripts) });
}

const batchesFile = path.join(outDir, 'batches.json');
fs.writeFileSync(batchesFile, JSON.stringify(batches.map(b => ({ scripts: b.scripts })), null, 2));

console.log(`\nBuilt ${batches.length} batches (batch-size=${batchSize})`);
console.log(`Batch list saved to ${batchesFile}`);
console.log('\nPrompt lengths:');
batches.forEach((b, i) => console.log(`  Batch ${i+1} [${b.scripts.join(', ')}]: ${b.prompt.length} chars`));

// Save individual prompts
const promptsDir = path.join(outDir, 'prompts');
fs.mkdirSync(promptsDir, { recursive: true });
batches.forEach((b, i) => {
  const fname = path.join(promptsDir, `batch-${String(i+1).padStart(3,'0')}.txt`);
  fs.writeFileSync(fname, b.prompt);
});
console.log(`\nPrompts saved to ${promptsDir}/`);
console.log('\nNext: spawn agents with each prompt, write outputs to:');
console.log(`  ${outDir}/<script>.critique`);
console.log('Then run: node compile-critique.js ' + proposalsFile + ' --critique-dir ' + outDir);
