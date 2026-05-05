#!/usr/bin/env bash
# Ensure the `info/` zone directory layout exists in the target vault, and
# seed placeholder docs (taxonomy / dashboard / README) when missing.
#
# Creates / seeds (only if missing):
#   info/
#   info/inbox/
#   info/inbox/<current YYYY-MM>/
#   info/research/                          <- info-research workspace root
#   info/_taxonomy.md       <- copied from info/vault-template/_taxonomy.md
#   info/dashboard.md       <- copied from info/vault-template/dashboard.md
#   info/README.md          <- copied from info/vault-template/README.md
#
# Existing files are left untouched.
#
# Usage:
#   info/scripts/prepare-vault.sh --vault <path> [--dry-run]

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GROUP_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
TEMPLATE_DIR="$GROUP_DIR/vault-template"

VAULT=""
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$VAULT" ]] || { echo "Error: --vault <path> is required" >&2; exit 1; }
[[ -d "$VAULT" ]] || { echo "Error: vault not found: $VAULT" >&2; exit 1; }

CURRENT_MONTH="$(date +%Y-%m)"

DIRS=(
  "info"
  "info/inbox"
  "info/inbox/$CURRENT_MONTH"
  "info/research"
)

# Pairs: "<vault-relative-target>|<template-source-basename>"
FILES=(
  "info/_taxonomy.md|_taxonomy.md"
  "info/dashboard.md|dashboard.md"
  "info/README.md|README.md"
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

ensure_file_from_template() {
  local rel="$1" src_name="$2"
  local target="$VAULT/$rel"
  local tmpl="$TEMPLATE_DIR/$src_name"
  if [[ -f "$target" ]]; then
    echo "  ok:    file $rel"
    return 0
  fi
  if [[ ! -f "$tmpl" ]]; then
    echo "  FAIL:  template missing: $tmpl" >&2
    return 1
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] file $rel  <-  vault-template/$src_name"
  else
    cp "$tmpl" "$target"
    echo "  create file $rel  <-  vault-template/$src_name"
  fi
}

echo "[info] prepare-vault in $VAULT"

for d in "${DIRS[@]}"; do
  ensure_dir "$d"
done

for pair in "${FILES[@]}"; do
  rel="${pair%%|*}"
  src="${pair#*|}"
  ensure_file_from_template "$rel" "$src"
done

echo "[info] prepare-vault done"
