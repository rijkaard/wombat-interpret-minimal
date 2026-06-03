#!/usr/bin/env node
'use strict';
// gen-naming-locals.js — generates naming prompt files for Q-coded local variables and params.
// One prompt per function/trigger that contains Q-coded locals or params.
// Usage: node gen-naming-locals.js [--scripts-dir ./scripts] [--out-dir ./step-10.naming/prompts]
//                                   [--builtins ../ouo/wombat_builtins.inc] [--round 10]

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const scriptsDir   = getArg('--scripts-dir', path.join(__dirname, '../scripts.interpreted'));
const outDir       = getArg('--out-dir', path.join(__dirname, '../step-10.naming/prompts'));
const builtinsFile = getArg('--builtins', path.join(__dirname, '../../ouo/wombat_builtins.inc'));
const symbolsFile  = getArg('--symbols', path.join(__dirname, '../symbols.json'));
const renamesFile  = getArg('--renames', path.join(__dirname, '../renames/renames.json'));
const roundLabel   = getArg('--round', '10');
const manifestOut  = getArg('--manifest', `/tmp/round${roundLabel}_locals_manifest.json`);

fs.mkdirSync(outDir, { recursive: true });

// ── Load data ─────────────────────────────────────────────────────────────────

const { symbols } = JSON.parse(fs.readFileSync(symbolsFile, 'utf8'));
const renames = fs.existsSync(renamesFile)
  ? JSON.parse(fs.readFileSync(renamesFile, 'utf8')) : {};

// Functions that have Q-coded locals or params (not already renamed)
const workFns = Object.values(symbols).filter(s =>
  s.kind !== 'member' && (
    (s.q_locals  && s.q_locals.some(q  => !renames[`${s.script}.${q}`])) ||
    (s.q_params && s.q_params.some(q => !renames[`${s.script}.${q}`]))
  )
);
console.log(`Functions needing local/param naming: ${workFns.length}`);

// ── Build engine API string ───────────────────────────────────────────────────

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

// ── Script source cache + inheritance ────────────────────────────────────────

const scriptSourceCache = {};
function getScriptSource(scriptName) {
  if (scriptSourceCache[scriptName] === undefined) {
    const p = path.join(scriptsDir, scriptName + '.m');
    scriptSourceCache[scriptName] = fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : null;
  }
  return scriptSourceCache[scriptName];
}

const inheritsCache = {};
function getParent(scriptName) {
  if (inheritsCache[scriptName] === undefined) {
    const src = getScriptSource(scriptName);
    if (!src) { inheritsCache[scriptName] = null; return null; }
    const m = /^inherits\s+(\S+)\s*;/m.exec(src);
    inheritsCache[scriptName] = m ? m[1] : null;
  }
  return inheritsCache[scriptName];
}

function getInheritanceChain(scriptName, maxDepth = 3) {
  const chain = [];
  let cur = getParent(scriptName);
  while (cur && chain.length < maxDepth) {
    chain.push(cur);
    cur = getParent(cur);
  }
  return chain;
}

// ── Extract function source from current (post-rename) script file ────────────

function extractFunctionSource(scriptSrc, sym) {
  const lines = scriptSrc.split('\n');
  let headerRE;

  if (sym.kind === 'trigger') {
    const name = escapeRE(sym.name);
    const filter = sym.filter ? escapeRE(sym.filter) : null;
    headerRE = filter
      ? new RegExp(`^\\s*trigger\\s+${name}\\s*\\(${filter}\\)`)
      : new RegExp(`^\\s*trigger\\s+${name}\\s*(\\{|$)`);
  } else {
    // function — match by name; handles "function int name(" and "function name("
    const name = escapeRE(sym.name);
    headerRE = new RegExp(`\\bfunction\\b[^{;]*\\b${name}\\s*\\(`);
  }

  let startIdx = -1;
  for (let i = 0; i < lines.length; i++) {
    if (headerRE.test(lines[i])) { startIdx = i; break; }
  }
  if (startIdx < 0) return null;

  let i = startIdx, depth = 0;
  const bodyLines = [];
  while (i < lines.length) {
    const l = lines[i];
    bodyLines.push(l);
    depth += (l.match(/\{/g) || []).length - (l.match(/\}/g) || []).length;
    i++;
    if (bodyLines.length > 1 && depth === 0) break;
    if (bodyLines.length > 500) break;
  }
  return bodyLines.join('\n');
}

