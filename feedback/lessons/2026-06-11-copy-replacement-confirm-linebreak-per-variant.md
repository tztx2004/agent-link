---
id: copy-replacement-confirm-linebreak-per-variant
trigger: user-correction
gate: B
occurrences: 1
created: 2026-06-11
scope: frontend
status: active
---

## Symptom (What went wrong)

When replacing marketing copy in a component that has mobile/desktop variant pairs (e.g., `subOverride` / `subDesktopOverride`), the agent followed the existing desktop pattern of having no line-break (`\n`), and did not apply the intended line-break of the new copy to the desktop variant. This caused the desktop rendering to omit the author-intended break point.

## Correct approach

When replacing copy text, do not inherit the existing variant's line-break pattern. Instead, apply the requested line-break position to ALL variants (mobile and desktop) uniformly, or explicitly confirm each variant's break point with the user before writing.

## When to apply

Frontend agents replacing any text content (marketing copy, headings, body text) in components that expose mobile/desktop (or any responsive) variant pairs — at the point of writing each variant string.

## Why (recurrence/correction log)

- 2026-06-11 user correction (Draft20Page.tsx line 97 — `subDesktopOverride`): "데스크톱도 '~으로'에서 줄바꿈되어야 한다"
