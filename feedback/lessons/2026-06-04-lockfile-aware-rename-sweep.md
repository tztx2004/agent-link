---
id: lockfile-aware-rename-sweep
trigger: recurring-qa-fail
gate: B
occurrences: 1
created: 2026-06-04
scope: universal
status: active
---

## Symptom (What went wrong)

During a rename/identifier-migration task, the sweep grep glob omitted `*.lock` extensions, leaving residual identifiers inside lockfiles (`package-lock.json`, `bun.lock`, etc.). Because the orchestrator's delegation prompt did not enumerate all lockfiles present in the repository, both the implementation agent and the reviewer shared the same blind spot — causing the same cohesion Gate B to fail twice on a single ticket.

## Correct approach

Before delegating a rename/identifier-migration task, the orchestrator must:

1. Run an explicit lockfile inventory (e.g., `find <repo> -maxdepth 3 \( -name "*.lock" -o -name "lockfile*" -o -name "Pipfile.lock" -o -name "poetry.lock" -o -name "go.sum" \)`) and list every discovered path in the delegation prompt.
2. Include `--include="*.lock"` (or equivalent glob `**/*.lock`) in the sweep grep that scans for the old identifier.
3. Never assume only one lockfile exists; confirm via actual `ls`/`find` output before delegation.
4. When a sweep returns zero matches, separately verify that the glob itself covers all relevant file types (i.e., distinguish "true zero" from "blind-spot zero").

## When to apply

The orchestrator, at delegation-prompt composition time, for any task that renames a package name, service identifier, image tag, or similar string that lockfiles may embed. Implementation agents should also self-check before reporting completion.

## Why (recurrence/correction log)

- 2026-06-04 QA FAIL ×2 (n3nai→n3n-ai rename ticket, Gate B — cohesion) — Pass 1: `package-lock.json` root `name` field left as `n3nai` because `*.lock` was absent from the sweep glob. Pass 2: `bun.lock` `workspaces[""].name` also left as `n3nai` because the delegation prompt named only `package-lock.json` and the repo's second lockfile was never discovered. Both the implementation agent and the reviewer shared the same blind spot across two full review rounds.