function escapeRE(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ── Extract type information for Q-codes from function source ─────────────────

function extractQTypes(funcSource, qCodes) {
  const types = {};
  const qSet = new Set(qCodes);
  const re = /\b(int|obj|str|list|loc|any|ustr)\s+(Q[0-9A-Z]{3})\b/g;
  let m;
  while ((m = re.exec(funcSource)) !== null) {
    if (qSet.has(m[2])) types[m[2]] = m[1];
  }
  return types;
}

// ── System preamble ───────────────────────────────────────────────────────────

const SYSTEM_PREAMBLE = `You are naming obfuscated Wombat script local variables and parameters for a 1998 Ultima Online shard.
Q-codes (Q4P5, Q4NO, etc.) are OSI-internal identifiers. Replace them with concise snake_case names.

RULES:
- ALL names must be snake_case (never camelCase)
- Locals and params are scoped to the function — name what the variable HOLDS or REPRESENTS in this context
- Loop counters: prefer i, j, count, idx over verbose names when context is clear
- Prefer short names: "target" not "target_object", "dmg" not "damage_amount" if obvious
- Params: name what the caller passes in
- Don't repeat the function name unless necessary for clarity
- Only output Q-codes listed in the task — do not rename already-resolved names

OUTPUT: a single JSON object mapping export keys to snake_case names. Example:
{
  "add_door_to_key.attach_lockable_to_key.Q4MZ": "lockable",
  "add_door_to_key.attach_lockable_to_key.Q5Z5": "key_list",
  "add_door_to_key.attach_lockable_to_key.Q51N": "key_type"
}

Keys:
  "script.function_name.Q"   → function local or param
  "script.@trigger_name.Q"   → trigger local or param (@ prefix for triggers)

ENGINE API (built-in functions, for context):
${engineApi}

`;

// ── Generate prompt files ─────────────────────────────────────────────────────

const manifest = [];

for (let bi = 0; bi < workFns.length; bi++) {
  const sym = workFns[bi];
  const batchNum = String(bi + 1).padStart(4, '0');

  const scriptSrc = getScriptSource(sym.script);
  if (!scriptSrc) {
    console.warn(`  SKIP ${sym.qualified}: script not found`);
    continue;
  }

  const funcSrc = extractFunctionSource(scriptSrc, sym);
  if (!funcSrc) {
    console.warn(`  SKIP ${sym.qualified}: function body not found in script`);
    continue;
  }

  // Collect all Q-codes needing names (locals + params, excluding already renamed)
  const allQ = [
    ...(sym.q_params || []),
    ...(sym.q_locals  || []),
  ].filter((q, idx, arr) => arr.indexOf(q) === idx && !renames[`${sym.script}.${q}`]);

  if (allQ.length === 0) continue;

  const qTypes = extractQTypes(funcSrc, allQ);

  // Build export keys for this function's Q-codes
  // qualified format: "script.@trigger" or "script.function_name"
  const exportKeys = allQ.map(q => `${sym.qualified}.${q}`);

  // Inheritance chain for context
  const chain = getInheritanceChain(sym.script);

  // Build prompt body
  let body = `=== FUNCTION: ${sym.script}.m / ${sym.kind} ${sym.name}${sym.filter ? `(${sym.filter})` : ''} ===\n\n`;

  body += 'Q-CODED LOCALS/PARAMS TO NAME:\n';
  for (const q of allQ) {
    const isParam = (sym.q_params || []).includes(q);
    const type = qTypes[q] || 'unknown';
    body += `  ${sym.qualified}.${q}  [${type} ${isParam ? 'param' : 'local'}]\n`;
  }

  body += `\n--- FUNCTION SOURCE: ${sym.script}.m ---\n`;
  body += funcSrc;
  body += '\n';

  if (chain.length === 0 || funcSrc.length > 800) {
    // Skip full script if function is large; agent already has enough context
    if (chain.length > 0 || scriptSrc.length < 4000) {
      body += `\n--- FULL SCRIPT: ${sym.script}.m ---\n`;
      body += scriptSrc;
      body += '\n';
    }
  } else {
    body += `\n--- FULL SCRIPT: ${sym.script}.m ---\n`;
    body += scriptSrc;
    body += '\n';
  }

  for (const parent of chain) {
    const parentSrc = getScriptSource(parent);
    if (parentSrc) {
      body += `\n--- INHERITED: ${parent}.m ---\n`;
      body += parentSrc;
      body += '\n';
    }
  }

  const prompt = SYSTEM_PREAMBLE + body;
  const outFile = path.join(outDir, `batch-${batchNum}.txt`);
  fs.writeFileSync(outFile, prompt);

  manifest.push({ batchNum, qualified: sym.qualified, script: sym.script, keys: exportKeys });
}

fs.writeFileSync(manifestOut, JSON.stringify(manifest, null, 2));
console.log(`Wrote ${manifest.length} prompt files to ${outDir}`);
console.log(`Manifest saved to ${manifestOut}`);
console.log(`\nNext: spawn naming agents reading each prompt file`);
console.log(`Results format: { "script.function.Q": "name", ... }`);
console.log(`Save combined results as renames-${roundLabel}-raw.json`);
