#!/usr/bin/env bash
# Repo-level orchestrator: invoke each skill group's install.sh.
#
# Two supported layouts for groups:
#   1. Legacy:  scripts/<group>/install.sh
#   2. Bundled: <group>/scripts/install.sh   (group dir at repo root contains
#               both skills/ and scripts/ subfolders, e.g. idea/)
#
# Usage:
#   scripts/install.sh --vault <path>
#                      [--tool cursor|codex|claude|agents|all]
#                      [--group <name>|all]
#                      [--dry-run]
#
# Defaults:
#   --tool  all
#   --group all

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_NAME="$(basename "$REPO_ROOT")"

VAULT=""
TOOL="all"
GROUP="all"
DRY_RUN_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --tool) TOOL="$2"; shift 2 ;;
    --group) GROUP="$2"; shift 2 ;;
    --dry-run) DRY_RUN_FLAG="--dry-run"; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$VAULT" ]] || { echo "Error: --vault <path> is required" >&2; exit 1; }

shopt -s nullglob

# Each entry: "<group_name>|<installer_path>"
ALL_ENTRIES=()

for d in "$SCRIPT_DIR"/*/; do
  installer="${d}install.sh"
  [[ -f "$installer" ]] || continue
  ALL_ENTRIES+=("$(basename "$d")|$installer")
done

for d in "$REPO_ROOT"/*/; do
  [[ -d "${d}skills" ]] || continue
  installer="${d}scripts/install.sh"
  [[ -f "$installer" ]] || continue
  ALL_ENTRIES+=("$(basename "$d")|$installer")
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
  installer="${entry#*|}"
  echo "[$REPO_NAME] -> $name"
  if ! bash "$installer" --vault "$VAULT" --tool "$TOOL" $DRY_RUN_FLAG; then
    EXIT=1
  fi
  echo
done

exit $EXIT
