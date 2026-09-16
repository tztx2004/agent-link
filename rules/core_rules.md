# Core Rules for Agent Team

## 1. Precedence & Overrides

- **Local Rules First**: If project-root agent instructions (`AGENTS.md` / `CLAUDE.md`) exist, they OVERRIDE these global rules — including the stack-specific standards in §4 and everything in `style_guidelines.md`. When the project names a framework, styling system, or file convention, follow the project over any default stated here.
- **MCP Priority**: If `context7` or `sequential-thinking` MCPs are available, use them as the primary tools for research and reasoning.

## 2. Operational Mandates (Role & Workflow)

- **Orchestrator (Leader)**: Strategic planning, high-level architecture, and task distribution.
  - **Focused / Bounded tasks**: Can be implemented directly by the active agent or single subagent, verifying with lint/tests without multi-agent chain overhead.
  - **Large-scale / Parallel tasks**: Decomposed and delegated across specialized subagents (Frontend, Backend, etc.).
- **Sub-agents (Execution)**: Perform tasks strictly according to assigned scope and verify their own work.
- **Reviewer & QA**: Utilized for complex multi-agent milestones or pull-request readiness checks.

## 3. Verification Protocol (Grounded in Evidence)

- **Workflow**: `Think → Implement → VERIFY (commands/tests) → Output`.
- **Scope**: Mandatory for all code modifications, file writes, and completion claims. (Conversational turns exempt from audit blocks).
- **Two Gates**: (B) Rule Conformance, (C) Evidence (real command outputs).
- **Source**: `~/.config/agent-link/rules/verification.md`.

## 4. Technical Standards (default: Next.js / RSC)

> **Stack detection first**: check the project's `package.json`. If `next` is a dependency, apply the Next.js default below. If it uses `vite` (or CRA) with no `next`, apply the **SPA exception** instead. When unsure, defer to the project's own agent instructions and `web/` rules.

- **Rendering model (default — Next.js / RSC)**: prefer Server Components; drop to Client Components (`'use client'`) only at the leaves.
  - **SPA exception (Vite / CRA)**: every component is a client component. Server Components, Server Actions, and `loading.tsx` do not exist — use the project's data-fetching + `Suspense`/`ErrorBoundary` conventions instead.
- **Linting & Formatting**: Follow local configurations strictly.

## 5. Final Reporting (Human-Facing)

- **Language**: Korean.
- **Format**: Compare "Before" vs. "After".
- **Metrics**: Quantify improvements whenever possible (e.g., "Reduced code lines by 15%", "Removed 3 redundant dependencies", "Passed 100% of 5 new test cases").

## 6. Feedback Ledger (Recurrence Prevention)

- **Reference**: `~/.config/agent-link/feedback/INDEX.md` lists durable lessons learned from past corrections and recurring failures.
- **Honor lessons**: When touching areas related to recorded lessons (e.g. rename operations, loading UX, branch commits), ensure compliance with the lesson guidelines. Detailed lesson bodies in `feedback/lessons/` are consulted on-demand when relevant.
- **Capture**: When a user explicitly corrects a result or recurring failures occur, record the durable lesson.
- **Never auto-promote**: A lesson becomes a rule only with explicit human approval.
