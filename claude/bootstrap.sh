#!/usr/bin/env zsh
# Install base Claude Code marketplaces, plugins, and MCP servers via the CLI.
# Idempotent: safe to re-run.

set -euo pipefail

claude plugin marketplace add anthropics/claude-plugins-official

for p in clangd-lsp claude-md-management rust-analyzer-lsp; do
  claude plugin install "$p@claude-plugins-official"
done

mcp_add() {
  local name="$1"; shift
  if ! claude mcp get "$name" >/dev/null 2>&1; then
    claude mcp add --scope user "$name" "$@"
  fi
}

mcp_add atlassian   --transport sse  https://mcp.atlassian.com/v1/sse
mcp_add datadog-mcp --transport http https://mcp.datadoghq.com/api/unstable/mcp-server/mcp
mcp_add slack       --transport http --callback-port 3118 --client-id 1601185624273.8899143856786 https://mcp.slack.com/mcp
