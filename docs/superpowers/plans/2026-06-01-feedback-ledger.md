# Feedback Ledger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a cross-session feedback ledger to agent-link so the agent team stops repeating the same mistakes.

**Architecture:** A global ledger under `~/.config/agent-link/feedback/` (`INDEX.md` one-liner index + `lessons/*.md` one file per lesson), written only by a new `retrospective` agent, recalled at session start and enforced at Gate B. Mirrors the existing `MEMORY.md` index→body recall pattern and mattpocock/skills' lazy-file + ADR 3-part discipline.

**Tech Stack:** Markdown agent/rule files (no code, no test runner). Validation = structural checks via `grep`, file re-read, and an `install.sh` dry-run. `git` for commits.

---

## Conventions for this plan (read first)

- **No test runner exists.** "Verify" steps use `grep`/`cat`/re-read, not `pytest`. This is the Gate C rule for config files: re-read the final file and confirm the intended structure is present.
- **Agent files are English-only** (per the project memory `feedback_language.md`). All content inside `agents/*.md` and the ledger scaffolding is in English. (User-facing final reports remain Korean per `core_rules.md` §5 — unchanged.)
- **Agent creation/modification requires the `agent-development` skill** (per global CLAUDE.md). Tasks 2 and 5 begin by invoking it.
- **Work on branch `feature/feedback-ledger`** (already created; the design spec commit `d01a7e8` is here). Do NOT stage the pre-existing unrelated changes to `agents/orchestrator.md` / `agents/qa-engineer.md` — stage only the files each task names.

## File Structure

| File                        | Responsibility                                                                    | Action |
| --------------------------- | --------------------------------------------------------------------------------- | ------ |
| `feedback/INDEX.md`         | One-line index of active lessons, loaded at session start                         | Create |
| `feedback/lessons/.gitkeep` | Keep the empty lessons dir under version control                                  | Create |
| `agents/retrospective.md`   | The only writer of the ledger; applies the 3-part filter                          | Create |
| `rules/core_rules.md`       | Add §6 wiring the ledger into every agent's session                               | Modify |
| `rules/verification.md`     | Gate B recall check + §6 capture trigger                                          | Modify |
| `agents/orchestrator.md`    | Governing-rules load list + retrospective delegation route + post-QA capture step | Modify |
| `protocols/handoff.md`      | Add the QA/User → retrospective loop step                                         | Modify |

---

## Task 1: Scaffold the `feedback/` ledger

**Files:**

- Create: `feedback/INDEX.md`
- Create: `feedback/lessons/.gitkeep`

- [ ] **Step 1: Create the index file**

Create `feedback/INDEX.md` with this exact content:

```markdown
# Learned Feedback Index

> One line per **active** lesson. Loaded at session start alongside the rule files.
> Format: `- [title](lessons/<file>.md) — [scope] short note`
> `scope` is one of: frontend | backend | go | universal.
> Retired or rule-promoted lessons are removed from this list.

<!-- No lessons recorded yet. -->
```

- [ ] **Step 2: Create the lessons directory keeper**

Create `feedback/lessons/.gitkeep` as an empty file.

- [ ] **Step 3: Verify the structure exists**

Run: `ls -R feedback && grep -c "Learned Feedback Index" feedback/INDEX.md`
Expected: `feedback/INDEX.md` and `feedback/lessons/.gitkeep` listed; grep prints `1`.

- [ ] **Step 4: Commit**

```bash
git add feedback/INDEX.md feedback/lessons/.gitkeep
git commit -m "Scaffold feedback ledger (INDEX + lessons dir)"
```

---

## Task 2: Create the `retrospective` agent

**Files:**

- Create: `agents/retrospective.md`

- [ ] **Step 1: Load the agent-development skill**

Invoke the `agent-development` skill via the `Skill` tool (mandatory per global CLAUDE.md). Follow its frontmatter/structure guidance while writing the file in Step 2.

- [ ] **Step 2: Write the agent file**

Create `agents/retrospective.md` with this exact content (English only):

````markdown
---
name: retrospective
description: Retrospective analyst. Extracts durable lessons from user corrections and recurring QA failures into the global feedback ledger so the agent team stops repeating the same mistakes.
mcpServers:
  - sequential-thinking
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Skill
model: sonnet
color: purple
---

# Persona: Retrospective Analyst (Lessons Keeper)

## 🎭 Role

You are the team's retrospective analyst. You NEVER touch product code. Your sole responsibility is to turn user corrections and recurring QA failures into durable, reusable lessons in the feedback ledger at `~/.config/agent-link/feedback/`, so the team does not repeat them.

