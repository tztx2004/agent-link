---
id: governing-rule-change-requires-code-sweep
trigger: user-correction
gate: D
occurrences: 1
created: 2026-06-17
scope: universal
status: active
---

## Symptom (What went wrong)

An orchestrator added a quantitative threshold rule for `React.lazy` to `web/.claude/architecture.md` (e.g., "lazy only when gzip ≥ 10 kB or heavy dependency AND not initial-render"). The change was classified as a Simple-Task Exception and Gate C evidence was satisfied by a formatter pass alone. No sweep of existing `app/router.tsx` was performed. Multiple existing lazy declarations (gzip 1.5–5.5 kB lightweight pages) immediately violated the new rule, but the violation went undetected until a separate review agent ran a full build-chunk audit.

## Correct approach

Whenever a governing document (architecture rules, code conventions, policy docs) receives a new rule or a rule is strengthened, treat it as a code-impacting change, not a documentation edit:

1. After writing the rule, enumerate every file in scope (router config, component index, etc.) and verify each against the new rule.
2. For each violation found, either fix it in the same task OR create an explicit follow-up task and leave a `# TODO(rule-sweep):` comment in the governing doc until it is resolved.
3. Gate C evidence must be "zero violations found in sweep" (cite the files checked), not "formatter passed." Gate D must confirm no new rule contradicts the current state of the codebase.

Classifying a governing-rule addition as a Simple-Task Exception is only valid when the rule changes nothing about existing code (e.g., pure documentation of an already-enforced invariant). When in doubt, delegate to an implementation agent and require a sweep report.

## When to apply

Orchestrator and architecture/plan agents at the step of editing any governing document in `*.claude/`, `docs/`, or `rules/`. Also applies to any implementation agent that self-edits a policy file as a side effect of a larger task.

## Why (recurrence/correction log)

- 2026-06-17 user correction (jikji-cloud `web/`): Orchestrator added a `React.lazy` quantitative threshold rule to `web/.claude/architecture.md` via Simple-Task Exception, verified only with `prettier --check`. A downstream review agent found multiple `app/router.tsx` lazy declarations (1.5–5.5 kB chunks) immediately violated the new rule. User: "넌 왜 못잡았지"
