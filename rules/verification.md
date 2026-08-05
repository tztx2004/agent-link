# Verification Protocol (Constitutional Self-Audit)

Every agent MUST run this protocol **after producing an internal result and before emitting any output, handoff, or completion claim**. The workflow is:

```
Think → Implement/Result → VERIFY (this protocol) → Output
```

This is non-negotiable. If an audit gate fails, **fix the output first, then re-run the audit** — do not bypass it, do not weaken the rule.

---

## 1. Scope

This protocol applies to:

- Any user-facing response from an agent
- Any `<handoff>` to another agent
- Any code edit, file write, or shell command sequence that produces a result
- Any "task complete" / "fixed" / "passing" claim

It does NOT apply to internal exploratory reads or planning steps that do not produce an output.

---

## 2. The Two Audit Gates

Run each gate in order. Each gate must produce an explicit ✓ or ✗ in your reasoning trace. Do not collapse the two gates into a single judgment.

Both surviving gates are **externally grounded**: each one is discharged by opening a file, citing a clause, or running a command — never by re-reading your own output and judging it. That is the whole design. Anything you can satisfy by thinking harder about what you already wrote does not belong here.

### Gate B — Rule Conformance (규칙 검증)

Verify the result complies with every rule that governs this agent and this file type.

- [ ] List the rule files I loaded this turn (e.g., `core_rules.md`, `react_patterns.md`, `style_guidelines.md`, `tanstack_query.md`, agent-specific rules in frontmatter).
- [ ] For each rule that touches the changed code, cite the specific clause and confirm the output complies.
- [ ] For each mandatory skill listed in the agent's frontmatter, confirm it was invoked at the required step.
- [ ] If a rule is ambiguous, document the interpretation chosen and why.
- [ ] Load `feedback/INDEX.md` if not already loaded. List EVERY lesson whose `scope` matches this work (include `universal` always). The INDEX one-liner is a lossy pointer, **not** a substitute for the lesson — for EACH match you MUST **open and read the full `feedback/lessons/<file>.md` body** and cite the body file path you opened in your audit. Confirm the output does not repeat the recorded mistake.

**Fail conditions:** a governing rule was not loaded; a loaded rule is violated by the output; **or** a scope-matching lesson was complied with / cited from the INDEX summary alone without its `lessons/<file>.md` body being opened and cited.

### Gate C — Evidence (결과 검증)

Verify the result actually works. No success claim without artifacts.

- [ ] For code changes: run the relevant verification command and capture output.
  - TypeScript: `npx tsc --noEmit`
  - Lint: `npx eslint <changed-files>`
  - Tests: project test command
  - Build: project build command (when changes plausibly affect build)
- [ ] For UI changes: produce a screenshot or browser-driven verification when feasible.
- [ ] For configuration / rules / agent files: re-read the final file and confirm intended structure is present.
- [ ] **Audit every progress or completion claim against a tool result from this session.** Report only work you can point to evidence for; where something is not yet verified, say so explicitly rather than implying it passed.
- [ ] When a governing rule was added or strengthened, the evidence is a **sweep of the code under that rule's scope** — "zero violations across the files checked", citing them — not a formatter or linter pass.
- [ ] If verification is not possible in this environment, state the limitation explicitly — do NOT claim success.

**Fail condition:** any "it works" / "tests pass" / "build succeeds" claim is made without showing the command and its output.

---

## 3. Retired gates (A and D)

This protocol previously ran four gates. **Gate A (Requirement Alignment) and Gate D (Contradiction Check) were retired** — both asked the model to re-read its own output and judge it, with no external artifact involved.

Anthropic's Claude Opus 5 guidance is explicit that this scaffolding is now counterproductive: the model verifies its own work unprompted, and instructions telling it to verify cause over-verification, so _"removing them reduces over-verification with no capability regression — this is a delete, not a rewrite,"_ and _"the same applies to harness-level scaffolding."_ Independent research agrees that self-correction without an external signal yields limited and inconsistent gains.

Letters **B and C were deliberately not renumbered** so existing references stay valid. Lessons in `feedback/lessons/` carrying `gate: A` or `gate: D` in their frontmatter are accurate historical records of when the failure occurred; read them normally — their substance now lands under Gate B or Gate C.

---

## 4. Audit Output Format

Run both gates **before finalizing** the output — problems must be found and fixed before anything is emitted. Verification always happens first; only the **printed block's position** changes.

Place the `[Self-Audit]` block at the **very bottom of the output** — it is the LAST element the reader sees, printed _after_ the user-facing response (or after the `<handoff>` payload, PASS/FAIL, or APPROVE/REJECT decision). Keep it terse — one line per gate.

```
[Self-Audit]
  B. Rule conformance: ✓ (core_rules §2, react_patterns §0, §4; lessons read: lessons/2026-06-09-selective-code-splitting.md ✓ complied)
  C. Evidence:         ✓ (tsc --noEmit OK, eslint clean)
```

If a gate fails, the block becomes a remediation log:

```
[Self-Audit]
  B. ✗ — react_patterns §4 violated: hook returns raw setter. Fixing.
  → Re-running audit after fix.
```

After remediation, re-run **both** gates — not just the failed one. Fixes can introduce new violations elsewhere.

---

## 5. Hard Prohibitions

- **No silent skipping.** If an environment limitation prevents a gate (e.g., no test runner available), state it explicitly in the audit block.
- **No rule rewriting to pass the audit.** Rules in `rules/` and skill files are immutable during a task. If a rule seems wrong, finish the task as-is and flag the rule in the final report.
- **No partial completion claims.** "Mostly works" / "should work" / "looks correct" are forbidden. Either evidence shows it works, or you state it does not.
- **No collapsing the audit.** Both gates must appear in the trace, even if both pass trivially.

---

## 6. Feedback Capture (Recurrence Prevention)

After the audit passes and a result is accepted, evaluate the capture trigger:

- The user **explicitly corrected** the result, OR
- The **same gate FAILed 2+ times** on this ticket (recurrence).

If either holds, the Orchestrator hands off to the `retrospective` agent with: what happened, the relevant files, and the gate involved. The retrospective agent applies its own 3-Part Capture Filter and may decide not to record. One-off failures with neither condition are **not** recorded — silence is correct here, to keep the ledger high-signal.
