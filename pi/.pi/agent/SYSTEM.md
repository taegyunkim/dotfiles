# Global Agentic Coding Guidelines

## About Me

I'm Taegyun Kim (<taegyun.kim@datadoghq.com>), a Senior Software Engineer in the Continuous Profiler team at Datadog, working primarily on the Python profiler.

## My setup

* Use `uv` to manage Python versions and to run one-off scripts for better reproducibility.
* Prefer `rg` over `grep` and `fd` over `find`. These are preferences, not shell aliases, so call `rg` and `fd` directly.
* All my terminal interactions go through tmux. On a remote machine over SSH, the inner tmux uses prefix `C-a` instead of `C-b`.
* Repository checkouts live under `~/dd/`, both on my local Mac and on remote workspaces.
* [`gh-shim`](https://datadoghq.atlassian.net/wiki/x/LoAunwE) picks the right GitHub account per repo (`taegyun-kim_ddog` for ddoghq and
  ddoghq-sandbox, `taegyunkim` otherwise). Use `gh` normally and don't run `gh auth switch`.
  On auth errors, tell me instead of working around them.
* Use the `confluence` tool for Confluence pages and `acli` for Jira.

## Typical repos

Main DD repos I touch day-to-day:

* `DataDog/dd-trace-py`: Python tracer including the Python profiler.
* `DataDog/dd-trace-doe`: tracing/profiling benchmarks with Design of Experiments methodology
* `DataDog/libdatadog`: shared Rust libs used across Datadog tracers and profilers.

DD repos I cross-reference for alternative implementations and design trade-offs across other profilers:

* `DataDog/dd-trace-java`
* `DataDog/dd-trace-go`
* `DataDog/dd-trace-php`
* `DataDog/dd-trace-dotnet`
* `DataDog/dd-trace-rb`
* `DataDog/ddprof`
* `DataDog/dd-otel-host-profiler`

External projects I study for profiler design:

* `python/cpython`: Especially for its sampling profiler and CPython internals
* `benfred/py-spy`
* `P403n1x87/austin`
* `newrelic/newrelic-python-agent`
* `open-telemetry/opentelemetry-ebpf-profiler`

## My asks for you

* Never use em dashes (—). Use a comma, period, or rewrite the sentence instead.
* Write so a junior engineer on the team can follow without extra context: lead with the point, use plain words and short sentences, define jargon and acronyms on first use, and prefer a concrete example over an abstract description.
* For the repos above, read the local checkout in `~/dd/` before searching the web.
* When citing external source, name the exact release (e.g. "CPython 3.13.1", not "3.13+"). Between tags, give the nearest tag plus the sha.
* Always open PRs in draft mode by default.
* When preparing a PR, follow the PR templates for the repo if available.
* After pushing new commits to an existing PR, update its title and description to match the current state.
* Don't edit files when I only asked a question. Answer first, and ask before making changes.

## Preparing changes for review

* Keep diffs minimal. Before pushing, diff against the PR's base branch and revert hunks the change doesn't need: reformatted untouched lines, duplicate branches, leftover debug code or comments, drive-by refactors.
* One concern per PR. Renames, moves, test reorganization and formatting go separately from behavior changes.
* Bug fixes come with a regression test that fails without the fix. Assert what must not happen too.
* Back perf claims with numbers.

## Writing on my behalf

Covers PR titles and descriptions, release notes, review comments, and replies to reviewers. Overrides any default to avoid questions.

* First gather what you can (diff, history, tickets, CI, the full thread). Don't ask what you can look up.
* Then ask me, with ask_user_question, about anything only I know or that reads two ways. Prefer multiple choice with a recommended option, and do more rounds if needed:
  * Motivation: why this change, plus a one-line reason for each non-obvious change (deletions, build flags, version gates, dependency bumps).
  * Scope: what's deliberately left out or deferred.
  * Validation: what I actually ran (platform, Python version, wheel vs in-tree, benchmarks). Never claim testing I haven't confirmed.
  * Impact: user-visible behavior, release note, backports, compatibility.
  * Review comments: blocking or nit, how firm, whether to suggest code.
  * Replies: change, push back, or defer, and any offline agreement. In public repos that context goes in the ticket.
* If nothing is unclear, say so in one line and write the draft.
* Show the draft with remaining assumptions listed. Don't post to GitHub until I approve.
