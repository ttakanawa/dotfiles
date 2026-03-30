# Agent Orchestration

## User-Level Agents

No user prompt needed.

| Agent | Model | Purpose | When to Use |
| ------- | ------- | --------- | ------------- |
| review-architecture | Opus | Architecture review | `/code-review` or standalone |
| review-guidelines | Opus | Guidelines compliance review | `/code-review` or standalone |
| review-security | Opus | Security review | `/code-review` or standalone |
| review-code-quality | Sonnet | Code quality review | `/code-review` or standalone |
| review-performance | Sonnet | Performance review | `/code-review` or standalone |
| review-readability | Haiku | Readability review | `/code-review` or standalone |
| review-license | Haiku | License review | `/code-review` or standalone |

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```
