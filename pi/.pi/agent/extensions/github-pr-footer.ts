import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "github-pr";
const BRANCH_POLL_INTERVAL_MS = 5_000;
const PR_CACHE_TTL_MS = 60_000;
const COMMAND_TIMEOUT_MS = 5_000;
const DATADOG_GITHUB_OWNERS = new Set(["ddoghq", "ddoghq-sandbox"]);
const DATADOG_GITHUB_USER = "taegyun-kim_ddog";
const INITIAL_REFRESH_DELAY_MS = 1_000;

interface GitHubRepository {
  owner: string;
  name: string;
}

interface PullRequest {
  number: number;
  url: string;
}

interface CommandResult {
  stdout: string;
  exitCode: number;
}

interface RepositoryBranch {
  repository: GitHubRepository;
  branch: string;
}

function runCommand(
  command: string,
  args: string[],
  options: { cwd?: string; env?: NodeJS.ProcessEnv; timeoutMs?: number } = {},
): Promise<CommandResult | null> {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: options.cwd,
      env: options.env ?? process.env,
      stdio: ["ignore", "pipe", "ignore"],
      windowsHide: true,
    });

    let stdout = "";
    let settled = false;
    const finish = (result: CommandResult | null) => {
      if (settled) return;
      settled = true;
      clearTimeout(timeout);
      resolve(result);
    };

    child.stdout.on("data", (chunk) => {
      stdout += chunk.toString();
    });
    child.on("error", () => finish(null));
    child.on("close", (exitCode) => finish({ stdout: stdout.trim(), exitCode: exitCode ?? 1 }));

    const timeout = setTimeout(() => {
      child.kill();
      finish(null);
    }, options.timeoutMs ?? COMMAND_TIMEOUT_MS);
  });
}

export function parseGitHubRepository(remoteUrl: string): GitHubRepository | null {
  const trimmed = remoteUrl.trim();
  if (!trimmed) return null;

  let host: string;
  let pathname: string;
  const scpLike = /^(?:[^@/]+@)?([^:/]+):(.+)$/.exec(trimmed);
  if (scpLike && !trimmed.includes("://")) {
    host = scpLike[1]!;
    pathname = scpLike[2]!;
  } else {
    try {
      const parsed = new URL(trimmed);
      host = parsed.hostname;
      pathname = parsed.pathname;
    } catch {
      return null;
    }
  }

  if (host.toLowerCase().replace(/^www\./, "") !== "github.com") return null;

  const parts = pathname.replace(/^\/+|\/+$/g, "").split("/");
  if (parts.length !== 2 || !parts[0] || !parts[1]) return null;

  const name = parts[1].replace(/\.git$/i, "");
  return name ? { owner: parts[0], name } : null;
}

export function parsePullRequestList(output: string): PullRequest | null {
  try {
    const parsed = JSON.parse(output) as unknown;
    if (!Array.isArray(parsed) || parsed.length === 0) return null;

    const candidate = parsed[0] as { number?: unknown; url?: unknown };
    if (!Number.isInteger(candidate.number) || (candidate.number as number) <= 0) return null;
    if (typeof candidate.url !== "string") return null;

    const url = new URL(candidate.url);
    if (url.protocol !== "https:" || url.hostname !== "github.com") return null;
    return { number: candidate.number as number, url: candidate.url };
  } catch {
    return null;
  }
}

export function formatPullRequestLink(pullRequest: PullRequest): string {
  const label = `#${pullRequest.number}`;
  return `\x1b]8;;${pullRequest.url}\x1b\\\x1b[4m${label}\x1b[24m\x1b]8;;\x1b\\`;
}

export async function getRepositoryBranch(cwd: string): Promise<RepositoryBranch | null> {
  const [branchResult, remoteResult] = await Promise.all([
    runCommand("git", ["symbolic-ref", "--quiet", "--short", "HEAD"], { cwd }),
    runCommand("git", ["remote", "get-url", "origin"], { cwd }),
  ]);

  if (branchResult?.exitCode !== 0 || remoteResult?.exitCode !== 0) return null;
  const branch = branchResult.stdout;
  const repository = parseGitHubRepository(remoteResult.stdout);
  return branch && repository ? { branch, repository } : null;
}

let datadogTokenPromise: Promise<string | null> | null = null;

