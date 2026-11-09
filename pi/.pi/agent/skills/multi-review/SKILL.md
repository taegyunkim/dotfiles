---
name: multi-review
description: Review a PR, branch, or working-tree change with several models in parallel, verify each blocking finding by running its proof, and optionally fix and re-review until no verified blockers remain. Use when the user asks for a multi-model review, a review with named models, or to review and update code until there are no blocking issues.
---

# Multi-model review

Reviewers from different models look for what breaks the change. Only findings you confirm count. You, the parent session, run the loop and make every decision.

## 1. Load the roster

Read `reviewers.json` next to this file. Each entry is one reviewer: `model` is the exact provider/id, `thinking` its level. `maxRounds` caps review rounds.

The user's request can override it for this run only:

- Naming models ("review with X and Y") replaces the roster.
- "Also add X" or "plus X" appends to it.
- "N rounds" replaces `maxRounds`.

Resolve each named model to an exact provider/id before launching. If a name is ambiguous or unknown, ask. Never swap in a different model silently.

## 2. Frame the target

- **Target**: the PR the user names, else the current branch against its merge base with the default branch, including uncommitted changes. For a PR on another branch, check it out when the tree is clean; ask first if it isn't.
- **Mode**: `fix` when the user asks to fix, update code, or loop until clean. Otherwise `report`, which edits nothing.
- **Intent**: one or two sentences from the PR description, commits, and linked ticket. Ask if it's unclear; reviewers judge against it.
- **Scratch**: `/tmp/multi-review/<repo>-<pr-or-branch>/round-<n>/`. Write `full.diff`, `delta.diff` from round 2 on, and `intent.md` there.

Tell the user in one line: target, mode, roster, cap.

## 3. Run a round

Launch one `proof-reviewer` per roster entry in a single async `parallel` workflow, fresh context, cwd set to the repository:

```
subagent({ workflow: "parallel", async: true, args: { tasks: [
  { agent: "proof-reviewer", model: "<provider/id>:<thinking>", task: "<brief>" }, ...
] } })
```

Every reviewer gets the same brief: repository path and head SHA, the scratch directory and the files in it, the intent, the repo's own review rules if it has them (AGENTS.md, test and lint skills), and from round 2 on the previous round's verified findings with their fixes. Then return control. The completion wakes you.

If a launch or child fails, stop and report it. Don't continue with fewer reviewers unless the user agrees.

## 4. Verify

For each blocking finding:

- `ran` or `proposed`: rerun the command yourself on the reviewed head. Confirm it only when the output shows the failure and the failure breaks the intent.
- `code-path`: walk the path in the source yourself. Confirm only if every step holds.

Mark each finding **confirmed**, **not reproduced**, or **unproven**. Merge findings with one root cause and note which models found it. Keep non-blocking findings as notes. Don't fix them unless the user asks.

## 5. Fix (fix mode only)

For each confirmed blocker, smallest change first:

- Add a regression test that fails without the fix, then fix the code, not the test.
- Run the targeted tests and the repo's lint the way its AGENTS.md says.
- One local commit per finding. Don't push.

Stop and ask the user when a fix needs a product, API, scope, or design call.

## 6. Loop or stop

Run another round after any fix. Stop when:

- no confirmed blockers remain, or
- the round cap is reached, or
- the same root cause comes back after a fix. Then don't patch again. Write down the premise the fixes shared, test it directly, and bring it to the user.

When the loop stops, send a desktop notification with the outcome.

## 7. Report

Follow the user's writing rules. Keep it short:

- **Result**: one line. Rounds run, confirmed blockers fixed or open, why it stopped.
- **Findings**: a table. Finding, models that found it, verdict, fix commit or "open".
- **Dropped**: count of not reproduced and unproven findings per model, one line.
- **Reviewer guide**, at most 5 lines: what the change does, which file to read first, the riskiest part, and which tests prove the behavior.
- **Next**: what needs the user, such as pushing the commits or the open blockers.
