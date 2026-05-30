#!/usr/bin/env node
'use strict';
// extract-symbols.js
// Reads all plain-text Wombat .m files from ./scripts/, parses symbols,
// builds the dependency graph, and writes symbols.json.
//
// Symbol kinds: 'function' | 'member' | 'param' | 'local'
// Q-name pattern: Q followed by exactly 3 uppercase alphanumeric chars
//
// Usage: node extract-symbols.js [--scripts-dir ./scripts]

const fs = require('fs');
const path = require('path');

const Q_RE = /\bQ[0-9A-Z]{3}\b/g;
const Q_TEST = /^Q[0-9A-Z]{3}$/;

function isQ(name) { return Q_TEST.test(name); }

// ── Tokenizer ────────────────────────────────────────────────────────────────

function tokenize(src) {
  const tokens = [];
  let i = 0;
  while (i < src.length) {
    // Line comment
    if (src[i] === '/' && src[i+1] === '/') {
      let j = i + 2;
      while (j < src.length && src[j] !== '\n') j++;
      i = j; continue;
    }
    // Block comment
    if (src[i] === '/' && src[i+1] === '*') {
      let j = i + 2;
      while (j < src.length - 1 && !(src[j] === '*' && src[j+1] === '/')) j++;
      i = j + 2; continue;
    }
    // String literal
    if (src[i] === '"') {
      let j = i + 1;
      while (j < src.length && src[j] !== '"') {
        if (src[j] === '\\') j++;
        j++;
      }
      tokens.push({ type: 'STRING', val: src.slice(i, j+1) });
      i = j + 1; continue;
    }
    // Whitespace
    if (/\s/.test(src[i])) {
      i++; continue;
    }
    // Identifier / keyword
    if (/[A-Za-z_]/.test(src[i])) {
      let j = i + 1;
      while (j < src.length && /[A-Za-z0-9_]/.test(src[j])) j++;
      tokens.push({ type: 'IDENT', val: src.slice(i, j) });
      i = j; continue;
    }
    // Hex number
    if (src[i] === '0' && src[i+1] === 'x') {
      let j = i + 2;
      while (j < src.length && /[0-9A-Fa-f]/.test(src[j])) j++;
      tokens.push({ type: 'NUMBER', val: src.slice(i, j) });
      i = j; continue;
    }
    // Decimal number
    if (/[0-9]/.test(src[i]) || (src[i] === '-' && /[0-9]/.test(src[i+1]))) {
      let j = i + 1;
      while (j < src.length && /[0-9]/.test(src[j])) j++;
      tokens.push({ type: 'NUMBER', val: src.slice(i, j) });
      i = j; continue;
    }
    // Two-char operators
    const two = src.slice(i, i+2);
    if (['++', '--', '==', '!=', '<=', '>=', '&&', '||'].includes(two)) {
      tokens.push({ type: 'PUNCT', val: two });
      i += 2; continue;
    }
    // Single-char punctuation
    tokens.push({ type: 'PUNCT', val: src[i] });
    i++;
  }
  return tokens;
}

// ── Parser ───────────────────────────────────────────────────────────────────

const TYPES = new Set(['int','string','ustring','loc','obj','list','void','unknown']);

