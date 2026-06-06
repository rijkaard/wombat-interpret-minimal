#!/usr/bin/env node
/*
 * gen-scripts-enum.mjs
 *
 * Reads scripts/ and produces scripts-enum/ by substituting integer literals
 * at annotated function-argument positions with enum constant names.
 *
 * Usage:
 *   node gen-scripts-enum.mjs \
 *     --enums   ../ouo/enumerations.h \
 *     --annots  ../wombat-compiler/enum-annotations.txt \
 *     --in      ./scripts \
 *     --out     ./scripts-enum
 */

import fs   from 'fs';
import path from 'path';

/* ── CLI ──────────────────────────────────────────────────────────────────── */

const args       = process.argv.slice(2);
const get        = (flag) => { const i = args.indexOf(flag); return i >= 0 ? args[i+1] : null; };
const ENUMS_PATH = get('--enums')  ?? '../ouo/enumerations.h';
const ANNOTS     = get('--annots') ?? '../wombat-compiler/enum-annotations.txt';
const IN_DIR     = get('--in')     ?? './scripts';
const OUT_DIR    = get('--out')    ?? './scripts-enum';

/* ── Parse enumerations.h ────────────────────────────────────────────────── */

function parseEnumH(src) {
    /* Returns: { 'SkillId': { 0:'SKILL_ALCHEMY', 25:'SKILL_MAGERY', ...}, ... } */
    const types = {};       /* type_name → { value_num → first_name } */
    const byName = {};      /* name → { value, type } */

    let inBlock = false;
    let curType = '';
    let lastVal = -1n;

    for (const rawLine of src.split('\n')) {
        /* strip comments */
        let line = rawLine;
        if (inBlock) {
            const end = line.indexOf('*/');
            if (end >= 0) { inBlock = false; line = line.slice(end + 2); }
            else continue;
        }
        const bc = line.indexOf('/*');
        if (bc >= 0) {
            const end = line.indexOf('*/', bc + 2);
            if (end >= 0) line = line.slice(0, bc) + line.slice(end + 2);
            else { inBlock = true; line = line.slice(0, bc); }
        }
        const lc = line.indexOf('//');
        if (lc >= 0) line = line.slice(0, lc);

        line = line.trim();
        if (!line) continue;

        if (!curType) {
            const m = line.match(/^enum\s+(\w+)\s*\{/);
            if (m) { curType = m[1]; lastVal = -1n; types[curType] = {}; }
        } else {
            if (line.startsWith('}')) { curType = ''; continue; }

            /* IDENTIFIER = VALUE, or IDENTIFIER, */
            const m = line.match(/^([A-Z_][A-Z0-9_]*)\s*(?:=\s*([^,]+?))?(?:\s*,|$)/);
            if (!m) continue;

            const name = m[1];
            let val;
            if (m[2] !== undefined) {
                const raw = m[2].trim();
                if (raw.startsWith("'") && raw.length >= 3) {
                    val = BigInt(raw.charCodeAt(1)); /* char literal */
                } else {
                    try { val = BigInt(raw); } catch { continue; }
                }
            } else {
                val = lastVal + 1n;
            }
            lastVal = val;

            if (!(val in types[curType])) types[curType][String(val)] = name;
            byName[name] = { value: val, type: curType };
        }
    }
    return { types, byName };
}

/* ── Parse annotations ───────────────────────────────────────────────────── */

function parseAnnotations(src) {
    /* Returns: { argMap: { 'getSkillLevel:1': 'SkillId', ... },
     *            returnsMap: { 'getDirectionInternal': 'Direction', ... } } */
    const argMap = {};
    const returnsMap = {};
    for (const rawLine of src.split('\n')) {
        const line = rawLine.replace(/#.*/, '').trim();
        const parts = line.split(/\s+/);
        if (parts.length === 3) {
            const [func, second, type] = parts;
            if (second === 'RETURNS') {
                returnsMap[func] = type;
            } else {
                const argIdx = parseInt(second, 10);
                if (!isNaN(argIdx)) argMap[`${func}:${argIdx}`] = type;
            }
        }
    }
    return { argMap, returnsMap };
}

/* ── Wombat tokenizer ────────────────────────────────────────────────────── */

const TK = {
    IDENT: 'IDENT', INT: 'INT', STR: 'STR', USTR: 'USTR',
    LPAREN: 'LPAREN', RPAREN: 'RPAREN', COMMA: 'COMMA',
    OTHER: 'OTHER', EOF: 'EOF',
};

function tokenize(src) {
    const tokens = [];
    let i = 0;

    while (i < src.length) {
        /* Block comment */
        if (src[i] === '/' && src[i+1] === '*') {
            const start = i;
            i += 2;
            while (i < src.length && !(src[i-1] === '*' && src[i] === '/')) i++;
            i++; /* consume final '/' */
            tokens.push({ kind: TK.OTHER, text: src.slice(start, i) });
            continue;
        }
        /* Line comment */
        if (src[i] === '/' && src[i+1] === '/') {
            const start = i;
            while (i < src.length && src[i] !== '\n') i++;
            tokens.push({ kind: TK.OTHER, text: src.slice(start, i) });
            continue;
        }
        /* Wide string */
        if (src[i] === 'L' && src[i+1] === '"') {
            const start = i; i += 2;
            while (i < src.length && src[i] !== '"') {
                if (src[i] === '\\') i++;
                i++;
            }
            i++; /* closing " */
            tokens.push({ kind: TK.USTR, text: src.slice(start, i) });
            continue;
        }
        /* Regular string */
        if (src[i] === '"') {
            const start = i; i++;
            while (i < src.length && src[i] !== '"') {
                if (src[i] === '\\') i++;
                i++;
            }
            i++;
            tokens.push({ kind: TK.STR, text: src.slice(start, i) });
            continue;
        }
        /* Hex integer */
        if (src[i] === '0' && (src[i+1] === 'x' || src[i+1] === 'X')) {
            const start = i; i += 2;
            while (i < src.length && /[0-9a-fA-F]/.test(src[i])) i++;
            tokens.push({ kind: TK.INT, text: src.slice(start, i), numDigits: i - start - 2 });
            continue;
        }
        /* Decimal integer */
        if (/[0-9]/.test(src[i])) {
            const start = i;
            while (i < src.length && /[0-9]/.test(src[i])) i++;
            /* not followed by letter (would be part of identifier-ish token) */
            tokens.push({ kind: TK.INT, text: src.slice(start, i), numDigits: 0 });
            continue;
        }
        /* Identifier */
        if (/[A-Za-z_]/.test(src[i])) {
            const start = i;
            while (i < src.length && /[A-Za-z0-9_]/.test(src[i])) i++;
            tokens.push({ kind: TK.IDENT, text: src.slice(start, i) });
            continue;
        }
        /* Single-char tokens */
        if (src[i] === '(') { tokens.push({ kind: TK.LPAREN, text: '(' }); i++; continue; }
        if (src[i] === ')') { tokens.push({ kind: TK.RPAREN, text: ')' }); i++; continue; }
        if (src[i] === ',') { tokens.push({ kind: TK.COMMA,  text: ',' }); i++; continue; }
        /* Everything else (operators, whitespace, etc.) */
        tokens.push({ kind: TK.OTHER, text: src[i] });
        i++;
    }
    tokens.push({ kind: TK.EOF, text: '' });
    return tokens;
}

/* ── Substitution pass ───────────────────────────────────────────────────── */

function substitute(src, enumTypes, argMap, returnsMap) {
    const tokens = tokenize(src);
    const out    = [];

    /*
     * Call-context stack: each entry is { func, argIdx, open?, isSwitch? }.
     * We push when entering a known function call; pop on matching ')'.
     * Non-call '(' pushes a sentinel { func: null } to track nesting.
     */
    const stack = [];

    /* ── Category 3: switch/case substitution state ───────────────────────
     *
     * varTypes: variable name → enum type, set when we see
     *   VAR = RETURNS_FUNC(...)  (intra-procedural assignment)
     * Cleared when braceDepth returns to 0 (end of top-level function).
     *
     * switchScopes: stack of { openDepth, enumType }.
     *   openDepth = braceDepth after the opening '{' of the switch body.
     *   Popped when that same '{' is closed.
     *
     * switchPending: set when we close switch(...); waiting for '{'.
     * switchVarCandidate: the identifier seen inside switch(...).
     * afterCase: true when 'case' was seen inside a typed switch body.
     *
     * recent: rolling buffer of last 8 non-whitespace tokens, used to
     *   detect the assignment pattern  VAR = FUNC(  .
     */
    const varTypes       = {};
    let   braceDepth     = 0;
    const switchScopes   = [];
    let   switchPending  = null;          /* { enumType } | null */
    let   switchVarCand  = null;          /* identifier inside switch(...) */
    let   afterCase      = false;

    const recent         = [];
    const RECENT_MAX     = 8;
    function pushRecent(tok) {
        /* Skip pure-whitespace OTHER tokens — they add noise to the pattern detector. */
        if (tok.kind === TK.OTHER && tok.text.trim() === '') return;
        recent.push({ kind: tok.kind, text: tok.text });
        if (recent.length > RECENT_MAX) recent.shift();
    }

    for (let i = 0; i < tokens.length; i++) {
        const tok = tokens[i];

        if (tok.kind === TK.IDENT) {
            const next = tokens[i + 1];

            if (next && next.kind === TK.LPAREN) {
                /* ── Function call ───────────────────────────────────────── */
                const funcName = tok.text;

                if (funcName === 'switch') {
                    /* 'switch' is a keyword that uses call syntax switch(expr).
                     * Track its arg so we can detect the variable name. */
                    switchVarCand = null;
                    stack.push({ func: 'switch', argIdx: 0, isSwitch: true });
                } else {
                    stack.push({ func: funcName, argIdx: 0 });

                    /* Check for RETURNS annotation → record assignment target. */
                    const retType = returnsMap[funcName];
                    if (retType) {
                        /* Pattern: the last two non-whitespace tokens before the
                         * function name must be  IDENT(varname)  OTHER('=')  .
                         * This avoids false positives like  x = 5; func()  where
                         * '=' belongs to a different assignment. */
                        const len = recent.length;
                        if (len >= 2
                            && recent[len-1].kind === TK.OTHER && recent[len-1].text === '='
                            && recent[len-2].kind === TK.IDENT) {
                            varTypes[recent[len-2].text] = retType;
                        }
                    }
                }

                pushRecent(tok);
                out.push(funcName);
            } else {
                /* ── Non-call identifier ─────────────────────────────────── */

                if (tok.text === 'case') {
                    /* 'case' inside a typed switch body → next INT gets substituted. */
                    const sw = switchScopes.length > 0 ? switchScopes[switchScopes.length-1] : null;
                    if (sw && sw.openDepth === braceDepth) {
                        afterCase = true;
                    }
                } else {
                    /* Any other identifier after 'case' means the value was already
                     * substituted (an enum name) — clear the flag. */
                    afterCase = false;

                    /* Record variable name seen inside switch(...) at arg 0. */
                    if (stack.length > 0) {
                        const top = stack[stack.length-1];
                        if (top.isSwitch && top.open && top.argIdx === 0) {
                            switchVarCand = tok.text;
                        }
                    }
                }

                pushRecent(tok);
                out.push(tok.text);
            }
            continue;
        }

        if (tok.kind === TK.LPAREN) {
            if (stack.length > 0 && stack[stack.length-1].open === undefined
                && stack[stack.length-1].func !== null) {
                stack[stack.length-1].open = true;
            } else {
                stack.push({ func: null, open: true });
            }
            pushRecent(tok);
            out.push('(');
            continue;
        }

        if (tok.kind === TK.RPAREN) {
            if (stack.length > 0) {
                const top = stack.pop();
                /* If we just closed switch(...), prepare for the opening '{'. */
                if (top && top.isSwitch) {
                    const enumType = switchVarCand ? varTypes[switchVarCand] : null;
                    if (enumType) switchPending = { enumType };
                    switchVarCand = null;
                }
            }
            pushRecent(tok);
            out.push(')');
            continue;
        }

        if (tok.kind === TK.COMMA) {
            if (stack.length > 0) {
                const top = stack[stack.length-1];
                if (top.func !== null) top.argIdx++;
            }
            pushRecent(tok);
            out.push(',');
            continue;
        }

        if (tok.kind === TK.INT) {
            let replaced = false;

            /* ── Case-label substitution (Category 3) ────────────────────── */
            if (afterCase) {
                afterCase = false;
                const sw = switchScopes.length > 0 ? switchScopes[switchScopes.length-1] : null;
                if (sw && sw.openDepth === braceDepth && enumTypes[sw.enumType]) {
                    let val;
                    try { val = BigInt(tok.text); } catch { /* leave as-is */ }
                    if (val !== undefined) {
                        const name = enumTypes[sw.enumType][String(val)];
                        if (name) { out.push(name); replaced = true; }
                    }
                }
            }

            /* ── Function-argument annotation (Category 1) ───────────────── */
            if (!replaced && stack.length > 0) {
                const top = stack[stack.length-1];
                if (top.func !== null) {
                    const key = `${top.func}:${top.argIdx}`;
                    const expectedType = argMap[key];
                    if (expectedType && enumTypes[expectedType]) {
                        let val;
                        try { val = BigInt(tok.text); } catch { /* leave as-is */ }
                        if (val !== undefined) {
                            const name = enumTypes[expectedType][String(val)];
                            if (name) { out.push(name); replaced = true; }
                        }
                    }
                }
            }

            if (!replaced) out.push(tok.text);
            pushRecent(tok);
            continue;
        }

        /* ── OTHER tokens: track braces, reset afterCase on non-whitespace ── */
        if (tok.kind === TK.OTHER) {
            if (tok.text === '{') {
                braceDepth++;
                if (switchPending) {
                    switchScopes.push({ openDepth: braceDepth, enumType: switchPending.enumType });
                    switchPending = null;
                }
            } else if (tok.text === '}') {
                /* Pop switch scope if we're closing its body. */
                if (switchScopes.length > 0
                    && switchScopes[switchScopes.length-1].openDepth === braceDepth) {
                    switchScopes.pop();
                }
                braceDepth--;
                /* Exiting a top-level function → clear all variable-type info. */
                if (braceDepth === 0) {
                    for (const k of Object.keys(varTypes)) delete varTypes[k];
                    afterCase = false;
                }
            } else if (tok.text.trim() !== '') {
                /* Non-whitespace, non-brace OTHER after 'case' → not an int value. */
                afterCase = false;
            }
        }

        pushRecent(tok);
        out.push(tok.text);
    }

    return out.join('');
}

/* ── Main ────────────────────────────────────────────────────────────────── */

const enumSrc   = fs.readFileSync(ENUMS_PATH, 'utf8');
const annotSrc  = fs.readFileSync(ANNOTS, 'utf8');

const { types: enumTypes }         = parseEnumH(enumSrc);
const { argMap, returnsMap }       = parseAnnotations(annotSrc);

console.log(`Loaded ${Object.keys(enumTypes).length} enum types`);
console.log(`Loaded ${Object.keys(argMap).length} arg annotations, ${Object.keys(returnsMap).length} RETURNS annotations`);

fs.mkdirSync(OUT_DIR, { recursive: true });

const files    = fs.readdirSync(IN_DIR).filter(f => f.endsWith('.m'));
let   changed  = 0;
let   total    = 0;

for (const file of files) {
    const src    = fs.readFileSync(path.join(IN_DIR, file), 'utf8');
    const result = substitute(src, enumTypes, argMap, returnsMap);
    fs.writeFileSync(path.join(OUT_DIR, file), result);
    total++;
    if (result !== src) changed++;
}

console.log(`Processed ${total} scripts, ${changed} modified`);
