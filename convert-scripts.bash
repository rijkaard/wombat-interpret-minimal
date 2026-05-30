#!/usr/bin/env bash

SCRIPTSDIR="$1"
RENAMESFILE="$2"
DESTINATION="$3"

set -euo pipefail

usage() {
  echo "bash convert-scripts.bash <SCRIPTS-DIR> <RENAMES-JSON> <DESTINATION>"
}

[[ -z "$SCRIPTSDIR" ]] && { usage; exit 1; }
[[ -z "$RENAMESFILE" ]] && { usage; exit 1; }
[[ -z "$DESTINATION" ]] && { usage; exit 1; }

SCRIPTSDIR="$(realpath "$SCRIPTSDIR")"
RENAMESFILE="$(realpath "$RENAMESFILE")"
DESTINATION="$(realpath "$DESTINATION")"
THISDIR="$(dirname "$(realpath "$0")")"

echo "SCRIPTSDIR=$SCRIPTSDIR"
echo "RENAMESFILE=$RENAMESFILE"
echo "DESTINATION=$DESTINATION"
echo "THISDIR=$THISDIR"

cd "$THISDIR"

symbols() {
    local where="$1"
    node extract-symbols.js --scripts-dir "$where"
}

apply() {
    local renames="$1"
    local oriscripts="$2"
    local modscripts="$3"
    mkdir -p "$modscripts"
    cp "$oriscripts"/* "$modscripts/"
    chmod +w "$modscripts"/*
    node apply-renames.js "$renames" --scripts-dir "$modscripts"
    local localsfile
    localsfile="$(mktemp --suffix=.json)"
    node -e "
const r=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));
const o={};
for(const[k,v]of Object.entries(r)){
  const ld=k.lastIndexOf('.');
  if(ld<0)continue;
  const qc=k.slice(ld+1);
  if(!/^Q[0-9A-Z]{3}$/.test(qc))continue;
  const fd=k.indexOf('.');
  if(fd===ld)continue;
  o[k]=v;
}
require('fs').writeFileSync(process.argv[2],JSON.stringify(o,null,2));
" "$renames" "$localsfile"
    node apply-renames-locals.js --input "$localsfile" --scripts-dir "$modscripts" --renames "$renames"
    rm -f "$localsfile"
}

verify() {
    local renames="$1"
    local modscripts="$2"
    local oriscripts="$3"
    local tmpdir="$(mktemp -d)"
    local symbolspath
    symbolspath="$tmpdir/symbols.json"
    mkdir -p "$tmpdir/modified"
    cp -r "$modscripts"/* "$tmpdir/modified/"
    echo "using temp dir $tmpdir"
    echo "copied $(ls "$tmpdir" | wc -l) files"
    echo "extracting symbols for the modified scripts directory"
    node extract-symbols.js --scripts-dir "$modscripts" --out "$symbolspath"
    node reverse-verify.js \
        --orig-dir "$oriscripts" \
	--scripts-dir "$tmpdir/modified" \
	--renames "$renames" \
	--symbols "$symbolspath" \
	--out-dir "$tmpdir/reversed"
}

# [[ -e "$SCRIPTSDIR" ]] && { echo "The destination '$DESTINATION' exists; exiting";exit 1; }

mkdir -p "$SCRIPTSDIR"

echo "=== Initial symbols"
symbols "$SCRIPTSDIR"

echo "=== Applying changes"
apply "$RENAMESFILE" "$SCRIPTSDIR" "$DESTINATION"

echo "=== Verifying reverse"
verify "$RENAMESFILE" "$DESTINATION" "$SCRIPTSDIR"

echo "=== Remaining symbols"
symbols "$DESTINATION"