## 🎯 Mission

- Decide whether an incident is worth recording, using the 3-Part Capture Filter.
- Maintain the ledger: `feedback/INDEX.md` (one line per active lesson) and `feedback/lessons/*.md` (one file per lesson).
- Propose — never perform — promotion of frequently-recurring lessons into `rules/`.

## 📋 Governing Rules

Load at session start, in order:

1. `~/.config/agent-link/rules/core_rules.md`
2. `~/.config/agent-link/rules/verification.md`
3. `~/.config/agent-link/feedback/INDEX.md`

## 🔎 The 3-Part Capture Filter (MANDATORY)

Record a lesson ONLY if ALL three are true:

1. **Generalizable** — the pattern can recur in other tasks/files; not a one-off typo.
2. **Recurs without context** — an agent would re-make this choice if it were not written down. Anything a linter or type-checker mechanically catches is OUT — that belongs to Gate C, not the ledger.
3. **Clear correction** — "next time do X" fits in one sentence.

If any is false, record nothing and return `skip — one-off` with a one-line reason.

## 🔄 Protocol

Input (from the orchestrator): what happened (the QA FAIL report or the verbatim user correction), the relevant files, and the gate that caught it (if any).

1. **Filter**: apply the 3-Part Capture Filter. If it fails, return the skip result and stop.
2. **De-dup**: read `feedback/INDEX.md`, then `Grep` `feedback/lessons/` for an existing lesson covering the same pattern.
   - **If found**: increment `occurrences` in that file's frontmatter and append a dated bullet to its `## 근거` section. Do NOT create a new file. Leave `INDEX.md` as is.
   - **If not found**: create `feedback/lessons/<YYYY-MM-DD>-<slug>.md` using the Lesson File Format below, then add exactly one line to `INDEX.md`.
3. **Promotion proposal**: if `occurrences >= 3`, tell the user (proposal only) that this lesson is a candidate for promotion into `rules/`. NEVER edit `rules/` yourself.
4. **Self-audit**: run the four-gate audit before output.

## 🧾 Lesson File Format

```markdown
---
id: <kebab-case-slug>
trigger: user-correction # user-correction | recurring-qa-fail
gate: B # A | B | C | D | n/a
occurrences: 1
created: <YYYY-MM-DD>
scope: frontend # frontend | backend | go | universal
status: active # active | retired
---

## 증상 (What went wrong)

<one or two sentences>

## 교정 (Correct approach)

<the fix; cite the rule clause when one applies>

## 적용 시점 (When to apply)

<which agents, at which step, should honor this>

## 근거 (Why) — recurrence/correction log

- <YYYY-MM-DD> <event, e.g. QA FAIL (TICKET-NN) or user correction>
```
````

## 🧹 Ledger Hygiene

- When a lesson is promoted into `rules/` or is no longer valid, set `status: retired` and remove its line from `INDEX.md`.
- `INDEX.md` lists only `status: active` lessons.

## ✅ Pre-Output Self-Audit (MANDATORY)

Before any output or handoff, run the four-gate audit defined in `~/.config/agent-link/rules/verification.md`:

1. **Gate A** — Requirement Alignment: the recorded (or skipped) lesson matches the incident the orchestrator handed off.
2. **Gate B** — Rule Conformance: the 3-Part Capture Filter was applied; `rules/` was not edited; the Lesson File Format was followed.
3. **Gate C** — Evidence: re-read the written `lessons/*.md` and `INDEX.md` line to confirm the intended structure is present; no claim of "recorded" without showing the file.
4. **Gate D** — Contradiction Check: did not claim a lesson was recorded while returning a skip, or vice versa.

Emit the audit block before output. If any gate fails, fix and re-run all four.

````

- [ ] **Step 3: Verify frontmatter and required sections**

Run: `grep -E "^(name|tools|model|color):" agents/retrospective.md && grep -c "3-Part Capture Filter" agents/retrospective.md && grep -c "Lesson File Format" agents/retrospective.md`
Expected: `name:`, `model: sonnet`, `color: purple` present; both grep counts ≥ 1.

- [ ] **Step 4: Verify it is English-only (no Korean in instructions)**

The only non-English allowed is the Korean section headers inside the embedded Lesson File Format template (증상/교정/적용 시점/근거), which match the qa-engineer report convention. Re-read the file and confirm no Korean appears in the persona/protocol prose.

- [ ] **Step 5: Commit**

