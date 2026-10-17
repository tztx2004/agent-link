# Verification Protocol (Evidence-Based)

Before any code-modifying output, handoff, or completion claim, check the result against the two gates below.

```
Think → Implement/Result → VERIFY (this protocol) → Output
```

If a gate fails, fix the output and check again rather than weakening the rule.

---

## 1. Scope

This protocol applies to:

- Any code edit, file write, or configuration change producing modified artifacts
- Any `<handoff>` to an implementation or verification agent
- Any completion claim ("task complete", "fixed", "passing")

It does not apply to pure Q&A, explanations, investigations, read-only research, or planning turns where no code or file was modified.

---

## 2. The Two Gates

### Gate B — Rule Conformance (규칙 검증)

The output complies with the project's governing rules, architecture patterns, and technical standards.

- Standard compliance (Next.js/React patterns, Go idioms in `golang_standards.md`, security rules).
- **Skill Grounding (Antigravity CLI only — ignore in Claude Code and Codex)**: When working in a domain with an available skill, confirm that `SKILL.md` was actively loaded via `view_file` during this session instead of guessing from parametric memory.
- Relevant lessons in `feedback/INDEX.md` when touching risk areas. (Full lesson bodies are consulted on-demand when relevant, not read all at once).

**Fail condition:** a governing rule is violated by the output without a stated rationale.

### Gate C — Evidence (결과 검증)

The result actually works. No success claim without artifacts.

- For code changes, run the relevant verification command:
  - TypeScript / Frontend: `npx tsc --noEmit`
  - Go Backend: `go vet ./...` and `go test -v -race ./...` (or target package)
  - Lint: `npx eslint <changed-files>` or `golangci-lint run`
  - Tests: project test command
  - Build: project build command (when changes plausibly affect build)
- For UI changes: produce a screenshot or browser-driven verification when feasible.
- For configuration / rules / agent files: re-read the final file and confirm intended structure is present.
- Report only work you can point to evidence for; where something is not yet verified, say so explicitly rather than implying it passed.
- Any list of changed files you report comes from `git diff --name-only` (or `git status --short`), not from memory. Recalled lists run short in long tasks.
- When a governing rule was added or strengthened, the evidence is a sweep of the code under that rule's scope — "zero violations across the files checked", citing them — not a formatter or linter pass.
- If verification is not possible in this environment, state the limitation — do not claim success.

**Fail condition:** any "it works" / "tests pass" / "build succeeds" claim is made without the command that showed it.

---

## 3. Retired gates (A and D)

This protocol previously ran four gates. **Gate A (Requirement Alignment) and Gate D (Contradiction Check) were retired** — both asked the model to re-read its own output and judge it, with no external artifact involved.

Anthropic's prompting guidance for current models is explicit that this scaffolding is now counterproductive: the model verifies its own work unprompted, and verification instructions carried over from earlier models cause over-verification. The same reasoning retired the mandatory `[Self-Audit]` block: printing a per-gate checklist on every output spent tokens without adding an external signal.

Letters **B and C were deliberately not renumbered** so existing references stay valid. Lessons in `feedback/lessons/` carrying `gate: A` or `gate: D` in their frontmatter are accurate historical records; their substance now lands under Gate B or Gate C.

---

## 4. Verification Report Format

End code-modifying outputs and handoffs with a short `Verification` section. It is the evidence the next agent (or the user) relies on, so keep it factual and brief:

```
Verification
- Ran: npx tsc --noEmit → OK; pnpm test → 42 passed
- Not verified: browser check (no dev server in this environment)
```

Mention a Gate B rule only when it shaped a decision or was knowingly deviated from. Pure conversational/Q&A turns omit this section.

---

## 5. Prohibitions

- **No silent skipping.** If an environment limitation prevents verification (e.g., no test runner available), say so under `Not verified`.
- **No rule rewriting to pass.** Rules in `rules/` and skill files are not edited during a task. If a rule seems wrong, finish the task as-is and flag the rule in the final report.
- **No partial completion claims.** "Mostly works" / "should work" / "looks correct" are not evidence. Either a command shows it works, or you state it was not verified.

---

## 6. Feedback Capture (Recurrence Prevention)

After a result is accepted, evaluate the capture trigger:

- The user **explicitly corrected** the result, OR
- The **same gate FAILed 2+ times** on this ticket (recurrence).

If either holds, the Orchestrator hands off to the `retrospective` agent with: what happened, the relevant files, and the gate involved. The retrospective agent applies its own 3-Part Capture Filter and may decide not to record. One-off failures with neither condition are not recorded — silence keeps the ledger high-signal.