async function getDatadogToken(): Promise<string | null> {
  if (!datadogTokenPromise) {
    datadogTokenPromise = runCommand("gh", ["auth", "token", "--user", DATADOG_GITHUB_USER])
      .then((result) => result?.exitCode === 0 && result.stdout ? result.stdout : null);
  }
  return datadogTokenPromise;
}

export async function findPullRequest(repository: GitHubRepository, branch: string): Promise<PullRequest | null> {
  const repo = `${repository.owner}/${repository.name}`;
  let env = process.env;

  if (DATADOG_GITHUB_OWNERS.has(repository.owner.toLowerCase())) {
    const token = await getDatadogToken();
    if (token) env = { ...process.env, GH_TOKEN: token };
  }

  const result = await runCommand(
    "gh",
    ["pr", "list", "--repo", repo, "--head", branch, "--state", "all", "--limit", "1", "--json", "number,url"],
    { env },
  );
  return result?.exitCode === 0 ? parsePullRequestList(result.stdout) : null;
}

export default function githubPrFooter(pi: ExtensionAPI): void {
  let currentContext: any = null;
  let pollTimer: NodeJS.Timeout | null = null;
  let initialRefreshTimer: NodeJS.Timeout | null = null;
  let refreshInProgress = false;
  let refreshAgain = false;
  let generation = 0;
  let cachedKey: string | null = null;
  let cachedPullRequest: PullRequest | null = null;
  let cachedAt = 0;

  const publish = (context: any, pullRequest: PullRequest | null) => {
    if (!context?.hasUI) return;
    context.ui.setStatus(STATUS_KEY, pullRequest ? formatPullRequestLink(pullRequest) : undefined);
  };

  const refresh = async (force = false): Promise<void> => {
    if (!currentContext) return;
    if (refreshInProgress) {
      refreshAgain = refreshAgain || force;
      return;
    }

    refreshInProgress = true;
    const refreshGeneration = generation;
    const context = currentContext;

    try {
      const repositoryBranch = await getRepositoryBranch(context.cwd ?? process.cwd());
      if (refreshGeneration !== generation || context !== currentContext) return;

      if (!repositoryBranch) {
        cachedKey = null;
        cachedPullRequest = null;
        cachedAt = 0;
        publish(context, null);
        return;
      }

      const { repository, branch } = repositoryBranch;
      const key = `${repository.owner}/${repository.name}:${branch}`;
      const cacheIsFresh = key === cachedKey && Date.now() - cachedAt < PR_CACHE_TTL_MS;
      if (!force && cacheIsFresh) {
        publish(context, cachedPullRequest);
        return;
      }

      const pullRequest = await findPullRequest(repository, branch);
      if (refreshGeneration !== generation || context !== currentContext) return;

      cachedKey = key;
      cachedPullRequest = pullRequest;
      cachedAt = Date.now();
      publish(context, pullRequest);
    } finally {
      refreshInProgress = false;
      if (refreshAgain && currentContext) {
        const forceNextRefresh = refreshAgain;
        refreshAgain = false;
        void refresh(forceNextRefresh);
      }
    }
  };

  const scheduleRefresh = () => {
    void refresh(false);
  };

  pi.on("session_start", (_event, context) => {
    generation++;
    currentContext = context;
    cachedKey = null;
    cachedPullRequest = null;
    cachedAt = 0;
    publish(context, null);

    if (pollTimer) clearInterval(pollTimer);
    if (initialRefreshTimer) clearTimeout(initialRefreshTimer);
    pollTimer = setInterval(scheduleRefresh, BRANCH_POLL_INTERVAL_MS);
    pollTimer.unref();
    // Pi binds the custom footer after session_start listeners finish. Waiting
    // briefly ensures the first status update reaches Powerline's repaint hook.
    initialRefreshTimer = setTimeout(() => {
      initialRefreshTimer = null;
      void refresh(true);
    }, INITIAL_REFRESH_DELAY_MS);
    initialRefreshTimer.unref();
  });

  pi.on("turn_start", scheduleRefresh);
  pi.on("tool_result", scheduleRefresh);
  pi.on("agent_end", scheduleRefresh);

  pi.on("session_shutdown", (_event, context) => {
    generation++;
    publish(context, null);
    currentContext = null;
    if (pollTimer) clearInterval(pollTimer);
    if (initialRefreshTimer) clearTimeout(initialRefreshTimer);
    pollTimer = null;
    initialRefreshTimer = null;
  });
}