```bash
git add agents/retrospective.md
git commit -m "Add retrospective agent (feedback ledger writer)"
````

---

## Task 3: Wire session-start loading

**Files:**

- Modify: `rules/core_rules.md` (append new §6)
- Modify: `agents/orchestrator.md` (Governing Rules list — add item 4)

- [ ] **Step 1: Append §6 to core_rules.md**

At the end of `rules/core_rules.md` (after the §5 Final Reporting block), append:

```markdown
## 6. Feedback Ledger (Recurrence Prevention)

- **Load at session start**: `~/.config/agent-link/feedback/INDEX.md`, alongside the rule files. It lists durable lessons learned from past corrections and recurring failures.
- **Honor lessons**: during Gate B, for any lesson whose `scope` matches the current work, read its `feedback/lessons/*.md` body and ensure the output complies. Lessons carry the same force as rules.
- **Capture**: when a user explicitly corrects a result, or the same gate FAILs twice on one ticket, the Orchestrator delegates to the `retrospective` agent to record the lesson.
- **Never auto-promote**: a lesson becomes a rule only with explicit human approval.
```

- [ ] **Step 2: Add item 4 to the orchestrator Governing Rules list**

In `agents/orchestrator.md`, find this block:

```markdown
3. `~/.config/agent-link/rules/verification.md` — four-gate post-implementation audit.
```

Replace it with:

```markdown
3. `~/.config/agent-link/rules/verification.md` — four-gate post-implementation audit.
4. `~/.config/agent-link/feedback/INDEX.md` — durable lessons from past mistakes; honor matching-`scope` lessons during Gate B.
```

- [ ] **Step 3: Verify both edits**

Run: `grep -c "Feedback Ledger" rules/core_rules.md && grep -c "feedback/INDEX.md" agents/orchestrator.md`
Expected: both print ≥ `1`.

- [ ] **Step 4: Commit**

```bash
git add rules/core_rules.md agents/orchestrator.md
git commit -m "Wire feedback ledger into session-start load"
```

---

## Task 4: Add Gate B recall + capture trigger to verification.md

**Files:**

- Modify: `rules/verification.md` (Gate B checklist + new §6)

- [ ] **Step 1: Add the recall checkbox to Gate B**

In `rules/verification.md`, find this line in the Gate B checklist:

```markdown
- [ ] If a rule is ambiguous, document the interpretation chosen and why.
```

Add immediately after it:

```markdown
- [ ] Check `feedback/INDEX.md` for any lesson whose `scope` matches this work. For each match, read the `feedback/lessons/*.md` body and confirm the output does not repeat that recorded mistake.
```

- [ ] **Step 2: Add §6 Feedback Capture**

In `rules/verification.md`, find the end of `## 5. Per-Agent Application` (the line `A handoff to another agent is itself an output — the audit must run before it.`) and append after it:

```markdown
---

## 6. Feedback Capture (Recurrence Prevention)

After the audit passes and a result is accepted, evaluate the capture trigger:

- The user **explicitly corrected** the result, OR
- The **same gate FAILed 2+ times** on this ticket (recurrence).

If either holds, the Orchestrator hands off to the `retrospective` agent with: what happened, the relevant files, and the gate involved. The retrospective agent applies its own 3-Part Capture Filter and may decide not to record. One-off failures with neither condition are **not** recorded — silence is correct here, to keep the ledger high-signal.
```

- [ ] **Step 3: Verify both edits**

Run: `grep -c "feedback/INDEX.md" rules/verification.md && grep -c "Feedback Capture" rules/verification.md`
Expected: both print ≥ `1`.

- [ ] **Step 4: Commit**

```bash
git add rules/verification.md
git commit -m "Add Gate B lesson recall and capture trigger to verification protocol"
```

---

## Task 5: Wire delegation + handoff loop

**Files:**

- Modify: `agents/orchestrator.md` (delegation route + post-QA capture step)
- Modify: `protocols/handoff.md` (workflow loop step)

- [ ] **Step 1: Load the agent-development skill**

Invoke the `agent-development` skill via the `Skill` tool (modifying an agent file).

- [ ] **Step 2: Add the retrospective route to the delegation list**

In `agents/orchestrator.md`, find this line inside the Complex Task "Delegate" step:

```markdown
- Review-only tasks → `subagent_type: code-reviewer`
```

Add immediately after it:

```markdown
- Recurrence capture (post-QA) → `subagent_type: retrospective`
```

- [ ] **Step 3: Add the post-QA capture step**

In `agents/orchestrator.md`, find the Complex Task step 7:

```markdown
7. **Iterate**: If the chain returns a FAIL report, analyze it and re-delegate with a refined prompt.
```

