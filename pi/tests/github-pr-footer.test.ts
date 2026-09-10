import assert from "node:assert/strict";
import test from "node:test";
import {
  formatPullRequestLink,
  parseGitHubRepository,
  parsePullRequestList,
} from "../.pi/agent/extensions/github-pr-footer.ts";

test("parseGitHubRepository accepts common GitHub remote formats", () => {
  assert.deepEqual(parseGitHubRepository("git@github.com:DataDog/dd-trace-py.git"), {
    owner: "DataDog",
    name: "dd-trace-py",
  });
  assert.deepEqual(parseGitHubRepository("https://github.com/ddoghq/private-repo.git"), {
    owner: "ddoghq",
    name: "private-repo",
  });
  assert.deepEqual(parseGitHubRepository("ssh://git@github.com/taegyunkim/dotfiles.git"), {
    owner: "taegyunkim",
    name: "dotfiles",
  });
});

test("parseGitHubRepository rejects non-GitHub and malformed remotes", () => {
  assert.equal(parseGitHubRepository("git@gitlab.com:DataDog/dd-trace-py.git"), null);
  assert.equal(parseGitHubRepository("https://github.com/owner"), null);
  assert.equal(parseGitHubRepository("not a URL"), null);
});

test("parsePullRequestList reads the first valid PR", () => {
  assert.deepEqual(
    parsePullRequestList('[{"number":12345,"url":"https://github.com/DataDog/dd-trace-py/pull/12345"}]'),
    { number: 12345, url: "https://github.com/DataDog/dd-trace-py/pull/12345" },
  );
  assert.equal(parsePullRequestList("[]"), null);
  assert.equal(parsePullRequestList("not JSON"), null);
  assert.equal(parsePullRequestList('[{"number":1,"url":"https://example.com/pull/1"}]'), null);
});

test("formatPullRequestLink creates an OSC 8 link with the PR number", () => {
  const rendered = formatPullRequestLink({
    number: 12345,
    url: "https://github.com/DataDog/dd-trace-py/pull/12345",
  });

  assert.match(rendered, /#12345/);
  assert.match(rendered, /https:\/\/github\.com\/DataDog\/dd-trace-py\/pull\/12345/);
  assert.ok(rendered.startsWith("\x1b]8;;"));
  assert.ok(rendered.endsWith("\x1b]8;;\x1b\\"));
});
