---
id: api-dto-must-mirror-server-struct
trigger: user-correction
gate: C
occurrences: 1
created: 2026-06-12
scope: frontend
status: active
---

## Symptom (What went wrong)

A frontend developer wrote a DTO schema by guessing the server response shape (`{id, name}`) without reading the actual Go handler struct. The real wire format was nested (`{postgres_type: {id}, sku: {name, code}}`). Because the Zod schema declared every field as optional, parsing succeeded silently with all values undefined, triggering a "no options → fallback to text input" path. Test mocks were built from the same incorrect assumption, making the suite self-consistent — implementation, code review, and QA all passed while the feature was completely non-functional. (T-PROT-098)

## Correct approach

Before writing any API integration DTO schema: (1) directly `Read` the server-side Go response struct and cross-reference every `json` tag; (2) if a legacy consumer exists, read its mapping as an additional cross-check; (3) write test mocks that mirror the actual server response structure — never derive mocks from the frontend schema. Avoid all-optional Zod schemas for catalog-type endpoints; require at least the key identifier fields so that a wire mismatch surfaces as a parse error or an empty validated result that is explicitly handled.

## When to apply

Frontend developer agent, at the step of writing or updating any DTO/schema for a backend API endpoint. Code reviewer agent, when reviewing any new `*.schemas.ts` or Zod schema file — confirm the shape was verified against a server struct, not inferred. QA engineer agent, when writing mocks for catalog-type or select-option endpoints — confirm the mock shape matches the actual wire format, not the frontend schema.

## Why (recurrence/correction log)

- 2026-06-12 user correction: T-PROT-098 web postgres catalog select integration — code reviewed PASS and QA passed 44/44 tests, but the feature was non-functional in the real UI because the DTO schema assumed a flat structure while the actual wire was nested. The user confirmed the defect by checking the real screen. "postgres 타입이 여전히 텍스트 입력"