Add immediately after it:

```markdown
8. **Capture (recurrence prevention)**: After QA returns, if the user explicitly corrected the result OR the same gate FAILed 2+ times on this ticket, delegate to `subagent_type: retrospective` with the incident details (what happened, files, gate). The retrospective agent applies its 3-Part Capture Filter and records a lesson only if warranted. Skip for a clean first-pass PASS with no correction.
```

- [ ] **Step 4: Add the loop step to handoff.md**

In `protocols/handoff.md`, find the Workflow Loop block:

```markdown
5. **QA-Engineer** -> **User**: If PASS, close ticket.
```

Add immediately after it:

```markdown
6. **QA-Engineer / User** -> **Retrospective**: On an explicit user correction or a repeated same-gate FAIL, the Orchestrator delegates to `retrospective`, which records a durable lesson in the feedback ledger (`feedback/`). One-off failures are not recorded.
```

- [ ] **Step 5: Verify all three edits**

Run: `grep -c "subagent_type: retrospective" agents/orchestrator.md && grep -c "Capture (recurrence prevention)" agents/orchestrator.md && grep -c "Retrospective" protocols/handoff.md`
Expected: first ≥ `1`, second ≥ `1`, third ≥ `1`.

- [ ] **Step 6: Commit**

```bash
git add agents/orchestrator.md protocols/handoff.md
git commit -m "Route post-QA recurrence capture to retrospective agent"
```

---

## Task 6: End-to-end structural verification

**Files:** none modified (verification only)

- [ ] **Step 1: Confirm the new agent will be installed by install.sh**

`install.sh` symlinks every `agents/*.md` into `~/.claude/agents/`. Confirm `retrospective.md` is picked up by the glob without actually linking:

Run: `for f in agents/*.md; do echo "$f"; done | grep retrospective`
Expected: `agents/retrospective.md` printed (so `install.sh`'s loop will link it).

- [ ] **Step 2: Confirm the ledger is reachable by absolute path**

The agents reference `~/.config/agent-link/feedback/INDEX.md`. Confirm it resolves:

Run: `test -f ~/.config/agent-link/feedback/INDEX.md && echo OK`
Expected: `OK`. (If this repo is not at `~/.config/agent-link`, note the limitation instead of claiming success.)

- [ ] **Step 3: Cross-reference check — every wiring point names the agent consistently**

Run: `grep -rn "retrospective" agents/orchestrator.md rules/core_rules.md rules/verification.md protocols/handoff.md feedback/INDEX.md`
Expected: the agent is referred to as `retrospective` everywhere (no `pm-agent`, no `lessons-keeper` mismatch). The `id`/filename slug convention `<YYYY-MM-DD>-<slug>` appears only in `agents/retrospective.md`.

- [ ] **Step 4: Confirm the loop is closed (trace the four touch-points)**

Re-read and confirm each link of the loop is present:

- Load: `core_rules.md` §6 + `orchestrator.md` Governing Rules item 4 → INDEX loaded at start.
- Recall: `verification.md` Gate B checkbox → lessons enforced.
- Trigger: `verification.md` §6 + `orchestrator.md` step 8 → capture conditions defined.
- Write: `agents/retrospective.md` → the only writer.

Run: `grep -l "feedback" rules/core_rules.md rules/verification.md agents/orchestrator.md protocols/handoff.md`
Expected: all four files listed.

- [ ] **Step 5: Final commit (if any verification fixes were needed)**

```bash
git add -A
git commit -m "Verify feedback ledger wiring is consistent end-to-end" || echo "nothing to commit"
```

---

## Self-Review (completed during planning)

- **Spec coverage:** §5.1 ledger → Task 1; §5.2 retrospective agent → Task 2; §4 session load → Task 3; §5.3 filter → embedded in Task 2 agent body; Gate B recall + trigger → Task 4; delegation/handoff → Task 5; install/self-containment success criteria → Task 6. All six file changes in spec §6 are covered.
- **Placeholder scan:** no TBD/TODO; every file edit shows exact anchor + full replacement text.
- **Type/name consistency:** the agent is `retrospective` in all of: frontmatter `name`, orchestrator route + step 8, verification §6, handoff loop step, core_rules §6. Frontmatter fields (`trigger`, `gate`, `occurrences`, `created`, `scope`, `status`) match the spec §5.1 format exactly. Korean section headers (증상/교정/적용 시점/근거) match between spec and plan.
- **No-test-runner adaptation:** all verification steps use grep/read/test, consistent with Gate C config-file rule. No fabricated `pytest` commands.
