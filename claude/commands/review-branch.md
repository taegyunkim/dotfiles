---
description: Review someone else's code by branch name or PR link. Creates a worktree, then runs a dual-agent review.
allowed-tools: Bash(git:*), Bash(gh:*), Bash(sed:*), Bash(grep:*), Bash(echo:*), Bash(for:*), Bash(tail:*), Bash(done:*), Bash(codex:*), Bash(rm:*), Bash(cd:*), Task, TaskOutput, Read, Grep, Glob, Skill, Agent
---

Review code changes from another person's branch or PR. Input: a branch name (e.g., `vlad/lockprof-fix-wrapper-or-ing`) or a GitHub PR URL (e.g., `https://github.com/DataDog/dd-trace-py/pull/16748`).

## Step 1: Parse Input

The user input is: `$ARGUMENTS`

Determine whether the input is:
- **A GitHub PR URL** — contains `github.com` and `/pull/`
- **A branch name** — anything else

### If PR URL:

Extract the PR number and fetch the branch name and base branch:

```bash
gh pr view <PR_NUMBER> --json headRefName,baseRefName --jq '{head: .headRefName, base: .baseRefName}'
```

Store both the head branch name and the base branch name (e.g., `main`). Also store the PR number for later use with `gh pr diff`.

### If branch name:

Use the input directly as the branch name. The base branch will be determined later.

## Step 2: Fetch Branch and Create Worktree

Fetch both the base branch (e.g., main) and the target branch from origin so local refs are up to date:

```bash
git fetch origin <base-branch> <branch-name>
```

If the fetch fails (e.g., branch doesn't exist on remote), inform the user and stop.

Create a worktree for the branch under `.worktrees/` in the repository root. The worktree directory name should be the branch name as-is (preserving slashes as subdirectories, matching existing convention):

```bash
git worktree add .worktrees/<branch-name> -b <branch-name> --track origin/<branch-name>
```

This creates a new local branch that tracks the remote branch, so the worktree is on a proper branch (not detached HEAD).

If the worktree already exists, skip creation and reuse it.

## Step 3: Run Dual Review

IMPORTANT: Use `gh pr diff <PR_NUMBER>` to get the actual PR diff, NOT `git diff <base>...HEAD`. The branch may have been merged with main, causing `git diff main...HEAD` to include unrelated changes from other branches. `gh pr diff` returns only the changes that are part of the PR.

### 3a. Get the PR diff and changed files

If a PR number is available:
```bash
gh pr diff <PR_NUMBER> --name-only
```
This gives the list of files actually changed in the PR.

To get the full diff for review:
```bash
gh pr diff <PR_NUMBER>
```

If only a branch name was provided (no PR number), determine the base branch:
```bash
git -C .worktrees/<branch-name> symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' | grep . || echo "main"
```
Then use `git -C .worktrees/<branch-name> diff $(git merge-base origin/<base-branch> origin/<branch-name>)..origin/<branch-name>` to get only the branch's own changes.

### 3b. Launch parallel reviews

Launch ALL reviews simultaneously in a single message with multiple tool calls:

1. **Codex review** (background Bash): `cd .worktrees/<branch-name> && codex review --base <base-branch>`
   - If Codex fails with auth errors, warn the user to run `codex login` and continue with Claude-only review.

2. **Claude review agents** (background Agent tools, general-purpose): Launch these in parallel:
   - **Code Reviewer**: Focus on correctness, security, performance, API design
   - **Silent Failure Hunter**: Focus on swallowed exceptions, missing error handling, race conditions
   - **Test Coverage Analyzer**: Compare test changes against source changes to find gaps

   Each agent prompt MUST include:
   - The list of changed files (from `gh pr diff --name-only` or merge-base diff)
   - The full diff output (from `gh pr diff` or merge-base diff) so agents review only the actual PR changes
   - Instruction to read the full file for context using `Read` tool on `<worktree-path>/<file>`
   - Instruction to do read-only review only — no edits

### 3c. Wait for all reviews to complete

Monitor progress. Wait for all agents and Codex to finish.

### 3d. Aggregate and output unified report

Merge all findings into a single report with these sections:
- **Summary**: High-level overview
- **Critical Issues**: Bugs, security issues (note source: Claude agent name / Codex / Both)
- **Suggestions**: Improvements, style issues
- **Positive Highlights**: Good patterns, well-written code
- **Review Metadata**: Status of each reviewer, duplicate count, total findings

When two findings target the same file/location and same issue category, merge them and mark source as "Both".

## Step 4: Done

After the review completes, inform the user that the review is complete. The worktree at `.worktrees/<branch-name>` is left in place — the user can clean it up later with `git-remove-deleted-branches`.
