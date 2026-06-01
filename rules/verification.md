# Verification Protocol (Constitutional Self-Audit)

Every agent MUST run this protocol **after producing an internal result and before emitting any output, handoff, or completion claim**. The workflow is:

```
Think → Implement/Result → VERIFY (this protocol) → Output
```

This is non-negotiable. If any audit gate fails, **fix the output first, then re-run the audit** — do not bypass it, do not weaken the rule.

---

## 1. Scope

This protocol applies to:

- Any user-facing response from an agent
- Any `<handoff>` to another agent
- Any code edit, file write, or shell command sequence that produces a result
- Any "task complete" / "fixed" / "passing" claim

It does NOT apply to internal exploratory reads or planning steps that do not produce an output.

---

## 2. The Four Audit Gates

Run each gate in order. Each gate must produce an explicit ✓ or ✗ in your reasoning trace. Do not collapse multiple gates into a single judgment.

### Gate A — Requirement Alignment (사고 검증)

Verify the plan and result match what the user actually asked for.

- [ ] Restate the user's original request in one sentence.
- [ ] List every explicit ask (verbs, deliverables, constraints) → mark each ✓ addressed / ✗ missed.
- [ ] Did I add scope the user did not request? If yes, remove it before output.
- [ ] Did I drop scope the user did request? If yes, complete it before output.

**Fail condition:** any explicit ask is ✗ or unverified.

### Gate B — Rule Conformance (규칙 검증)

Verify the result complies with every rule that governs this agent and this file type.

- [ ] List the rule files I loaded this turn (e.g., `core_rules.md`, `react_patterns.md`, `style_guidelines.md`, `tanstack_query.md`, agent-specific rules in frontmatter).
- [ ] For each rule that touches the changed code, cite the specific clause and confirm the output complies.
- [ ] For each mandatory skill listed in the agent's frontmatter, confirm it was invoked at the required step.
- [ ] If a rule is ambiguous, document the interpretation chosen and why.
- [ ] Load `feedback/INDEX.md` if not already loaded, then check it for any lesson whose `scope` matches this work. For each match, read the `feedback/lessons/*.md` body and confirm the output does not repeat that recorded mistake.

**Fail condition:** a governing rule was not loaded, or a loaded rule is violated by the output.

### Gate C — Evidence (결과 검증)

Verify the result actually works. No success claim without artifacts.

- [ ] For code changes: run the relevant verification command and capture output.
  - TypeScript: `npx tsc --noEmit`
  - Lint: `npx eslint <changed-files>`
  - Tests: project test command
  - Build: project build command (when changes plausibly affect build)
- [ ] For UI changes: produce a screenshot or browser-driven verification when feasible.
- [ ] For configuration / rules / agent files: re-read the final file and confirm intended structure is present.
- [ ] If verification is not possible in this environment, state the limitation explicitly — do NOT claim success.

**Fail condition:** any "it works" / "tests pass" / "build succeeds" claim is made without showing the command and its output.

### Gate D — Contradiction Check (자기모순 검열)

Verify the output is internally consistent and does not contradict the rules it claims to follow.

- [ ] Re-read the final output as if seeing it for the first time.
- [ ] Compare each non-trivial decision against the rules cited in Gate B. Any contradiction?
- [ ] Compare against the agent's own prior statements this turn. Did I assert X early then do ¬X?
- [ ] If a contradiction exists, **fix the output, not the rule.** Rules are immutable for this turn.

**Fail condition:** the output contradicts a cited rule, an earlier assertion, or itself.

---

## 3. Audit Output Format

Before producing the final user-facing response or `<handoff>`, emit a short audit block. Keep it terse — one line per gate.

```
[Self-Audit]
  A. Requirement alignment: ✓ (all 3 asks addressed: X, Y, Z)
  B. Rule conformance:      ✓ (core_rules §2, react_patterns §0, §4)
  C. Evidence:              ✓ (tsc --noEmit OK, eslint clean)
  D. Contradiction check:   ✓ (none)
```

If any gate fails, the block becomes a remediation log:

```
[Self-Audit]
  A. ✓
  B. ✗ — react_patterns §4 violated: hook returns raw setter. Fixing.
  → Re-running audit after fix.
```

After remediation, re-run **every** gate from A — not just the failed one. Fixes can introduce new violations elsewhere.

---

## 4. Hard Prohibitions

- **No silent skipping.** If an environment limitation prevents a gate (e.g., no test runner available), state it explicitly in the audit block.
- **No rule rewriting to pass the audit.** Rules in `rules/` and skill files are immutable during a task. If a rule seems wrong, finish the task as-is and flag the rule in the final report.
- **No partial completion claims.** "Mostly works" / "should work" / "looks correct" are forbidden. Either evidence shows it works, or you state it does not.
- **No collapsing the audit.** All four gates must appear in the trace, even if all pass trivially.

---

## 5. Per-Agent Application

Each agent file references this protocol in its workflow. The reference is mandatory and must appear as the **last step before any output or handoff** in the agent's defined workflow.

The agent must:

1. Load this file at session start (alongside other rules).
2. Run the four gates after every result-producing step.
3. Emit the audit block immediately before final output or handoff.

A handoff to another agent is itself an output — the audit must run before it.

---

## 6. Feedback Capture (Recurrence Prevention)

After the audit passes and a result is accepted, evaluate the capture trigger:

- The user **explicitly corrected** the result, OR
- The **same gate FAILed 2+ times** on this ticket (recurrence).

If either holds, the Orchestrator hands off to the `retrospective` agent with: what happened, the relevant files, and the gate involved. The retrospective agent applies its own 3-Part Capture Filter and may decide not to record. One-off failures with neither condition are **not** recorded — silence is correct here, to keep the ledger high-signal.
