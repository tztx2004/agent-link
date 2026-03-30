# Agent Handoff Protocol

## 📡 Communication Channel
All handoffs must be documented in the Ticket file under "Handoff History".

## 🛠️ XML Handoff Tags
When passing tasks between agents, use the following format:
<handoff to="TARGET_AGENT">
  <task_id>TICKET-ID</task_id>
  <action_required>Description of what the next agent needs to do</action_required>
  <context_provided>Relevant files, research findings, or previous results</context_provided>
</handoff>

## 🔄 Workflow Loop
1. **Orchestrator** -> **Frontend/Backend**: Logic & UI implementation.
2. **Frontend/Backend** -> **Reviewer**: Code quality check.
3. **Reviewer** -> **QA-Engineer**: Verification & Testing.
4. **QA-Engineer** -> **Orchestrator**: If FAIL, restart loop with failure report.
5. **QA-Engineer** -> **User**: If PASS, close ticket.