function parseFile(src, scriptName) {
  const tokens = tokenize(src);
  let pos = 0;

  function peek(offset=0) { return tokens[pos + offset]; }
  function consume() { return tokens[pos++]; }
  function expect(type, val) {
    const t = consume();
    if (val !== undefined && t?.val !== val) throw new Error(`Expected ${val} got ${t?.val} in ${scriptName}`);
    return t;
  }
  function at(val) { return peek()?.val === val; }
  function tryConsume(val) { if (at(val)) { consume(); return true; } return false; }

  // Skip to matching closing brace, return source slice
  function bodyBetweenBraces() {
    // We're positioned after the opening '{'
    let depth = 1;
    const start = pos;
    while (pos < tokens.length && depth > 0) {
      const t = tokens[pos++];
      if (t.val === '{') depth++;
      else if (t.val === '}') depth--;
    }
    return tokens.slice(start, pos - 1); // tokens inside braces
  }

  // Skip to next ';' at depth 0
  function skipToSemi() {
    let depth = 0;
    while (pos < tokens.length) {
      const t = consume();
      if (t.val === '(') depth++;
      else if (t.val === ')') depth--;
      else if (t.val === ';' && depth === 0) break;
    }
  }

  // Parse parameter list: (type name, type name, ...)
  function parseParams() {
    const params = [];
    expect('PUNCT', '(');
    while (!at(')') && pos < tokens.length) {
      if (at(',')) { consume(); continue; }
      const typeTok = peek();
      if (!TYPES.has(typeTok?.val)) break;
      consume(); // type
      const nameTok = consume(); // name
      params.push({ type: typeTok.val, name: nameTok?.val });
    }
    expect('PUNCT', ')');
    return params;
  }

  // Extract Q-function calls and Q-local-var declarations from body tokens
  function analyseBody(bodyTokens) {
    const q_calls = new Set();
    const q_locals = new Set();
    let i = 0;
    while (i < bodyTokens.length) {
      const t = bodyTokens[i];
      // Local variable declaration: TYPE Q_NAME ...;
      if (t.type === 'IDENT' && TYPES.has(t.val) && bodyTokens[i+1]?.type === 'IDENT') {
        const nameT = bodyTokens[i+1];
        if (isQ(nameT.val)) q_locals.add(nameT.val);
        i += 2; continue;
      }
      // Member declaration inside trigger/function with explicit 'member' keyword shouldn't appear, but guard:
      if (t.val === 'member' && bodyTokens[i+1]?.type === 'IDENT' && bodyTokens[i+2]?.type === 'IDENT') {
        if (isQ(bodyTokens[i+2].val)) q_locals.add(bodyTokens[i+2].val);
        i += 3; continue;
      }
      // Q-name followed by '(' = function call
      if (t.type === 'IDENT' && isQ(t.val) && bodyTokens[i+1]?.val === '(') {
        q_calls.add(t.val);
        i++; continue;
      }
      i++;
    }
    return { q_calls: [...q_calls], q_locals: [...q_locals] };
  }

  // Reconstruct source from tokens
  function tokensToSource(toks) {
    let out = '';
    for (let i = 0; i < toks.length; i++) {
      const t = toks[i];
      const prev = toks[i-1];
      // Add space between adjacent identifiers/numbers
      if (prev && (prev.type === 'IDENT' || prev.type === 'NUMBER') &&
          (t.type === 'IDENT' || t.type === 'NUMBER')) out += ' ';
      else if (prev && prev.type === 'IDENT' && t.val === '(') { /* no space */ }
      else if (prev && (prev.val === ',' || prev.val === ';' || prev.val === '{' ||
               prev.val === '}' || prev.val === '(' )) out += ' ';
      else if (t.val === ')' || t.val === ';' || t.val === ',' || t.val === ')') { /* no space */ }
      else if (prev) out += ' ';
      out += t.val;
    }
    return out.trim();
  }

  const result = {
    script: scriptName,
    inherits: null,
    members: [],
    functions: [],
    triggers: [],
  };

  while (pos < tokens.length) {
    const t = peek();
    if (!t) break;

    // inherits NAME;
    if (t.val === 'inherits') {
      consume();
      const name = consume();
      result.inherits = name?.val;
      tryConsume(';');
      continue;
    }

    // member TYPE NAME [= expr];
    if (t.val === 'member') {
      consume();
      const typeTok = consume();
      const nameTok = consume();
      let initSrc = null;
      if (at('=')) {
        consume();
        const initStart = pos;
        skipToSemi();
        initSrc = tokens.slice(initStart, pos - 1).map(t=>t.val).join(' ');
      } else {
        tryConsume(';');
      }
      result.members.push({
        name: nameTok?.val,
        type: typeTok?.val,
        init: initSrc,
      });
      continue;
    }

    // function RETTYPE NAME(PARAMS) { BODY }
    if (t.val === 'function') {
      consume();
      const retTypeTok = consume();
      const nameTok = consume();
      let params = [];
      try { params = parseParams(); } catch(e) { /* skip malformed */ }
      if (!at('{')) { skipToSemi(); continue; }
      consume(); // {
      const bodyToks = bodyBetweenBraces();
      const { q_calls, q_locals } = analyseBody(bodyToks);
      result.functions.push({
        name: nameTok?.val,
        returnType: retTypeTok?.val,
        params,
        q_calls,
        q_locals,
        source: `function ${retTypeTok?.val} ${nameTok?.val}(${params.map(p=>`${p.type} ${p.name}`).join(', ')}) {\n  ${tokensToSource(bodyToks)}\n}`,
      });
      continue;
    }

    // trigger NAME[(filter)] { BODY }
    if (t.val === 'trigger') {
      consume();
      const nameTok = consume();
      let filter = null;
      if (at('(')) {
        consume();
        if (peek()?.type === 'STRING' || peek()?.type === 'NUMBER') filter = consume()?.val;
        tryConsume(')');
      }
      if (!at('{')) { skipToSemi(); continue; }
      consume(); // {
      const bodyToks = bodyBetweenBraces();
      const { q_calls, q_locals } = analyseBody(bodyToks);
      result.triggers.push({
        name: nameTok?.val,
        filter,
        q_calls,
        q_locals,
        source: `trigger ${nameTok?.val}${filter ? `(${filter})` : ''} {\n  ${tokensToSource(bodyToks)}\n}`,
      });
      continue;
    }

    // Skip anything else
    consume();
  }

  return result;
}

