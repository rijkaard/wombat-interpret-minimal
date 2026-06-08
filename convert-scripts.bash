#!/usr/bin/env bash

SCRSCRIPTS="$1"
DSTROOT="$2"

usage() {
    echo "usage: $0 <scripts-dir> <destination>"
    echo "  e.g. $0 ../rundir-wip/scripts.wombat /tmp/uo/wip"
}

[[ -z "$SRCSCRIPTS" ]] && { usage; exit 1; }
[[ -z "$DSTROOT" ]] && { usage; exit 1; }

set -euo pipefail

DSTSCRIPTS="$DSTROOT/scripts.interpreted"
DSTSCRIPTS_ENUM="$DSTROOT/scripts.enum"
DSTSYMBOLS="$DSTROOT/symbols.json"

[[ -d "$SRCSCRIPTS" ]] || { echo "not a directory: $SRCSCRIPTS"; exit 1; }
[[ -d "$DSTSCRIPTS" ]] && { echo "directory exists: $DSTSCRIPTS"; exit 1; }
[[ -d "$DSTSCRIPTS_ENUM" ]] && { echo "directory exists: $DSTSCRIPTS_ENUM"; exit 1; }
[[ -f "$DSTSYMBOLS" ]] && echo "symbols will be overwritten: $DSTSYMBOLS"

mkdir -p "$DSTSCRIPTS"
mkdir -p "$DSTSCRIPTS_ENUM"

echo "copying: $SRCSCRIPTS -> $DSTSCRIPTS"
cp -r "$SRCSCRIPTS"/* "$DSTSCRIPTS/"

echo -e "---\nextracting symbols -> $DSTSYMBOLS"
node tools/extract-symbols.js \
    --scripts-dir "$DSTSCRIPTS" \
    --out "$DSTSYMBOLS"

echo -e "---\napplying renames -> $DSTSCRIPTS"
node tools/apply-renames.js \
    renames/renames.json \
    --scripts-dir "$DSTSCRIPTS" \
    --symbols "$DSTSYMBOLS"

echo -e "---\napplying local renames -> $DSTSCRIPTS"
node tools/apply-renames-locals.js \
    --input renames/renames.json \
    --scripts-dir "$DSTSCRIPTS" \
    --renames "$DSTROOT/renames.json"

echo -e "---\napplying enum renames: $DSTSCRIPTS -> $DSTSCRIPTS_ENUM"
node tools/gen-scripts-enum.mjs \
  --enums   ../wombat-ext/compiler/enumerations.h \
  --annots  ../wombat-ext/compiler/enum-annotations.txt \
  --in      "$DSTSCRIPTS" \
  --out     "$DSTSCRIPTS_ENUM"

