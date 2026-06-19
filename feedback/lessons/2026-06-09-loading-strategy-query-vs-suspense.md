---
id: loading-strategy-query-vs-suspense
trigger: user-correction
gate: A
occurrences: 1
created: 2026-06-09
scope: frontend
status: active
---

## Symptom (What went wrong)

When specifying loading/pending UX in Task definitions, the agent conflated all loading states under "Suspense + Toast," without distinguishing between read (query) and write (mutation) operations. This produces inconsistent UX and misuses both Suspense and TanStack Query mutation APIs.

## Correct approach

Split loading handling by operation type:

- **Read (query)**: use `Suspense` with a `Skeleton` fallback.
- **Write (mutation)**: use TanStack Query `mutateAsync` with `await` to manage submission and loading state inline; do not rely on Suspense for this path.

## When to apply

Any agent writing Task specs, component plans, or data-fetching implementations for a TanStack Query + React frontend — at the point where loading/pending UX is described or implemented.

## Why (recurrence/correction log)

- 2026-06-09 user correction on T-PROT-092 (jikji-cloud `web/`): the agent described loading handling only as "Suspense + Toast." User clarified: "로딩 처리는 조회=`Suspense`(Skeleton), mutation=TanStack Query `mutateAsync`(await로 제출/로딩 상태 처리)로 일원화."
