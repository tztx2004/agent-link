# Learned Feedback Index

> One line per **active** lesson. Loaded at session start alongside the rule files.
> Format: `- [title](lessons/<file>.md) — [scope] short note`
> `scope` is one of: frontend | backend | go | universal.
> Retired or rule-promoted lessons are removed from this list.

> ⚠️ **MANDATORY — the one-line note is a lossy POINTER, not the lesson.**
> It exists only to let you triage by `scope`. It is intentionally incomplete and
> MUST NOT be acted on, cited, or "complied with" on its own.
> Before Gate B can pass you MUST **open and read the full `lessons/<file>.md` body**
> for EVERY lesson whose `scope` matches the current work, and record each body file
> path you opened in your Gate B audit line. Complying with — or citing — a lesson
> from this index summary alone is a **Gate B FAILURE**. (See `rules/verification.md` Gate B.)

- [Don't expand implementation approval into commit consent](lessons/2026-06-01-no-implicit-commit-on-proceed.md) — universal; "진행"/"proceed" grants code changes only; git commit·push only on explicit instruction
- [Lockfile-aware sweep glob for rename/identifier-migration tasks](lessons/2026-06-04-lockfile-aware-rename-sweep.md) — universal; enumerate all \*.lock files before delegation and include them in sweep grep glob
- [Selective code splitting: React.lazy only for heavy non-initial-render domains](lessons/2026-06-09-selective-code-splitting.md) — frontend; do not apply React.lazy to all routes; restrict to domains that are heavy AND not needed on initial render
- [Loading strategy: Suspense(Skeleton) for queries, mutateAsync for mutations](lessons/2026-06-09-loading-strategy-query-vs-suspense.md) — frontend; split loading UX by operation type — reads use Suspense+Skeleton, writes use TanStack Query mutateAsync with await
- [Deferral instruction must not silently violate architecture placement rules](lessons/2026-06-10-defer-instruction-must-not-silently-violate-arch-rules.md) — universal; "보류/미루기" instruction overrides scheduling only, not placement rules; surface the conflict or use a minimal rule-compliant skeleton
- [Copy replacement: confirm line-break for every responsive variant](lessons/2026-06-11-copy-replacement-confirm-linebreak-per-variant.md) — frontend; when replacing copy in mobile/desktop variant pairs, apply the intended line-break to all variants; do not inherit the existing variant's break pattern
- [API DTO schema must mirror server struct, not be inferred](lessons/2026-06-12-api-dto-must-mirror-server-struct.md) — frontend; read the Go response struct and json tags directly before writing any DTO schema; mocks must mirror actual wire shape, not the frontend schema
- [Governing rule change requires existing-code sweep](lessons/2026-06-17-governing-rule-change-requires-code-sweep.md) — universal; adding or strengthening a rule in any governing doc requires sweeping all code under that rule's scope; Gate C evidence must be "zero violations in sweep," not "formatter passed"
- [Self-audit is per-output, not per-session](lessons/2026-06-18-self-audit-per-output-not-per-session.md) — universal; emit [Self-Audit] block at the very bottom of every user-facing response; prior audit in same session does not satisfy current turn; read-only responses are outputs
