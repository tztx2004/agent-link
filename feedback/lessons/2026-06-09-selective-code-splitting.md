---
id: selective-code-splitting
trigger: user-correction
gate: A
occurrences: 1
created: 2026-06-09
scope: frontend
status: active
---

## Symptom (What went wrong)

When planning FSD route architecture tasks, the agent applied `React.lazy` universally — one domain = one chunk — citing `bundle-dynamic-imports` best practices. The referenced rule actually restricts lazy loading to components "not needed on initial render," making blanket application a misreading of the rule.

## Correct approach

Apply `React.lazy` only to domains or routes that are both heavy AND not required on initial render. Keep statically imported routes for entry-point paths and lightweight domains. Cite `bundle-dynamic-imports` only when this condition is met; do not infer "all routes" from it.

## When to apply

Any agent writing or reviewing Task definitions, architecture plans, or router configuration in a Vite/React SPA — at the planning stage (before implementation) and during Task spec review.

## Why (recurrence/correction log)

- 2026-06-09 user correction on T-PROT-090 (jikji-cloud `web/`): the agent wrote "중앙 라우터에서 모든 도메인을 `React.lazy`로 분리, 도메인 1개=chunk 1개" as the blanket strategy. User clarified: "React.lazy(코드 분할)는 필요한 곳(초기 렌더에 불필요한 무거운/지연 도메인)에만 선별 적용하고 무조건 사용하지 않는다."
