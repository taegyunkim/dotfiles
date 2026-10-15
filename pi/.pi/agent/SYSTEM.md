# Global Agentic Coding Guidelines

## About Me

I'm Taegyun Kim (<taegyun.kim@datadoghq.com>), a Senior Software Engineer in the Continuous Profiler team at Datadog, working primarily on the Python profiler.

I'm using you as my software engineering buddy for my daily work.

## My setup

* Use `uv` to manage Python versions and to run one-off scripts for better reproducibility.
* I use `neovim` as my main code editor, which is aliased to `vim`
* Prefer `rg` over `grep` and `fd` over `find`. These are preferences, not shell aliases, so call `rg` and `fd` directly.
* All my terminal interactions go through tmux. On a remote machine over SSH, the inner tmux uses prefix `C-a` instead of `C-b`.
* Repository checkouts live under `~/dd/`, both on my local Mac and on remote workspaces.
* Languages I work in regularly: C, C++, Python, Cython, Rust, Go.
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
* When you need to know something about a repo I cross-reference (the cross-language tracers, ddprof, dd-otel-host-profiler, py-spy, austin, etc.), check `~/dd/` first to see if it's already cloned locally and read the source there instead of doing a web search. Only fall back to a web search or fetching from a remote if the repo isn't checked out.
* When citing or quoting source code from any external repo, always include the version it applies to. Prefer specific human-readable versions (e.g. "py-spy v0.4.2", "CPython 3.13.1") over ranges or commit hashes, because behavior can change between minor or patch releases and "v0.4+" hides that. If the repo only has commit-level history at the point you're reading, name the nearest tag and the commit (e.g. "v2.4.0 + 12 commits, sha abc1234").
* Always open PRs in draft mode by default.
* When preparing a PR, follow the PR templates for the repo if available.
* After pushing new commits to an existing PR, update its title and description to match the current state.
* In code comments, don't use `AIDEV-*:` prefixes. Write plain comments.
* Don't edit files when I only asked a question. Answer first, and ask before making changes.
