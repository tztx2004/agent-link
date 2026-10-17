#!/usr/bin/env bash
set -euo pipefail

AGENT_LINK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"
GEMINI_DIR="$HOME/.gemini/config"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

prune_orphaned_links() {
  local target_dir="$1"
  local src_base_dir="$2"
  [ -d "$target_dir" ] || return 0

  for link_path in "$target_dir"/*; do
    [ -L "$link_path" ] || continue
    local name
    name=$(basename "$link_path")

    # 1. Broken symlink
    if [ ! -e "$link_path" ]; then
      echo -e "  ${RED}PRUNE${NC}   $name (broken symlink)"
      rm -f "$link_path"
      continue
    fi

    # 2. Symlink points to this repo's source base dir, but original file was removed
    local link_target
    link_target=$(readlink "$link_path")
    if [[ "$link_target" != /* ]]; then
      link_target="$(cd "$(dirname "$link_path")" && pwd)/$link_target"
    fi

    if [[ "$link_target" == "$src_base_dir"* ]]; then
      if [ ! -e "$link_target" ]; then
        echo -e "  ${RED}PRUNE${NC}   $name (source removed)"
        rm -f "$link_path"
      fi
    fi
  done
}

echo "==> [Claude] Linking agents..."
mkdir -p "$CLAUDE_DIR/agents"
for agent in "$AGENT_LINK_DIR/agents"/*.md; do
  [ -e "$agent" ] || continue
  link "$agent" "$CLAUDE_DIR/agents/$(basename "$agent")"
done
prune_orphaned_links "$CLAUDE_DIR/agents" "$AGENT_LINK_DIR/agents"

echo "==> [Claude] Linking skills..."
mkdir -p "$CLAUDE_DIR/skills"
for skill in "$AGENT_LINK_DIR/.agents/skills"/*; do
  [ -d "$skill" ] || continue
  link "$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
done
prune_orphaned_links "$CLAUDE_DIR/skills" "$AGENT_LINK_DIR/.agents/skills"

echo "==> [Codex] Linking skills..."
mkdir -p "$CODEX_DIR/skills"
for skill in "$AGENT_LINK_DIR/.agents/skills"/*; do
  [ -d "$skill" ] || continue
  link "$skill" "$CODEX_DIR/skills/$(basename "$skill")"
done
prune_orphaned_links "$CODEX_DIR/skills" "$AGENT_LINK_DIR/.agents/skills"

echo "==> [Codex] Linking global instructions..."
link "$AGENT_LINK_DIR/codex/AGENTS.md" "$CODEX_DIR/AGENTS.md"

echo "==> [Codex] Linking agents..."
mkdir -p "$CODEX_DIR/agents"
for agent in "$AGENT_LINK_DIR/codex-agents"/*.toml; do
  [ -e "$agent" ] || continue
  link "$agent" "$CODEX_DIR/agents/$(basename "$agent")"
done
prune_orphaned_links "$CODEX_DIR/agents" "$AGENT_LINK_DIR/codex-agents"

echo "==> [Gemini/Antigravity] Linking agents..."
mkdir -p "$GEMINI_DIR/agents"
for agent in "$AGENT_LINK_DIR/agy-agents"/*.md; do
  [ -e "$agent" ] || continue
  link "$agent" "$GEMINI_DIR/agents/$(basename "$agent")"
done
prune_orphaned_links "$GEMINI_DIR/agents" "$AGENT_LINK_DIR/agy-agents"

echo "==> [Gemini/Antigravity] Linking skills..."
mkdir -p "$GEMINI_DIR/skills"
for skill in "$AGENT_LINK_DIR/.agents/skills"/*; do
  [ -d "$skill" ] || continue
  link "$skill" "$GEMINI_DIR/skills/$(basename "$skill")"
done
prune_orphaned_links "$GEMINI_DIR/skills" "$AGENT_LINK_DIR/.agents/skills"

echo "==> [Gemini/Antigravity] Linking rules..."
mkdir -p "$GEMINI_DIR/rules"
for rule in "$AGENT_LINK_DIR/rules"/*.md; do
  [ -e "$rule" ] || continue
  link "$rule" "$GEMINI_DIR/rules/$(basename "$rule")"
done
prune_orphaned_links "$GEMINI_DIR/rules" "$AGENT_LINK_DIR/rules"

echo ""
echo "Done."
