#!/usr/bin/env bash
# Ensure the `tasks/` zone directory layout exists in the target vault.
#
# Creates missing directories that the task-* skills depend on:
#   tasks/
#   tasks/inbox/
#   tasks/active/
#   tasks/archived/
#   tasks/archived/<current YYYY-MM>/
#
# Each task is a single markdown file at:
#   tasks/inbox/<YYYYMMDD-HHMM>-<slug>.md      (after task-collect)
#   tasks/active/<YYYYMMDD-HHMM>-<slug>.md     (after task-organize promote)
#   tasks/archived/YYYY-MM/<YYYYMMDD-HHMM>-<slug>.md  (after task-operate done/drop)
#
# Usage:
#   task/scripts/prepare-vault.sh --vault <path> [--dry-run]

set -euo pipefail

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
  "tasks"
  "tasks/inbox"
  "tasks/active"
  "tasks/archived"
  "tasks/archived/$CURRENT_MONTH"
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

echo "[task] prepare-vault in $VAULT"
for d in "${DIRS[@]}"; do
  ensure_dir "$d"
done
echo "[task] prepare-vault done"
