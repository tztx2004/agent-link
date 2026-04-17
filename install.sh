#!/usr/bin/env bash
set -euo pipefail

AGENT_LINK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

link() {
  local src="$1"
  local dst="$2"
  local name
  name=$(basename "$src")

  if [ -L "$dst" ]; then
    echo -e "  ${YELLOW}UPDATE${NC}  $name"
    ln -sf "$src" "$dst"
  elif [ -e "$dst" ]; then
    echo -e "  ${YELLOW}SKIP${NC}    $name (non-symlink exists)"
  else
    ln -s "$src" "$dst"
    echo -e "  ${GREEN}LINKED${NC}  $name"
  fi
}

echo "==> Linking agents..."
for agent in "$AGENT_LINK_DIR/agents/"*.md; do
  link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done

echo "==> Linking skills..."
for skill in "$AGENT_LINK_DIR/.agents/skills/"/*/; do
  link "$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
done

echo ""
echo "Done."
