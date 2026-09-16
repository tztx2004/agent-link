# Learned Feedback Index

> High-density summary of active lessons learned from past mistakes.
> Format: `- [title](lessons/<file>.md) — [scope] actionable rule`
> `scope`: frontend | backend | go | universal.
> When performing work in a relevant domain, follow these core guidelines. Full lesson bodies in `lessons/<file>.md` can be consulted on-demand for deep context.

- [Don't expand implementation approval into commit consent](lessons/2026-06-01-no-implicit-commit-on-proceed.md) — universal; "진행"/"proceed" grants code changes only; git commit·push only on explicit instruction
- [Lockfile-aware sweep glob for rename/identifier-migration tasks](lessons/2026-06-04-lockfile-aware-rename-sweep.md) — universal; enumerate all \*.lock files before delegation and include them in sweep grep glob
- [Selective code splitting: React.lazy only for heavy non-initial-render domains](lessons/2026-06-09-selective-code-splitting.md) — frontend; do not apply React.lazy to all routes; restrict to domains that are heavy AND not needed on initial render
- [Loading strategy: Suspense(Skeleton) for queries, mutateAsync for mutations](lessons/2026-06-09-loading-strategy-query-vs-suspense.md) — frontend; split loading UX by operation type — reads use Suspense+Skeleton, writes use TanStack Query mutateAsync with await
- [Deferral instruction must not silently violate architecture placement rules](lessons/2026-06-10-defer-instruction-must-not-silently-violate-arch-rules.md) — universal; "보류/미루기" instruction overrides scheduling only, not placement rules; surface the conflict or use a minimal rule-compliant skeleton
- [Copy replacement: confirm line-break for every responsive variant](lessons/2026-06-11-copy-replacement-confirm-linebreak-per-variant.md) — frontend; when replacing copy in mobile/desktop variant pairs, apply the intended line-break to all variants; do not inherit the existing variant's break pattern
- [API DTO schema must mirror server struct, not be inferred](lessons/2026-06-12-api-dto-must-mirror-server-struct.md) — frontend; read the Go response struct and json tags directly before writing any DTO schema; mocks must mirror actual wire shape, not the frontend schema
- [Governing rule change requires existing-code sweep](lessons/2026-06-17-governing-rule-change-requires-code-sweep.md) — universal; adding or strengthening a rule in any governing doc requires sweeping all code under that rule's scope; Gate C evidence must be "zero violations in sweep," not "formatter passed"
- [Self-audit is per-output, not per-session](lessons/2026-06-18-self-audit-per-output-not-per-session.md) — universal; emit [Self-Audit] block at bottom of code-modifying responses; pure Q&A and research turns are exempt
- [Docs-first workflow must precede implementation delegation](lessons/2026-07-22-docs-first-workflow-before-implementation.md) — universal; check AGENTS.md/CLAUDE.md for a docs-before-code order before delegating; write/confirm the Task doc first when the project mandates it
- [Verify target branch before commit — never commit directly to main](lessons/2026-07-22-verify-branch-before-commit.md) — universal; commit governance covers branch target too, not just message/content; check current branch and branch off default before `git commit`
