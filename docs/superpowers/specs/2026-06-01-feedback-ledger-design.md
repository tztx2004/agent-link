# Feedback Ledger — Design Spec

**Date:** 2026-06-01
**Status:** Approved (pending implementation plan)
**Goal:** Prevent the agent team from repeating the same mistakes across sessions.

---

## 1. Problem

`agent-link` already has an **in-turn verification loop**: the four-gate self-audit
(`rules/verification.md`), the QA gate (`agents/qa-engineer.md`), and the
`QA FAIL → orchestrator → re-delegate` handoff loop (`protocols/handoff.md`).

What it lacks is a **cross-session feedback loop**. Every loop is stateless: when QA
fails and the team fixes it, the lesson lives only in the ephemeral ticket file and
evaporates when the session ends. The system has no way to know it made the same kind
of mistake yesterday. The primary pain to solve is therefore: **the same mistake
recurring across sessions** (rule violations, wrong patterns, choices the user has
already corrected).

This is explicitly **not** an "error log". A raw log of every failure becomes dead
noise. Instead we record _durable lessons_ — corrections and recurring failures that
will recur unless captured — and recall them at session start so they carry the force
of a rule.

## 2. Goals & Non-Goals

### Goals

- Capture durable lessons from **user corrections** and **recurring QA failures**.
- Recall relevant lessons at session start so every agent works aware of them.
- Keep the ledger inside `agent-link` and reference it by absolute path (`~/.config/agent-link/feedback/...`), exactly as `rules/` is referenced today — so it travels with the repo. (`install.sh` symlinks only `agents/` and `skills/`; `rules/` and `feedback/` are read by absolute path, not symlinked.)
- Keep signal high and noise low via a strict capture filter.
- Stay self-contained: depend on **no** agent or file outside `agent-link`.

### Non-Goals (deferred to later cycles)

- `CONTEXT.md` domain glossary (targets _misalignment_, a different axis).
- A full `docs/adr/` architecture-decision directory.
- `handoff` improvements (temp-dir storage, de-duplication).
- `triage` issue-tracker state machine (outside agent-link scope).

## 3. Key Decisions (from brainstorming)

| Decision        | Choice                                                  | Rationale                                                                                      |
| --------------- | ------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Primary pain    | Same mistake recurring                                  | Anchors scope to a feedback ledger                                                             |
| Ledger location | **Global**, inside `~/.config/agent-link/`              | Referenced by absolute path like `rules/`; travels with the repo; shared across all projects   |
| Capture trigger | **User correction + recurring QA FAIL (same gate ≥2×)** | Strongest signals; excludes one-off failures                                                   |
| Writer          | **New dedicated agent** in `agent-link/agents/`         | Self-contained; `~/.claude/agents/pm-agent.md` is NOT part of agent-link and would not install |
| Rule promotion  | **Propose only**, never auto-edit `rules/`              | Rule changes are a human-approval domain (mirrors ADR discipline)                              |

> **Note on pm-agent:** an earlier draft proposed reusing `pm-agent`. Investigation
> showed `~/.claude/agents/pm-agent.md` and `self-review.md` are independent
> user-level global agents, not symlinked from agent-link. Depending on them would
> break self-containment, so a new agent is authored inside agent-link instead.

## 4. Architecture & Data Flow

```
Session start
  └─ rules/ loaded  ──┬─ core_rules.md → thinking_model.md → verification.md
                      └─ feedback/INDEX.md   (NEW — one line per lesson)
                                 │
                                 ▼  every agent now aware of relevant lessons
Work loop:  orchestrator → impl → reviewer → qa-engineer
                                 │
              ┌──────────────────┴───────────────────┐
         QA PASS                               QA FAIL / user correction
              │                                       │
        (trigger met?)                   orchestrator delegates → retrospective
              └──────────────▶  retrospective agent  ◀──┘
                                 │ ① apply 3-part filter
                                 │ ② write/update lessons/*.md
                                 │ ③ update INDEX.md (one line)
                                 ▼
                       Recalled next session → recurrence blocked
```

The recall path is intentionally **isomorphic to the existing `MEMORY.md` pattern**
(one-line index → load body only when relevant) and follows mattpocock/skills'
lazy-file + index convention.

## 5. Components

### 5.1 `feedback/` directory (NEW)

```
~/.config/agent-link/feedback/
├── INDEX.md                 # one line per active lesson, loaded at session start
└── lessons/
    ├── .gitkeep
    └── <date>-<slug>.md     # one lesson per file, created lazily
```

**`INDEX.md`** — mirrors `MEMORY.md`; no bodies, scope visible for selective loading:

```markdown
# Learned Feedback Index

- [Hook이 raw setter 반환 금지](lessons/2026-06-01-hook-return-raw-setter.md) — [frontend] react_patterns §4 재발 2회
- [Next.js는 Server Component 우선](lessons/2026-06-01-server-component-default.md) — [frontend] 사용자 교정
```

**Lesson file format** — frontmatter + structured body:

