#!/usr/bin/env bash

DIR1="$1"
DIR2="$2"

usage() {
    echo "$0 <scripts-dir-1> <scripts-dir-2>"
}

[[ -z "$DIR1" ]] && { usage; exit 1; }
[[ -z "$DIR2" ]] && { usage; exit 1; }

set -euo pipefail

DIR1="$(realpath "$DIR1")"
DIR2="$(realpath "$DIR2")"

[[ "$DIR1" = "$DIR2" ]] && { echo "same directory twice"; exit 1; }

trap "popd" EXIT

pushd .
cd "$DIR1"

for ff in * ; do
    echo "=== $ff"
    [[ -f "$DIR2/$ff" ]] || { echo "!! file $ff doesn't exist in $DIR2"; continue; }
    diff "$ff" "$DIR2/$ff" || true
done


