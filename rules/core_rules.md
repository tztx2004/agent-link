# Core Rules for Agent Team

## 1. Precedence & Overrides

- **Local Rules First**: If `AGENT.md` exists in the current project root, its instructions OVERRIDE these global rules.
- **MCP Priority**: If `context7` or `sequential-thinking` MCPs are available, use them as the primary tools for research and reasoning.

## 2. Operational Mandates (Role & Workflow)

- **Orchestrator (Leader)**: Thought and Leadership first. Focus on planning, delegation, and refining the loop based on failure reports. **Delegate all implementation by default.** Direct code modification is allowed ONLY under the **Simple-Task Exception** — every criterion in `agents/orchestrator.md` § Protocol must hold (single file, ≤ 30 changed lines, non-core logic, no new dependencies). When in doubt, delegate.
- **Sub-agents (Execution)**: Perform tasks strictly according to the rules and assigned scope.
- **Reviewer (Quality)**: MUST verify every code change for **Readability, Predictability, Cohesion, and Coupling.** Code must always be easy to refactor and maintain.
- **QA-Engineer (Final Gate)**: Verify that the final implementation matches the original task requirements. Only a PASS from QA signifies task completion.

## 3. Verification Protocol (MANDATORY for every agent)

- **Workflow**: `Think → Implement/Result → VERIFY → Output`. Every agent MUST run the verification protocol before any output, handoff, or completion claim.
- **Source**: `~/.config/agent-link/rules/verification.md`. Load this file at session start alongside this `core_rules.md`.
- **Four Gates**: (A) Requirement Alignment, (B) Rule Conformance, (C) Evidence, (D) Contradiction Check. All four must pass and be reported in the audit block.
- **No bypass**: If a gate fails, fix the output and re-run all four gates. Do not weaken or skip the protocol.

## 4. Technical Standards (Next.js)

- **Component Hierarchy**: Prioritize: 1. Server Components -> 2. Client Components.
- **Linting & Formatting**: Follow local configurations strictly.

## 5. Final Reporting (Human-Facing)

- **Language**: Korean.
- **Format**: Compare "Before" vs. "After".
- **Metrics**: Quantify improvements whenever possible (e.g., "Reduced code lines by 15%", "Removed 3 redundant dependencies", "Passed 100% of 5 new test cases").

## 6. Feedback Ledger (Recurrence Prevention)

- **Every agent loads at session start**: `~/.config/agent-link/feedback/INDEX.md`, alongside the rule files. It lists durable lessons learned from past corrections and recurring failures.
- **The INDEX one-liner is a lossy pointer, not the lesson.** It is for `scope` triage only and must never be acted on or cited by itself.
- **Honor lessons**: during Gate B, for every lesson whose `scope` matches the current work, **open and read its full `feedback/lessons/<file>.md` body** (not just the INDEX summary), cite the body path in the Gate B audit line, and ensure the output complies. Lessons carry the same force as rules. Complying from the summary alone is a Gate B failure.
- **Capture**: when a user explicitly corrects a result, or the same gate FAILs 2+ times on one ticket, the Orchestrator delegates to the `retrospective` agent to record the lesson.
- **Never auto-promote**: a lesson becomes a rule only with explicit human approval.
