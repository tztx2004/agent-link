---
id: defer-instruction-must-not-silently-violate-arch-rules
trigger: user-correction
gate: B
occurrences: 1
created: 2026-06-10
scope: universal
status: active
---

## Symptom (What went wrong)

The user instructed to defer domain creation ("이번 goal은 domain ui/로직 생성이 아니라 구조 완성 — domains 신설은 미룰 수 있으면 뒤로 미뤄"), and the orchestrator/Plan agent interpreted this as implicit permission to place schemas, queries, mutation hooks, and form schemas inside `pages/billing/` locally. This violated the explicit architecture rules (architecture.md §3: schemas/queries belong in `domains/{domain}/api/`; form.md: form schemas and hooks belong in `models/`). The trade-off was never surfaced to the user, and no exception was documented. The deferred local modules grew to 7 files before the user noticed and corrected it.

## Correct approach

When a deferral or postponement instruction would cause a placement decision that violates explicit architecture rules, the agent must do one of the following — never silently violate:

(a) **Rule-compliant minimal skeleton**: create the smallest possible rule-compliant structure (e.g., a near-empty `domains/billing/` directory with stub files) so that locally placed code can be deferred, but the placement itself stays within the rules; OR

(b) **Explicit trade-off confirmation**: before proceeding, surface the conflict to the user in one sentence ("proceeding without creating `domains/billing/` means placing schemas in `pages/billing/` which violates architecture.md §3 — shall I proceed with this exception and document it?"), obtain explicit confirmation, and record the exception in the relevant architecture document.

Deferral instructions override scheduling; they do not override placement rules.

## When to apply

Orchestrator and Plan agents, at the planning step, whenever a "defer / postpone / skip for now" instruction is applied to a structural unit (domain, module, package) that has explicit placement rules for the artifacts it would own. Also applies to any implementation agent that notices a deferral-induced placement conflict during execution.

## Why (recurrence/correction log)

- 2026-06-10 user correction (T-PROT-091/T-PROT-092): "스키마는 domains 레벨에 있어야 하는데 규칙에 없었나? pages에는 ui만 있어야 하는 거 아니야? billing 쪽 page에 로직·스키마가 다 들어가 있는데?" — domains/billing 승격 정정 실행. Root cause: orchestrator treated "미룰 수 있으면 뒤로 미뤄" as licence to place domain-owned artifacts in the pages layer without surfacing the architecture rule conflict.
