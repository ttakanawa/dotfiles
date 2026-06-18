---
name: review-until-clean
description: Use when the user asks to review and fix an existing PR/MR, branch diff, staged or unstaged diff, source code, specification, documentation, or configuration change until no actionable findings remain. Use for rerun-review-after-fixes and self-review-before-push requests; do not use for single-pass review-only requests.
---

# Review Until Clean

## Purpose

Drive a completed work diff to a review-clean state, whether the target is source code, specifications, documentation, configuration, or a mixed change. Review-clean means no actionable findings remain: either the review output is empty, or every remaining finding has been explicitly classified as Skip or Reject with a defensible reason.

This skill owns the loop. For each review pass, decide whether to use an available specialized skill, direct review, or subagents based on the changed files and the task. Use an available review-resolution workflow instead when the primary task is triaging existing remote reviewer comments and replying to threads.

## Workflow

### 1. Establish the Target

Identify the diff to review in this order:

1. Use the PR/MR URL, number, branch, commit, or commit range named by the user.
2. If the current branch has an open PR/MR, use its base-to-head diff.
3. If there is no open PR/MR, use the current branch against the upstream default branch.
4. If the branch diff is empty and staged changes exist, use the staged diff.
5. If staged diff is empty and unstaged changes exist, use the unstaged diff.

Use high-level commands before raw APIs:

  ```bash
  git status --short
  git rev-parse --abbrev-ref HEAD
  gh pr list --head "$(git rev-parse --abbrev-ref HEAD)"
  glab mr list --source-branch "$(git rev-parse --abbrev-ref HEAD)"
  git remote show origin
  ```

When multiple targets are plausible, explain why the decision matters, state what you checked, and ask the user which target to use. If every candidate diff is empty, stop and report that there is nothing to review.

### 2. Explain and Confirm Before Changing Files

Before modifying files, summarize:

- review target
- review method
- project-required checks, if any
- whether you will commit
- whether you will push

Ask for confirmation before file edits unless the user has already clearly asked you to proceed with this exact workflow. Always confirm immediately before `git push`, even if earlier confirmation covered fixes and commits.

### 3. Run a Review Pass

Before each review pass, inspect the skills and instructions available to the current agent and project. Use a skill only when it encodes a better workflow for the current change or review source; this may be a built-in skill, a user-level skill, a project-level skill, or an agent-specific review workflow. Do not invoke a skill just because it exists. Direct review is acceptable for very small diffs, mechanical changes, or cases where no available skill materially improves the review.

Gather enough context before invoking review or subagents:

- diff output
- diff stat
- PR/MR title and description when available
- local instructions such as `AGENTS.md`

Actively use subagents when the task can be split without shared-state conflicts. Good subagent work includes independent review categories, separate subsystem investigations, independent findings with disjoint write sets, and project-prescribed checks that can run in parallel with other work. Keep tightly coupled design decisions, final triage, commits, push decisions, and user-facing summaries in the main agent.

When using review subagents, pass raw diff, file stats, PR/MR description, relevant skill guidance, and acceptance criteria into each prompt. Treat the categories below as reference review lenses, not a required or exhaustive list; choose, merge, rename, or omit them based on the changed files and risks. Run independent review lenses in parallel when the environment supports it:

- architecture
- guidelines
- security
- code quality
- specification consistency
- documentation clarity
- requirements coverage
- performance
- readability
- license

Normalize findings into this shape:

  ```text
  #N [SEVERITY][Category] Summary
  File: path/to/file:line
  Issue: Why this is a problem
  Fix: Concrete suggested fix
  ```

Severity order is `CRITICAL`, `HIGH`, `MEDIUM`, then `LOW`.

If you run a direct review without a specialized skill, still check the review lenses relevant to the target. For code, that often includes bug risk, security risk, behavior regression, and missing executable coverage. For specifications and documentation, that often includes correctness, ambiguity, internal consistency, requirements coverage, user impact, outdated claims, and mismatch with implemented behavior. For configuration, that often includes default behavior, compatibility, secret handling, environment assumptions, and operational impact.

### 4. Triage Findings

Triage in severity order. Classify every finding as:

- **Fix**: The finding is valid and should be corrected in this workflow.
- **Skip**: The finding is valid but out of scope or not worth changing for this task.
- **Reject**: The finding is incorrect or conflicts with the existing specification.
- **Ask**: A product, policy, API, security, data model, migration, or user-visible behavior decision is required.

