#!/usr/bin/env node
'use strict';
// trim-prompts.js — rewrite step-10 prompts so ENGINE API only includes
// functions actually called in the included code section.
// Creates step-10b/prompts/ with trimmed prompts and copies existing results.
//
// Usage: node trim-prompts.js [--in-dir ./step-10.naming] [--out-dir ./step-10b]
//         [--batch NNNN]   (test single batch)

const fs   = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
function getArg(f, d) { const i = argv.indexOf(f); return i >= 0 ? argv[i+1] : d; }
const inDir   = getArg('--in-dir',  './step-10.naming');
const outDir  = getArg('--out-dir', './step-10b');
const singleBatch = getArg('--batch', null);

const inPrompts  = path.join(inDir,  'prompts');
const outPrompts = path.join(outDir, 'prompts');
const inResults  = path.join(inDir,  'results');
const outResults = path.join(outDir, 'results');

fs.mkdirSync(outPrompts, { recursive: true });
fs.mkdirSync(outResults, { recursive: true });

const API_HEADER = 'ENGINE API (built-in functions, for context):';
const FUNC_START = /^=== FUNCTION:/m;

function trimPrompt(src) {
  // Split at the ENGINE API header line
  const apiHeaderIdx = src.indexOf(API_HEADER);
  if (apiHeaderIdx < 0) return src; // no API section, pass through unchanged

  const beforeApi = src.slice(0, apiHeaderIdx + API_HEADER.length + 1); // includes trailing \n
  const afterHeader = src.slice(apiHeaderIdx + API_HEADER.length + 1);

  // Find where the code section begins (=== FUNCTION: ...)
  const codeMatch = FUNC_START.exec(afterHeader);
  if (!codeMatch) return src; // no code section found, pass through

  const apiBlock = afterHeader.slice(0, codeMatch.index);
  const codeSection = afterHeader.slice(codeMatch.index);

  // Parse API entries: one per line, extract function name (word before '(')
  // Lines look like: "int functionName(arg, arg)" or "functionName(arg)"
  const apiLines = apiBlock.split('\n');
  const apiEntries = []; // { line, name }
  for (const line of apiLines) {
    const m = /\b([a-zA-Z_]\w*)\s*\(/.exec(line);
    if (m) {
      apiEntries.push({ line, name: m[1] });
    } else {
      // blank line or non-function line — keep as separator placeholder
      apiEntries.push({ line, name: null });
    }
  }

  // Find which function names actually appear in the code section
  const usedNames = new Set();
  for (const { name } of apiEntries) {
    if (!name) continue;
    // Match as a whole word followed by '(' — actual call syntax
    const re = new RegExp(`\\b${name}\\s*\\(`, 'g');
    if (re.test(codeSection)) usedNames.add(name);
  }

  // Filter API lines: keep a line if its function is used, or if it's blank
  // (preserve blank separator lines that follow a used entry)
  const filteredLines = [];
  for (const { line, name } of apiEntries) {
    if (name === null) {
      // blank/non-function line: include only if we included something before it
      if (filteredLines.length > 0) filteredLines.push(line);
    } else if (usedNames.has(name)) {
      filteredLines.push(line);
    }
  }

  // Remove trailing blank lines from the filtered API block
  while (filteredLines.length && filteredLines[filteredLines.length - 1].trim() === '') {
    filteredLines.pop();
  }

  const newApiBlock = filteredLines.length > 0
    ? filteredLines.join('\n') + '\n\n'
    : '\n';

  return beforeApi + newApiBlock + codeSection;
}

function processFile(filename) {
  const inPath  = path.join(inPrompts,  filename);
  const outPath = path.join(outPrompts, filename);
  const src = fs.readFileSync(inPath, 'utf8');
  const trimmed = trimPrompt(src);
  fs.writeFileSync(outPath, trimmed);

  const origLines = src.split('\n').length;
  const newLines  = trimmed.split('\n').length;
  return { origLines, newLines, saved: origLines - newLines };
}

// ── Main ──────────────────────────────────────────────────────────────────────

if (singleBatch) {
  // Test mode: process one file and report
  const filename = `batch-${singleBatch}.txt`;
  const { origLines, newLines, saved } = processFile(filename);
  console.log(`batch-${singleBatch}: ${origLines} → ${newLines} lines (saved ${saved})`);

  // Show what API functions were kept
  const trimmed = fs.readFileSync(path.join(outPrompts, filename), 'utf8');
  const apiHeaderIdx = trimmed.indexOf(API_HEADER);
  const afterHeader  = trimmed.slice(apiHeaderIdx + API_HEADER.length + 1);
  const codeMatch    = FUNC_START.exec(afterHeader);
  const apiBlock     = codeMatch ? afterHeader.slice(0, codeMatch.index) : afterHeader;
  const keptFns = apiBlock.split('\n')
    .map(l => { const m = /\b([a-zA-Z_]\w*)\s*\(/.exec(l); return m ? m[1] : null; })
    .filter(Boolean);
  console.log(`\nKept ${keptFns.length} engine functions: ${keptFns.join(', ')}`);
  process.exit(0);
}

// Full run: process all prompt files
const files = fs.readdirSync(inPrompts).filter(f => f.endsWith('.txt')).sort();
let totalSaved = 0;
let count = 0;
for (const f of files) {
  const { origLines, newLines, saved } = processFile(f);
  totalSaved += saved;
  count++;
}
console.log(`Processed ${count} prompts. Total lines saved: ${totalSaved} (~${Math.round(totalSaved/count)} per prompt avg).`);

// Copy existing results
const resultFiles = fs.existsSync(inResults)
  ? fs.readdirSync(inResults).filter(f => f.endsWith('.json'))
  : [];
for (const f of resultFiles) {
  fs.copyFileSync(path.join(inResults, f), path.join(outResults, f));
}
console.log(`Copied ${resultFiles.length} result files to ${outResults}`);
