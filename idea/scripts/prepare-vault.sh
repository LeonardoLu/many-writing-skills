#!/usr/bin/env bash
# Ensure the `ideas/` zone directory layout exists in the target vault.
#
# Creates missing directories that the idea-* skills depend on:
#   ideas/
#
# Each idea is captured as its own subdirectory under ideas/<idea-name>/,
# created on demand by the idea-create skill. We do not pre-create per-idea
# directories here.
#
# Usage:
#   idea/scripts/prepare-vault.sh --vault <path> [--dry-run]

set -euo pipefail

VAULT=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$VAULT" ]] || { echo "Error: --vault <path> is required" >&2; exit 1; }
[[ -d "$VAULT" ]] || { echo "Error: vault not found: $VAULT" >&2; exit 1; }

DIRS=(
  "ideas"
)

ensure_dir() {
  local rel="$1"
  local full="$VAULT/$rel"
  if [[ -d "$full" ]]; then
    echo "  ok:    dir  $rel"
  elif [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] dir  $rel"
  else
    mkdir -p "$full"
    echo "  create dir  $rel"
  fi
}

echo "[idea] prepare-vault in $VAULT"
for d in "${DIRS[@]}"; do
  ensure_dir "$d"
done
echo "[idea] prepare-vault done"
