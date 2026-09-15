# Codex Multi-Agent Workflow

The primary Codex thread is the default orchestrator. It owns task classification, delegation, progress tracking, result consolidation, and the final response.

Do not spawn the `orchestrator` custom agent as an intermediate layer unless the user explicitly requests that agent. Prefer direct delegation from the primary thread to the smallest useful set of specialists.

## Task Classification

Classify each task before acting. File count and line count are supporting signals, not deciding factors. Base the decision on ownership boundaries, risk, uncertainty, verification needs, and whether delegation materially improves quality or latency.

### Direct Execution

Handle a task directly when all of the following are true:

- The requirement and target location are clear.
- The change belongs to one ownership area.
- No architecture, public-contract, data-migration, authentication, authorization, security, infrastructure, concurrency, transaction-integrity, or dependency decision is required.
- Verification is narrow and deterministic.
- Delegation would not materially improve quality or latency.

### Single-Specialist Delegation

Delegate to one specialist when the task belongs to one clear domain and that specialist's focused instructions would materially improve the result:

- Repository exploration, execution tracing, ownership mapping, or impact analysis: `codebase_explorer`.
- React, Next.js, TypeScript UI, accessibility, client behavior, or frontend tests: `frontend_developer`.
- APIs, server-side logic, persistence, validation, authentication, authorization, or backend tests: `backend_developer`.
- Independent review of an existing change: `code_reviewer`.
- Requirement validation, regression testing, browser verification, or defect reproduction: `qa_engineer`.

### Multi-Agent Orchestration

Use a multi-agent workflow when a hard-risk condition applies or when at least two of the following are true:

- The task contains two or more independent workstreams.
- The change spans multiple ownership areas, packages, services, or technical domains.
- Repository exploration is required before implementation ownership is clear.
- Independent implementation, review, and QA stages are required.
- Parallel read-heavy work would materially reduce latency or keep noisy evidence out of the primary context.
- Multiple agents must preserve a shared interface or contract.

Hard-risk conditions include authentication, authorization, payments, database migrations, public API changes, security boundaries, concurrency, transaction integrity, infrastructure, deployment pipelines, and critical dependency changes.

## Coordination Rules

- Run no more than three subagents concurrently.
- Use the smallest number of agents that materially improves the outcome.
- Prefer parallel execution for independent read-heavy work such as exploration, review lenses, test analysis, and log inspection.
- Parallelize implementation only when file ownership and interfaces are disjoint.
- Never assign the same file to concurrent writers.
- Establish shared contracts before starting dependent or parallel implementation.
- Give every delegated task an explicit objective, scope, acceptance criteria, verification requirements, expected output, and no-edit boundary.
- Wait for every requested result before consolidating the current work wave.
- Preserve user changes and do not expand scope through delegation.

## Review and QA Gates

- Route material production-code changes through `code_reviewer` after implementation.
- After review is acceptable, route user-facing, contract-sensitive, or otherwise material behavior through `qa_engineer`.
- If review or QA finds a reproducible defect, return the smallest remediation task to the responsible implementation specialist.
- Request targeted re-review and repeat only the necessary QA checks after remediation.
- Do not claim completion while a required review or QA gate is failing or remains unverified.
