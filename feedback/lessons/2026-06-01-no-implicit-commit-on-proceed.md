---
id: no-implicit-commit-on-proceed
trigger: user-correction
gate: n/a
occurrences: 1
created: 2026-06-01
scope: universal
status: active
---

## Symptom (What went wrong)

The agent over-interpreted implementation-approval utterances (e.g. "진행해보자", "권장방향대로 해줘", "proceed", "착수") as also granting consent for `git commit` and `git push`, and automatically ran `git commit` and flipped the doc status to Done without any explicit commit instruction. The same over-interpretation occurred when the user selected an item from an agent-defined option menu (e.g. "option b = fix immediately with a TINY commit") — the option selection was treated as commit consent.

## Correct approach

An "approve / proceed with implementation" utterance grants authority only up to writing or modifying code. `git commit`, `git push`, and doc-status changes are performed only when, in that same turn, the user explicitly says e.g. "커밋해", "push해", "별도 커밋", or "완료 처리해줘". Even if an agent-defined option implies a commit, the user's selection of that option is NOT treated as commit consent without separate explicit confirmation. Default behavior after finishing implementation: leave changes in the working tree, report the results, and ask separately whether to commit.

## When to apply

Every agent that performs implementation (especially the orchestrator and implementation agents). Right before entering any commit / push / status-change step after a code change, check each time: "Was there an explicit commit instruction in this turn?" — if not, leave changes in the working tree, report, and ask.

## Why (recurrence/correction log)

- 2026-06-01 user correction — on jikji-cloud T-OBJ-010, after finishing implementation, `git commit` was run and the docs status was changed to Done without the user's permission. User said: "커밋을 허락하지 않았는데 왜 진행한거지?" Violated harness rule: "Commit or push only when the user asks".
