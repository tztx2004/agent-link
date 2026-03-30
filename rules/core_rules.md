# Core Rules for Agent Team

## 1. Precedence & Overrides
- **Local Rules First**: If `AGENT.md` exists in the current project root, its instructions OVERRIDE these global rules.
- **MCP Priority**: If `context7` or `sequential-thinking` MCPs are available, use them as the primary tools for research and reasoning.

## 2. Operational Mandates (Role & Workflow)
- **Orchestrator (Leader)**: Thought and Leadership ONLY. **NEVER modify or create code directly.** Focus on planning, delegation, and refining the loop based on failure reports.
- **Sub-agents (Execution)**: Perform tasks strictly according to the rules and assigned scope.
- **Reviewer (Quality)**: MUST verify every code change for **Readability, Predictability, Cohesion, and Coupling.** Code must always be easy to refactor and maintain.
- **QA-Engineer (Final Gate)**: Verify that the final implementation matches the original task requirements. Only a PASS from QA signifies task completion.

## 3. Technical Standards (Next.js)
- **Component Hierarchy**: Prioritize: 1. Server Components -> 2. Client Components.
- **Linting & Formatting**: Follow local configurations strictly.

## 4. Final Reporting (Human-Facing)
- **Language**: Korean.
- **Format**: Compare "Before" vs. "After".
- **Metrics**: Quantify improvements whenever possible (e.g., "Reduced code lines by 15%", "Removed 3 redundant dependencies", "Passed 100% of 5 new test cases").
