#!/usr/bin/env bash
# heckit installer — copies skills (flattened), agents, and commands into your coding agent.
# Usage:  ./install.sh <claude|opencode|codex> [global|project]
#   global  (default) -> installs into your home config
#   project           -> installs into ./.claude or ./.opencode in the current repo
set -euo pipefail

TOOL="${1:-}"
SCOPE="${2:-global}"
REPO="$(cd "$(dirname "$0")" && pwd)"
CM=""

case "$TOOL" in
  claude)
    if [ "$SCOPE" = project ]; then SK=".claude/skills"; AG=".claude/agents"; CM=".claude/commands";
    else SK="$HOME/.claude/skills"; AG="$HOME/.claude/agents"; CM="$HOME/.claude/commands"; fi ;;
  opencode)
    if [ "$SCOPE" = project ]; then SK=".opencode/skills"; AG=".opencode/agent"; CM=".opencode/commands";
    else SK="$HOME/.config/opencode/skills"; AG="$HOME/.config/opencode/agent"; CM="$HOME/.config/opencode/commands"; fi ;;
  codex)
    # Codex has no separate sub-agent or slash-command format: both are installed as skills too.
    SK="$HOME/.agents/skills"; AG="$SK"; CM="$SK" ;;
  *)
    echo "usage: ./install.sh <claude|opencode|codex> [global|project]"; exit 1 ;;
esac

mkdir -p "$SK" "$AG" "$CM"

# --- skills: flatten skills/<category>/<name>/ -> $SK/<name>/ ---
# (Claude discovers skills only one level deep, so categories must be flattened.)
count=0
for d in "$REPO"/skills/*/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  rm -rf "${SK:?}/$name"
  cp -R "$d" "$SK/$name"
  count=$((count+1))
done

# --- agents ---
acount=0
for f in "$REPO"/agents/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f" .md)"
  if [ "$TOOL" = codex ]; then
    mkdir -p "$SK/$name"
    cp "$f" "$SK/$name/SKILL.md"
  else
    cp "$f" "$AG/"
  fi
  acount=$((acount+1))
done

# --- commands (slash commands) ---
ccount=0
for f in "$REPO"/commands/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f" .md)"
  if [ "$TOOL" = codex ]; then
    mkdir -p "$SK/$name"
    cp "$f" "$SK/$name/SKILL.md"
  else
    cp "$f" "$CM/"
  fi
  ccount=$((ccount+1))
done

echo "heckit: installed $count skills    -> $SK"
echo "heckit: installed $acount agents   -> $AG"
echo "heckit: installed $ccount commands -> $CM"
echo "Done. Restart your agent (or reload) to pick them up."