// ── Main ─────────────────────────────────────────────────────────────────────

const argv = process.argv.slice(2);
function getArg(flag, def) { const i = argv.indexOf(flag); return i >= 0 ? argv[i+1] : def; }
const scriptsDir = getArg('--scripts-dir', './scripts');
const outFile = getArg('--out', './symbols.json');

// Load all script files
const files = fs.readdirSync(scriptsDir).filter(f => f.endsWith('.m'));
const parsed = {};

for (const file of files) {
  const scriptName = path.basename(file, '.m');
  const src = fs.readFileSync(path.join(scriptsDir, file), 'utf8');
  try {
    parsed[scriptName] = parseFile(src, scriptName);
  } catch(e) {
    console.error(`Error parsing ${file}:`, e.message);
  }
}

// Build inheritance graph
const inheritsMap = {}; // child -> parent
for (const [name, data] of Object.entries(parsed)) {
  if (data.inherits) inheritsMap[name] = data.inherits;
}

// Collect all defined Q-symbols with their definitions
// sym_table: qualifiedName -> descriptor
const sym_table = {};

for (const [scriptName, data] of Object.entries(parsed)) {
  // Members
  for (const m of data.members) {
    if (!m.name) continue;
    const qualified = `${scriptName}.${m.name}`;
    sym_table[qualified] = {
      qualified,
      name: m.name,
      script: scriptName,
      kind: 'member',
      type: m.type,
      is_q: isQ(m.name),
      resolved_name: null, // filled in after renames
    };
  }

  // Functions
  for (const f of data.functions) {
    if (!f.name) continue;
    const qualified = `${scriptName}.${f.name}`;
    // Q-params
    const q_params = f.params.filter(p => isQ(p.name)).map(p => p.name);
    sym_table[qualified] = {
      qualified,
      name: f.name,
      script: scriptName,
      kind: 'function',
      returnType: f.returnType,
      params: f.params,
      q_calls: f.q_calls,    // Q-names called (function calls)
      q_locals: f.q_locals,  // Q-names declared as local vars
      q_params,
      source: f.source,
      is_q: isQ(f.name),
      resolved_name: null,
    };
  }

  // Triggers (not Q-named themselves, but may call Q-functions)
  for (const tr of data.triggers) {
    const qualified = `${scriptName}.@${tr.name}${tr.filter ? `(${tr.filter})` : ''}`;
    sym_table[qualified] = {
      qualified,
      name: tr.name,
      script: scriptName,
      kind: 'trigger',
      filter: tr.filter,
      q_calls: tr.q_calls,
      q_locals: tr.q_locals,
      source: tr.source,
      is_q: false, // triggers are never Q-named
    };
  }
}

// Load existing renames if present
let renames = {};
if (fs.existsSync('./renames.json')) {
  renames = JSON.parse(fs.readFileSync('./renames.json', 'utf8'));
}

// Mark resolved names
for (const sym of Object.values(sym_table)) {
  const renamed = renames[sym.qualified] || renames[sym.name];
  if (renamed) sym.resolved_name = renamed;
  else if (!sym.is_q) sym.resolved_name = sym.name;
}

// Determine leaf status for each function/trigger
// A function is a leaf if all its Q-call dependencies are resolved (non-Q or renamed)
function isResolved(qName, scriptName) {
  // Check if qName has a resolved entry in this script or any ancestor
  let cur = scriptName;
  while (cur) {
    const qual = `${cur}.${qName}`;
    if (sym_table[qual]) {
      return sym_table[qual].resolved_name !== null;
    }
    cur = inheritsMap[cur] || null;
  }
  // If not found in any ancestor, check if it's a Script_* or known named function
  return !isQ(qName);
}

for (const sym of Object.values(sym_table)) {
  if (sym.kind !== 'function' && sym.kind !== 'trigger') continue;
  const unresolved_q_calls = (sym.q_calls || []).filter(q => !isResolved(q, sym.script));
  sym.unresolved_q_calls = unresolved_q_calls;
  sym.is_leaf = sym.is_q && unresolved_q_calls.length === 0;
}

// Summary stats
const all_q = Object.values(sym_table).filter(s => s.is_q);
const leaves = Object.values(sym_table).filter(s => s.is_leaf);
const resolved = all_q.filter(s => s.resolved_name !== null);

console.log(`Scripts: ${files.length}`);
console.log(`Q-symbols: ${all_q.length} total, ${resolved.length} resolved, ${leaves.length} leaves`);

fs.writeFileSync(outFile, JSON.stringify({ meta: { scripts: files.length, q_total: all_q.length, q_resolved: resolved.length, leaves: leaves.length }, inherits: inheritsMap, symbols: sym_table }, null, 2));
console.log(`Wrote ${outFile}`);
