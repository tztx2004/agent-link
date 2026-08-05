---
id: self-audit-per-output-not-per-session
trigger: user-correction
gate: B
occurrences: 1
created: 2026-06-18
scope: universal
status: active
---

## Symptom (What went wrong)

An orchestrator produced 7 user-facing responses in a single session but emitted the [Self-Audit] four-gate block only once, at the end of the session, as a retrospective summary. Individual responses — including read-only investigation turns — were not accompanied by an audit block. The root causes were two misclassifications: (1) treating the audit as a once-per-session ritual rather than a once-per-output requirement, and (2) treating "read-only / investigation responses" as internal exploratory steps exempt under verification.md §1 line 22.

## Correct approach

Emit the [Self-Audit] block with every user-facing response, without exception — printed at the **very bottom** of the output, after the response content (verification.md §1 Scope, §4 Audit Output Format, §5 Hard Prohibitions). The gates still RUN before the output is finalized; only the printed block sits last:

- **Output unit, not session unit.** A prior audit block in the same session does not satisfy the requirement for the current output. Gate values change turn-by-turn and cannot be reused.
- **Read-only responses are outputs.** Any response that contains verifiable assertions or corrects a prior statement is an output under §1 ("Any user-facing response from an agent"). The exemption for "internal exploratory reads or planning steps that do not produce an output" applies only to agent-internal steps that emit nothing to the user.
- **No silent skipping, no collapsing** (§5 Hard Prohibitions). Every gate must appear in the trace even when all pass trivially. If an environment limitation blocks a gate, state it explicitly in the block.

## When to apply

All orchestrator and sub-agent personas, on every turn that produces a user-facing message or a `<handoff>`. The check is: "Am I about to emit text the user will see?" — if yes, the [Self-Audit] block must accompany it, printed at the very bottom of that output.

## Why (recurrence/correction log)

- 2026-06-18 user correction: orchestrator emitted 7 user-facing responses in one session with [Self-Audit] only once (session-end retrospective). User said: "self-audit은 세션 단위가 아니라 출력(output) 단위다 — verification.md line 17 'Any user-facing response from an agent'가 scope. 같은 세션에서 한 번 했다고 이후 턴 생략 불가. Gate A/C/D는 턴마다 값이 바뀌어 재사용 불가." and "읽기 전용 조사 턴도 면제 아님" and "line 22 '내부 탐색(output 없는)' 면제를 과대적용하지 말 것 — 사용자에게 답을 내보내면 그게 output이다."
