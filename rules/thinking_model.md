# Thinking Model (Lean Cognition Protocol)

## 1. Purpose

A lightweight cognitive framework for implementation and planning. Modern LLMs possess strong internal Chain-of-Thought (Extended Thinking) capabilities; this protocol establishes **essential grounding anchors** rather than enforcing rigid procedural stages.

- **Pre-implementation**: Ground changes in actual code and impact analysis via internal reasoning.
- **Post-implementation**: Verify against empirical evidence (`verification.md` Gate C).

## 2. Core Principles (The 3 Grounding Anchors)

1. **Read Before Write (Empirical Grounding)**:
   - Never assume file contents, imports, or API signatures from memory or intuition.
   - Read the relevant code, types, and configurations (`view_file`, `grep_search`) before planning or editing.

2. **Impact Boundary (Scope Awareness)**:
   - Identify contracts, dependencies, or sibling modules touched by the change.
   - For multi-file or cross-domain changes, outline a clear, bounded plan before editing.

3. **Verify with Real Outputs (Artifact-Driven Validation)**:
   - Every implementation must produce tangible evidence: run type-check (`tsc`), linter (`eslint`), tests, or build commands.
   - Narrative claims ("it looks good", "should work") are invalid without captured command outputs.

## 3. Practical Workflow

- **Simple / Local Tasks**: Read the target file → Edit → Run verification command.
- **Complex Tasks**: Explore relevant files → Outline a bounded plan → Implement → Capture verification evidence.
- Agents use their internal reasoning (CoT) naturally without being forced to emit rigid stage labels (e.g. `READ: ...`, `REACT: ...`) into the conversation output.
