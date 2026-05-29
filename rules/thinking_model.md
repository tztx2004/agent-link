# Thinking Model (Pre-Implementation Cognition Protocol)

## 1. Purpose

A six-stage cognitive workflow that every agent MUST apply **before and during implementation**. This file is the companion of `verification.md`:

- **`thinking_model.md`** (this file): _pre_-implementation cognition — how to read context, form hypotheses, analyze impact, and plan changes.
- **`verification.md`**: _post_-implementation audit — four-gate checks on the produced result.

The output of the final stage (REFLECT) becomes the input of Gate C in `verification.md`. The two protocols are sequential, not redundant.

## 2. The Six Stages

| Stage           | Question                                                                                                                      | Required Output                                                                                                                        |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **READ**        | Where is the existing implementation? Which files, types, hooks are involved?                                                 | A short list of files/symbols cited as `path:line`. No assumptions — only what was read.                                               |
| **REACT**       | Hypothesis: will this approach cause problems? _Intuition only — NOT a conclusion._                                           | An explicit, falsifiable hypothesis statement (e.g., "This change likely breaks the orders list because both depend on `useFilters`"). |
| **ANALYZE**     | What is the actual impact scope? Does the change touch other screens, contracts, or policies? Does the REACT hypothesis hold? | Impact list (files/modules affected) + verdict on the REACT hypothesis (confirmed / refuted / partial).                                |
| **RESTRUCTURE** | Is the same logic duplicated in 3+ places? Does the change warrant structural improvement rather than a local patch?          | Decision: `structural change needed: yes/no` with evidence (file count, duplication examples).                                         |
| **STRUCTURE**   | What is the concrete change plan? Have I decomposed it into small, reviewable units?                                          | A numbered plan, each step bounded (one file or one logical unit per step).                                                            |
| **REFLECT**     | Did I miss anything? Lint, type-check, test, build outputs.                                                                   | Captured command outputs. These artifacts feed Gate C of `verification.md`.                                                            |

## 3. Complexity-Based Application

Do not run stages the task does not require. Over-engineering simple work wastes context and time.

| Complexity | Criteria                                                         | Stages                                                  | Examples                                                          |
| ---------- | ---------------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------------- |
| **LOW**    | 1 file, clear modification, no logic branching                   | READ → REACT                                            | Typo fix, style touch-up, single constant change                  |
| **MEDIUM** | 2–5 files, follows an existing pattern                           | READ → ANALYZE → STRUCTURE → REFLECT                    | Add a component, write a hook, add a server action                |
| **HIGH**   | 5+ files, new architecture, or cross-domain (frontend + backend) | All six stages + delegate to a Plan agent for STRUCTURE | Domain refactor, new feature spanning layers, FSD layer migration |

## 4. Hard Rules

- **REACT is a hypothesis, not a conclusion.** Any decision derived from REACT alone is invalid until ANALYZE confirms or refutes it. Acting on raw intuition is forbidden.
- **No silent tier escalation.** If a task assigned as MEDIUM reveals HIGH-tier impact during ANALYZE, state the escalation explicitly and re-run from STRUCTURE with HIGH stages.
- **REFLECT outputs MUST be concrete artifacts** — captured command outputs, diffs, or screenshots. Narrative summaries ("looks fine", "should work") are forbidden and will fail Gate C.
- **No stage skipping inside an assigned tier.** Running only READ → STRUCTURE on a MEDIUM task is a protocol violation.
- **RESTRUCTURE returning `yes` cannot be deferred.** If duplication threshold is met, address it in STRUCTURE — do not file a TODO and move on.

## 5. Integration with `verification.md`

The protocols chain like this:

```
READ → REACT → ANALYZE → RESTRUCTURE → STRUCTURE → (Implement) → REFLECT → [4-Gate Audit] → Output
```

- **ANALYZE → Gate A & B**: the impact list and rule citations gathered here become the input for Requirement Alignment (A) and Rule Conformance (B).
- **REFLECT → Gate C**: captured command outputs are the evidence Gate C demands.
- **Gate failure routing**: a failed audit gate routes back to STRUCTURE for replan, not to READ. Re-reading is only required when ANALYZE was wrong (a Gate A failure).

## 6. Per-Agent Application

Each agent that performs implementation or planning MUST:

1. Load this file at session start alongside `core_rules.md` and `verification.md`.
2. Declare the assigned complexity tier (LOW/MEDIUM/HIGH) at the start of the task.
3. Run the stages required by that tier, emitting a short trace line per stage.
4. Hand REFLECT outputs to the four-gate audit.

Agents whose role is _post-hoc review only_ (e.g., `code-reviewer`, `qa-engineer`) MAY skip stages 1–5 and operate directly on the artifacts produced by an implementation agent, but MUST still verify that the implementation agent ran the protocol.
