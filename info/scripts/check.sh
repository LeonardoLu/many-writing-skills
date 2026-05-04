#!/usr/bin/env bash
# Pre-flight check for the `info` skill group.
#
# Validates that every skill under info/skills/info-*:
#   - contains SKILL.md
#   - SKILL.md frontmatter has `name:` matching the directory name
#   - SKILL.md frontmatter has `description:`
#
# Exit code: 0 if all pass, 1 otherwise.
#
# Usage: info/scripts/check.sh

set -euo pipefail

GROUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GROUP_NAME="$(basename "$GROUP_DIR")"
SKILLS_DIR="$GROUP_DIR/skills"
PREFIX="${GROUP_NAME}-"

extract_name() {
  awk '
    /^---[[:space:]]*$/ {
      block++
      if (block == 1) next
      if (block == 2) exit
    }
    block == 1 && /^name:[[:space:]]*/ {
      sub(/^name:[[:space:]]*/, "")
      gsub(/[[:space:]]+$/, "")
      print
      exit
    }
  ' "$1"
}

has_description() {
  awk '
    /^---[[:space:]]*$/ {
      block++
      if (block == 1) next
      if (block == 2) exit
    }
    block == 1 && /^description:/ { found = 1; exit }
    END { exit (found ? 0 : 1) }
  ' "$1"
}

CHECKED=0
ERRORS=0

echo "[$GROUP_NAME] Checking skills under $SKILLS_DIR (prefix: $PREFIX)..."

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "  FAIL: skills dir not found: $SKILLS_DIR"
  exit 1
fi

shopt -s nullglob
for d in "$SKILLS_DIR"/${PREFIX}*/; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  CHECKED=$((CHECKED + 1))
  skill_md="${d}SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    echo "  FAIL: $name — missing SKILL.md"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  declared_name="$(extract_name "$skill_md")"
  if [[ -z "$declared_name" ]]; then
    echo "  FAIL: $name — SKILL.md missing 'name:' in frontmatter"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if [[ "$declared_name" != "$name" ]]; then
    echo "  FAIL: $name — name mismatch: declared '$declared_name', dir '$name'"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if ! has_description "$skill_md"; then
    echo "  FAIL: $name — SKILL.md missing 'description:' in frontmatter"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo "  OK:   $name"
done

if [[ "$CHECKED" -eq 0 ]]; then
  echo "  (no skills with prefix '$PREFIX' found under $SKILLS_DIR)"
fi

echo "[$GROUP_NAME] Checked: $CHECKED, Errors: $ERRORS"
[[ "$ERRORS" -eq 0 ]] || exit 1
