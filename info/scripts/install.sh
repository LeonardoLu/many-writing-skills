#!/usr/bin/env bash
# Install the `info` skill group into the target vault.
#
# Steps:
#   1. Run prepare-vault.sh to ensure the info/ layout exists in the vault.
#   2. Copy each skill from info/skills/info-* into:
#        <vault>/.<tool>/skills/<skill>/
#      for each requested tool.
#
# Usage:
#   info/scripts/install.sh --vault <path> [--tool cursor|codex|claude|all] [--dry-run]

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GROUP_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
GROUP_NAME="$(basename "$GROUP_DIR")"
SKILLS_DIR="$GROUP_DIR/skills"
PREFIX="${GROUP_NAME}-"

VAULT=""
TOOL="all"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --tool) TOOL="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$VAULT" ]] || { echo "Error: --vault <path> is required" >&2; exit 1; }
[[ -d "$VAULT" ]] || { echo "Error: vault not found: $VAULT" >&2; exit 1; }

case "$TOOL" in
  all) TOOLS=(cursor codex claude) ;;
  cursor|codex|claude) TOOLS=("$TOOL") ;;
  *) echo "Error: unknown --tool: $TOOL (allowed: cursor, codex, claude, all)" >&2; exit 1 ;;
esac

prepare_args=(--vault "$VAULT")
[[ "$DRY_RUN" -eq 1 ]] && prepare_args+=(--dry-run)
bash "$SCRIPTS_DIR/prepare-vault.sh" "${prepare_args[@]}"

shopt -s nullglob
SKILLS=()
for d in "$SKILLS_DIR"/${PREFIX}*/; do
  [[ -d "$d" && -f "${d}SKILL.md" ]] || continue
  SKILLS+=("$(basename "$d")")
done

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  echo "[$GROUP_NAME] No skills with prefix '$PREFIX' to install."
  exit 0
fi

echo "[$GROUP_NAME] Installing ${#SKILLS[@]} skill(s) into $VAULT for: ${TOOLS[*]}"

for tool in "${TOOLS[@]}"; do
  TARGET_BASE="$VAULT/.$tool/skills"
  for skill in "${SKILLS[@]}"; do
    SRC="$SKILLS_DIR/$skill"
    DEST="$TARGET_BASE/$skill"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "  [dry-run] $skill -> $DEST"
    else
      mkdir -p "$TARGET_BASE"
      rm -rf "$DEST"
      cp -R "$SRC" "$DEST"
      echo "  $skill -> $DEST"
    fi
  done
done

echo "[$GROUP_NAME] Done."
