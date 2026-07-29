---
id: verify-branch-before-commit
trigger: user-correction
gate: B
occurrences: 1
created: 2026-07-22
scope: universal
status: active
---

## Symptom (What went wrong)

The orchestrator created a docs-maintenance commit (5cef224, "SPEC: docs 인덱스 정비...") on the innowatch-demo repo with the user's approval of the commit _message and content_, but never checked which branch it landed on — the commit went directly onto `main`. A system instruction ("If on the default branch, branch first") existed, but no step in the commit-execution flow actually verified the current branch before running `git commit`.

## Correct approach

Commit Governance covers the target branch, not just the message/content. Immediately before executing `git commit`, run `git branch --show-current` (or equivalent) and check it against the repo's default branch (`main`/`master`). If on the default branch, create and switch to a task/feature branch first — do this even when the user has already approved the commit message and diff, since that approval does not cover the branch target. This is a distinct check from message/content approval and must not be skipped because content was approved. When a project's own convention doc (e.g. `docs/conventions.md`) states a no-direct-main-commit rule, that project rule additionally governs and must be honored.

## When to apply

Any agent (orchestrator or implementation agent) about to run `git commit`, at the moment just before execution — as part of Gate B (Rule Conformance) in `verification.md`, alongside message/content checks. Applies to every git-backed project, not specific to innowatch-demo.

## Why (recurrence/correction log)

- 2026-07-22 user correction on innowatch-demo: commit 5cef224 ("SPEC: docs 인덱스 정비...") was made directly on `main` despite content approval. User said: "main 브랜치에서 하면 안돼." Recovery: moved the commit to `docs/index-hub-reorg` and reset `main` to `origin/main` (safe because `origin/main` had not yet received the push). Root cause: commit governance gate checked message/content only, never the target branch, even though a system instruction to branch-first on default branch already existed.