Ask the user before proceeding when:

- public behavior changes
- API contracts change
- data model or migration behavior changes
- authentication, authorization, permissions, or security posture changes
- multiple defensible solutions exist
- the fix expands beyond the original change area
- you plan to leave a finding as Skip or Reject

Small bug fixes, tests, lint fixes, typo fixes, and alignment with established local patterns may proceed after the initial workflow confirmation.

### 5. Fix Approved Items

Fix findings by cohesive change, not blindly one commit per comment. Combine findings that touch the same file, behavior, or design decision.

For each fix:

1. Read the target files.
2. Follow existing patterns and helper APIs.
3. Keep unrelated refactors out of the change.
4. Add or update tests only when project rules require them or a behavior change needs executable coverage.
5. Preserve unrelated user changes in the worktree.

Use fix agents only for independent findings that do not share files or design decisions. The main agent must review fix-agent output before committing.

### 6. Respect Project Checks

Do not invent verification requirements in this skill. Follow checks only when they are required by the current project, current agent, active hooks, or explicit user instructions.

Look for required checks in:

- project instructions such as `AGENTS.md`
- configured pre-commit or pre-push hooks
- repository task runners or CI docs when local instructions point to them
- explicit user instructions

If no active project, agent, hook, or user rule requires a check, do not add one only because a generic review workflow usually would. If a required check fails because dependencies, network access, or permissions are unavailable, report the exact failure and ask before changing environment state.

### 7. Commit

Commit after required project checks pass, or after noting that no active project, agent, hook, or user rule requires additional checks.

Commit policy:

- Prefer one commit per review iteration.
- Split commits by finding only when findings are large and independent.
- Keep findings that share files, behavior, or design decisions in one cohesive commit.
- Stage only files changed for this workflow.

Before committing, inspect staged and unstaged changes:

  ```bash
  git status --short
  git diff
  git diff --staged
  ```

Use a commit message that names what was made review-clean, such as:

  ```bash
  git commit -m "fix: address review findings for auth flow"
  ```

### 8. Push Before Remote Re-Review

After a commit, decide whether the next review pass depends on remote state. If the review target is an existing PR/MR, a remote branch diff, remote reviewer tooling, or any source that only sees pushed commits, push the current branch before running the next review pass.

Always confirm immediately before `git push`. Before pushing, run:

  ```bash
  git status --short
  git log --oneline @{u}..HEAD
  ```

Push policy:

- For a branch with an existing PR/MR, push the current branch.
- For a branch without a PR/MR, push the current branch but do not create a PR/MR.
- Never force push unless the user explicitly asks for force push.
- Do not monitor CI after push unless the user asks; CI follow-up is a separate workflow.

If the user declines a push that is required for the selected remote review source to see the latest fixes, stop and report that review-clean cannot be established against that source. Continue with a local re-review only when that still satisfies the chosen target.

### 9. Repeat Until Clean

After each commit, run another review pass against the full updated target: the latest version of the original review target, including both areas changed by fixes and areas left unchanged.

Stop the loop only when one of these is true:

- no findings remain
- every remaining finding is classified as Skip or Reject
- an Ask decision is required and the user has not answered
- the same blocker has occurred three consecutive times and no meaningful progress is possible without external change

Do not treat a clean-looking first pass as enough if fixes were just made. Review again after fixes unless the user explicitly stops the loop.

### 10. Final Push

After the clean condition is met, push only if commits remain unpushed and the user confirms the push. This is a final catch-up push for local-only review targets or any commits not already pushed before a remote re-review.

Before pushing, run:

  ```bash
  git status --short
  git log --oneline @{u}..HEAD
  ```

Push policy:

- Use the same push policy from "Push Before Remote Re-Review".

Final summary must include:

- target reviewed
- total review passes run (minimum 2; 1 indicates the post-fix re-review was skipped)
- commits created
- project-required checks run, or why none were run
- remaining skipped or rejected findings with reasons
- pushed branch and remote, when pushed

## Interaction Rules

Before asking a question, explain what you already checked and why the decision matters. Keep questions specific and short.

Before file edits, explain the overall change and wait for confirmation unless the user already gave exact permission for this workflow. Before push, always confirm again.

Do not reply to remote review threads in this workflow. If thread replies are required, switch to `resolve-review`.
