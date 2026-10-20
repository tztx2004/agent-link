# Agent Development

When creating or modifying agents, always use the `agent-development` skill via the `Skill` tool. This skill provides guidelines on agent structure, frontmatter, tool selection, and best practices.

# File Naming Convention

- `.tsx` files: PascalCase (e.g., `UserCard.tsx`, `AuthModal.tsx`)
- `.ts` files: camelCase (e.g., `useUser.ts`, `fetchOrders.ts`)

# Language

Always respond in Korean.

# Skill Usage

The superpowers plugin injects a "using-superpowers" instruction at session start that says to invoke a skill whenever there is even a 1% chance it applies. That threshold is overridden here: invoke a skill when the task clearly matches its description, and handle simple questions, small edits, and lookups directly without a skill. Process skills (brainstorming, systematic-debugging, TDD, writing-plans) are for work where their process adds value — new features, real bugs, multi-step plans — not for every turn. Project instructions (AGENTS.md / CLAUDE.md) take precedence over a skill's workflow when they conflict.
