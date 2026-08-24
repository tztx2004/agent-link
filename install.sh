#!/usr/bin/env bash
set -euo pipefail

AGENT_LINK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
GEMINI_DIR="$HOME/.gemini/config"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

link() {
  local src="$1"
  local dst="$2"
  local name
  name=$(basename "$src")

  # Ensure destination parent directory exists
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    echo -e "  ${YELLOW}UPDATE${NC}  $name"
    ln -sfn "$src" "$dst"
  elif [ -e "$dst" ]; then
    echo -e "  ${YELLOW}SKIP${NC}    $name (non-symlink exists)"
  else
    ln -sn "$src" "$dst"
    echo -e "  ${GREEN}LINKED${NC}  $name"
  fi
}

echo "==> [Claude] Linking agents..."
mkdir -p "$CLAUDE_DIR/agents"
for agent in "$AGENT_LINK_DIR/agents"/*.md; do
  [ -e "$agent" ] || continue
  link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done

echo "==> [Claude] Linking skills..."
mkdir -p "$CLAUDE_DIR/skills"
for skill in "$AGENT_LINK_DIR/.agents/skills"/*; do
  [ -d "$skill" ] || continue
  link "$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
done

echo "==> [Gemini/Antigravity] Linking agents..."
mkdir -p "$GEMINI_DIR/agents"
for agent in "$AGENT_LINK_DIR/agy-agents"/*.md; do
  [ -e "$agent" ] || continue
  link "$agent" "$GEMINI_DIR/agents/$(basename "$agent")"
done

echo "==> [Gemini/Antigravity] Linking skills..."
mkdir -p "$GEMINI_DIR/skills"
for skill in "$AGENT_LINK_DIR/.agents/skills"/*; do
  [ -d "$skill" ] || continue
  link "$skill" "$GEMINI_DIR/skills/$(basename "$skill")"
done

echo "==> [Gemini/Antigravity] Linking rules..."
mkdir -p "$GEMINI_DIR/rules"
for rule in "$AGENT_LINK_DIR/rules"/*.md; do
  [ -e "$rule" ] || continue
  link "$rule" "$GEMINI_DIR/rules/$(basename "$rule")"
done

echo ""
echo "Done."