```markdown
---
id: hook-return-raw-setter
trigger: recurring-qa-fail # user-correction | recurring-qa-fail
gate: B # which gate caught it (when applicable)
occurrences: 2
created: 2026-06-01
scope: frontend # frontend | backend | go | universal
status: active # active | retired
---

## 증상 (What went wrong)

훅이 useState의 setter를 그대로 반환해 호출부가 내부 구현에 결합됨.

## 교정 (Correct approach)

의미 있는 액션 함수로 감싸 반환. react_patterns §4.

## 적용 시점 (When to apply)

커스텀 훅 작성 시. frontend-developer / refactor 에이전트가 Gate B에서 확인.

## 근거 (Why) — 재발/교정 기록

- 2026-05-20 QA FAIL (TICKET-031)
- 2026-06-01 QA FAIL (TICKET-040) → 패턴화
```

Field roles:

- **`status: retired`** — when a lesson is promoted to a rule or no longer valid, mark
  retired and drop it from INDEX. Prevents unbounded growth.
- **`scope`** — controls recall cost. An agent working on frontend pulls only
  `scope: frontend | universal` bodies. Scope is visible in the INDEX line.
- **`occurrences`** — recurrence counter; ≥3 makes it a rule-promotion candidate.

### 5.2 `agents/retrospective.md` (NEW agent)

Persona-form agent following the existing 9-agent style. A _meta_ agent: it operates
on the team's mistake patterns, not on code. It is the only writer of `feedback/`.

Frontmatter (core):

```yaml
name: retrospective
description:
  Retrospective analyst. Extracts durable lessons from user corrections
  and recurring QA failures into the feedback ledger.
tools: [Read, Write, Edit, Glob, Grep, Skill]
model: sonnet
color: purple
```

Workflow:

1. **Input** (from orchestrator delegation): what happened (QA FAIL report or the
   verbatim user correction) + the relevant files/gate.
2. **Apply 3-part filter** (§5.3). If it fails, record nothing and return
   "skip — one-off". This is the noise gate.
3. **De-dup against `INDEX.md`**: if the lesson exists, `occurrences++` and append a
   line to the existing file's 근거 (no new file). Else create a new `lessons/*.md`
   lazily and add one INDEX line.
4. **Promotion proposal**: if `occurrences >= 3`, propose to the user (proposal only)
   that this be promoted into `rules/`. Never edit `rules/` directly.
5. Run its own four-gate self-audit (`verification.md`) before output.

### 5.3 Capture filter (3-part, applied by retrospective)

A correction/failure is recorded only if **all three** are true:

| Filter                     | Question                                         | Reject example                       |
| -------------------------- | ------------------------------------------------ | ------------------------------------ |
| **Generalizable**          | Will this recur in other tasks/files?            | one-line typo in this file           |
| **Recurs without context** | Would the agent re-make this choice if unstated? | something the linter already catches |
| **Clear correction**       | Can "next time do X" be written in one sentence? | vague "do better"                    |

Filter #2 is the signal/noise core: anything a tool (lint/type-check) mechanically
catches belongs to Gate C, not the ledger.

## 6. File Changes

| #   | File                                              | Change                                                                                                       |
| --- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| 1   | `agents/retrospective.md`                         | **NEW** — retrospective agent                                                                                |
| 2   | `feedback/INDEX.md` + `feedback/lessons/.gitkeep` | **NEW** — ledger scaffold                                                                                    |
| 3   | `rules/core_rules.md` §3                          | Load `feedback/INDEX.md` at session start                                                                    |
| 4   | `rules/verification.md` Gate B                    | Add "check INDEX for matching-scope lessons; pull body; confirm output complies" + define the record trigger |
| 5   | `agents/orchestrator.md`                          | Add retrospective to the delegation routing + add INDEX to Governing Rules load list                         |
| 6   | `protocols/handoff.md`                            | Add `QA-Engineer → retrospective` loop step                                                                  |

## 7. Borrowed from mattpocock/skills

**Adopted now:** lazy-file + INDEX pattern (from `grill-with-docs`/CONTEXT.md), the
3-part recording discipline (from ADR's 3-part test), the retrospective step (from
`diagnose` Phase 6 "what would have prevented this?"), propose-don't-auto-apply
promotion (from ADR's human-trade-off rule).

**Deferred:** CONTEXT.md glossary, full ADR directory, handoff improvements, triage
state machine — each is a separate axis; introducing all at once risks three
unmaintained dead documents. Land the ledger first, confirm `occurrences>=3`
promotion works in practice, then expand.

## 8. Success Criteria

- A user correction or a 2nd same-gate QA FAIL produces exactly one lesson entry
  (new file or `occurrences++`), and one-off failures produce none.
- At session start, agents load `INDEX.md` and, for matching scope, comply with the
  lesson body at Gate B.
- On a fresh machine (clone agent-link to `~/.config/agent-link` + run `install.sh`), agents reach the ledger by absolute path with no dependency outside the repo.
- `INDEX.md` stays bounded: retired/promoted lessons leave the index.
