# Global Claude Guidelines

## About Me

My name is Taegyun, I'm a Senior Software Engineer in the Continuous Profiler team at Datadog, working primarily on the Python profiler.

I'm using you as my software engineering buddy for my daily work across the stack.

Some personal details about me:

* Name: Taegyun Kim
* Email: <taegyun.kim@datadoghq.com>
* Github: <https://github.com/taegyunkim>
* Slack: @taegyun.kim (<https://dd.enterprise.slack.com/team/U071N8GMG68>)

Slack channels I monitor:

* #profiling-python (<https://dd.enterprise.slack.com/archives/C040E5XBLTF>)
* #profiling-team (<https://dd.enterprise.slack.com/archives/GK1JL5FAB>)
* #profiling-libraries (<https://dd.enterprise.slack.com/archives/C04DF4T1UMB>)
* #libdatadog (<https://dd.enterprise.slack.com/archives/C01TCF143GB>)
* #guild-dd-trace-py (<https://dd.enterprise.slack.com/archives/C02E4BKJQBT>)
* #apm-python-release (<https://dd.enterprise.slack.com/archives/C04MK6NNDG9>)
* #support-profiler (<https://dd.enterprise.slack.com/archives/C019FJ8Q2QJ>)
* #dd-trace-doe (<https://dd.enterprise.slack.com/archives/C096ACTU26Q>)
* #dogweb-dd-trace-py-upgrade (<https://dd.enterprise.slack.com/archives/C08G8GU67JB>)

Useful team links:

* Confluence: <https://datadoghq.atlassian.net/wiki/spaces/PROF>
* JIRA: <https://datadoghq.atlassian.net/browse/PROF>

## My setup

* I use `pyenv` to manage multiple versions of Python. I also have `uv` available and use it to run most one-off scripts for better reproducibility.
* I use `neovim` as my main code editor (lua config under `~/.config/nvim`, lazy.nvim plugin manager, blink.cmp, telescope + fzf, treesitter, LSPs via mason).
* I have rust-optimized tool alternatives for faster execution:
  * `grep` → `rg`
  * `find` → `fd`
* All my terminal interactions go through tmux. On a remote machine over SSH, the inner tmux uses prefix `C-a` instead of `C-b`.
* Datadog-related repos live under `~/dd/`. Personal repos live under `~/personal` (or `~/.dotfiles` for dotfiles).
* Languages I work in regularly: C, C++, Python, Cython, Rust, Go.
* When using `gh`, make sure to check which account we're currently logged into.
  For repositories in github.com/ddoghq-sandbox and github.com/ddoghq, need to use
  taegyun-kim_ddog. Use my personal taegyunkim for the rest.

## Typical repos

Main DD repos I touch day-to-day:

* `DataDog/dd-trace-py`: Python tracer including the Python profiler.
* `DataDog/dd-trace-doe`: profiler DOE (Datadog On Engineering / experimentation).
* `DataDog/libdatadog`: shared Rust libs used across Datadog tracers and profilers.

DD repos I cross-reference for alternative implementations and design trade-offs across other profilers:

* `DataDog/dd-trace-java`
* `DataDog/dd-trace-go`
* `DataDog/dd-trace-php`
* `DataDog/dd-trace-dotnet`
* `DataDog/dd-trace-rb`
* `DataDog/ddprof`
* `DataDog/dd-otel-host-profiler`

External projects I study for profiler design and CPython internals:

* `python/cpython`
* `benfred/py-spy`
* `P403n1x87/austin`
* `newrelic/newrelic-python-agent`
* `open-telemetry/opentelemetry-ebpf-profiler`

## My asks for you

* Try not to ask for my input too often. Instead of lots of isolated questions, come up with a full proposal and ask me to review it.
* Try not to use compound commands or shell substitutions. They're a pain to whitelist.
* Never use em dashes (—). Use a comma, period, or rewrite the sentence instead.
* When you need to know something about a repo I cross-reference (the cross-language tracers, ddprof, dd-otel-host-profiler, py-spy, austin, etc.), check `~/dd/` first to see if it's already cloned locally and read the source there instead of doing a web search. Only fall back to a web search or fetching from a remote if the repo isn't checked out.
* When citing or quoting source code from any external repo, always include the version it applies to. Prefer specific human-readable versions (e.g. "py-spy v0.4.2", "CPython 3.13.1") over ranges or commit hashes, because behavior can change between minor or patch releases and "v0.4+" hides that. If the repo only has commit-level history at the point you're reading, name the nearest tag and the commit (e.g. "v2.4.0 + 12 commits, sha abc1234").
* Always open PRs in draft mode by default.
* When preparing a PR, follow the PR templates for the repo if available.
* When iterating or reacting to changes, update the PR description (if PR is already open) to reflect new state after changes.
