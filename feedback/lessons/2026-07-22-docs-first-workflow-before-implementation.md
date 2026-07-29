---
id: docs-first-workflow-before-implementation
trigger: user-correction
gate: A
occurrences: 1
created: 2026-07-22
scope: universal
status: active
---

## Symptom (What went wrong)

The orchestrator delegated implementation of the event schema v2.0.0 parser (T-EVT-011, INNOWATCH VMS) directly to `golang-backend-developer` on a new branch without first writing the corresponding Task document (`docs/tasks/event-alarm.md`), even though the project's `AGENTS.md` explicitly states the workflow order: "check scope in product.md → check/write Goal → check/write Task → implement." The gap was only caught after implementation and QA were already done, at commit-review time.

## Correct approach

Before delegating any implementation work, check the project's root agent-instruction file (`AGENTS.md` / `CLAUDE.md` or equivalent index) for a documented workflow order. When it mandates a docs-before-code sequence (e.g. product → goal → task-doc → implement, or an RFC/spec-first convention), write or confirm the relevant task/spec document FIRST — using the project's own doc commit convention (e.g. `SPEC:` prefix) — and only then delegate implementation (e.g. `T-<GROUP>-###:` commit). This check is part of the orchestrator's Gate A (Requirement Alignment) read step, performed before any delegation, not discovered afterward via user correction.

## When to apply

Orchestrator agent, at the planning/delegation step, for any project whose root instruction file specifies a docs-before-code workflow (product→goal→task, spec-first, RFC-first, ADR-first, etc.). Not limited to INNOWATCH — apply this check whenever a project's `AGENTS.md`/`CLAUDE.md` names an explicit document-then-implement sequence.

## Why (recurrence/correction log)

- 2026-07-22 user correction: "이 프로젝트는 구현보다 문서가 먼저야. 문서 작성해줘" — orchestrator had delegated T-EVT-011 (event schema v2.0.0 parser) implementation to `golang-backend-developer` before `docs/tasks/event-alarm.md` was authored, skipping AGENTS.md's product→goal→task→implement order.
