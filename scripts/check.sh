#!/usr/bin/env bash
# Repo-level orchestrator: invoke each skill group's check.sh.
#
# Two supported layouts for groups:
#   1. Legacy:  scripts/<group>/check.sh
#   2. Bundled: <group>/scripts/check.sh   (group dir at repo root contains
#               both skills/ and scripts/ subfolders, e.g. idea/)
#
# Usage:
#   scripts/check.sh [--group <name>|all]
#
# Default:
#   --group all

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"

GROUP="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group) GROUP="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

shopt -s nullglob

# Each entry: "<group_name>|<checker_path>"
ALL_ENTRIES=()

for d in "$SCRIPT_DIR"/*/; do
  checker="${d}check.sh"
  [[ -f "$checker" ]] || continue
  ALL_ENTRIES+=("$(basename "$d")|$checker")
done

for d in "$REPO_ROOT"/*/; do
  [[ -d "${d}skills" ]] || continue
  checker="${d}scripts/check.sh"
  [[ -f "$checker" ]] || continue
  ALL_ENTRIES+=("$(basename "$d")|$checker")
done

if [[ ${#ALL_ENTRIES[@]} -eq 0 ]]; then
  echo "[$REPO_NAME] No skill groups found"
  exit 0
fi

SELECTED_ENTRIES=()
if [[ "$GROUP" == "all" ]]; then
  SELECTED_ENTRIES=("${ALL_ENTRIES[@]}")
else
  for entry in "${ALL_ENTRIES[@]}"; do
    name="${entry%%|*}"
    if [[ "$name" == "$GROUP" ]]; then
      SELECTED_ENTRIES+=("$entry")
    fi
  done
  if [[ ${#SELECTED_ENTRIES[@]} -eq 0 ]]; then
    echo "[$REPO_NAME] No group named '$GROUP'" >&2
    exit 1
  fi
fi

EXIT=0
for entry in "${SELECTED_ENTRIES[@]}"; do
  name="${entry%%|*}"
  checker="${entry#*|}"
  echo "[$REPO_NAME] -> $name"
  if ! bash "$checker"; then
    EXIT=1
  fi
  echo
done

exit $EXIT
