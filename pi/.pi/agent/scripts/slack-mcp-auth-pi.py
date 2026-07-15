#!/usr/bin/env python3
"""Authenticate Slack MCP for Pi only.

This script performs Slack OAuth with the callback URI registered for the
Slack MCP Claude client, then writes the resulting token to Pi's MCP OAuth
cache under ~/.pi/agent/mcp-oauth. It intentionally does not read or write
Claude Code's macOS keychain credentials.
"""

from __future__ import annotations

import base64
import hashlib
import http.server
import json
import pathlib
import secrets
import sys
import threading
import time
import urllib.parse
import urllib.request
import webbrowser

CLIENT_ID = "1601185624273.8899143856786"
CALLBACK_PORT = 3118
REDIRECT_URI = f"http://localhost:{CALLBACK_PORT}/callback"
SERVER_URL = "https://mcp.slack.com/mcp"
RESOURCE = "https://mcp.slack.com/"
AUTH_ENDPOINT = "https://slack.com/oauth/v2_user/authorize"
TOKEN_ENDPOINT = "https://slack.com/api/oauth.v2.user.access"

# Keep this aligned with the scopes requested by Pi's MCP auth-start flow.
SCOPES = " ".join(
    [
        "search:read.public",
        "search:read.private",
        "search:read.mpim",
        "search:read.im",
        "search:read.files",
        "search:read.users",
        "chat:write",
        "channels:history",
        "groups:history",
        "mpim:history",
        "im:history",
        "canvases:read",
        "canvases:write",
        "users:read",
        "users:read.email",
        "reactions:write",
        "reactions:read",
        "emoji:read",
        "files:read",
        "channels:write",
        "groups:write",
        "im:write",
        "mpim:write",
        "channels:read",
        "groups:read",
        "mpim:read",
    ]
)

PI_OAUTH_ROOT = pathlib.Path.home() / ".pi" / "agent" / "mcp-oauth"


def pkce_pair() -> tuple[str, str]:
    verifier = secrets.token_urlsafe(32)
    challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).rstrip(b"=").decode()
    return verifier, challenge


def build_auth_url(challenge: str, state: str) -> str:
    params = {
        "client_id": CLIENT_ID,
        "response_type": "code",
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPES,
        "state": state,
        "code_challenge": challenge,
        "code_challenge_method": "S256",
        "resource": RESOURCE,
    }
    return AUTH_ENDPOINT + "?" + urllib.parse.urlencode(params)


def run_local_server(expected_state: str) -> str:
    code_holder: dict[str, str] = {}
    error_holder: dict[str, str] = {}
    done = threading.Event()

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):  # noqa: N802, inherited API name
            parsed = urllib.parse.urlparse(self.path)
            params = dict(urllib.parse.parse_qsl(parsed.query))

            if parsed.path != "/callback":
                self.send_response(404)
                self.end_headers()
                return

            if params.get("state") != expected_state:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"State mismatch")
                error_holder["error"] = "state mismatch"
            elif params.get("error"):
                self.send_response(400)
                self.end_headers()
                msg = params.get("error", "unknown_error")
                self.wfile.write(f"Slack OAuth error: {msg}".encode())
                error_holder["error"] = msg
            else:
                code_holder["code"] = params.get("code", "")
                self.send_response(200)
                self.send_header("Content-type", "text/html")
                self.end_headers()
                self.wfile.write(
                    b"<html><body>"
                    b"<h2>Slack authenticated for Pi!</h2>"
                    b"<p>You can close this tab and return to the terminal.</p>"
                    b"</body></html>"
                )

            threading.Thread(target=self.server.shutdown, daemon=True).start()
            done.set()

        def log_message(self, *args):
            pass

    server = http.server.HTTPServer(("localhost", CALLBACK_PORT), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    done.wait(timeout=180)

    if error_holder:
        raise RuntimeError(error_holder["error"])
    return code_holder.get("code", "")


def exchange_code(code: str, verifier: str) -> dict:
    body = urllib.parse.urlencode(
        {
            "client_id": CLIENT_ID,
            "code": code,
            "redirect_uri": REDIRECT_URI,
            "code_verifier": verifier,
        }
    ).encode()
    req = urllib.request.Request(
        TOKEN_ENDPOINT,
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())


def find_or_create_pi_slack_cache() -> pathlib.Path:
    PI_OAUTH_ROOT.mkdir(parents=True, exist_ok=True)
    for path in PI_OAUTH_ROOT.glob("*/tokens.json"):
        try:
            data = json.loads(path.read_text())
        except Exception:
            continue
        if data.get("serverUrl") == SERVER_URL:
            return path

    # If Pi ever changes the hash scheme, this fallback may not be discovered by
    # the runtime automatically. In practice the Slack cache directory already
    # exists once Pi has attempted to connect at least once.
    fallback = PI_OAUTH_ROOT / "sha256-877c3aec832cd41012590679bdb84ebe25e5ebbd71b6b81722b48b129feb76ae" / "tokens.json"
    fallback.parent.mkdir(parents=True, exist_ok=True)
    return fallback


def write_pi_cache(verifier: str, token_result: dict) -> pathlib.Path:
    if not token_result.get("ok"):
        raise RuntimeError(f"token exchange failed: {token_result.get('error')}")

    access_token = token_result["access_token"]
    refresh_token = token_result.get("refresh_token", "")
    scope = token_result.get("scope", SCOPES.replace(" ", ","))
    expires_in = token_result.get("expires_in")
    # If Slack does not return an expiry, leave a conservative far-future value
    # to avoid Pi immediately re-entering its broken generated OAuth flow.
    expires_at = time.time() + float(expires_in if expires_in else 360 * 24 * 60 * 60)

    cache_path = find_or_create_pi_slack_cache()
    if cache_path.exists():
        backup = cache_path.with_name(f"tokens.json.backup.{time.strftime('%Y%m%d%H%M%S')}")
        backup.write_text(cache_path.read_text())
        backup.chmod(0o600)
        print(f"Backed up previous Pi Slack cache to {backup}")

    cache_data = {
        "serverUrl": SERVER_URL,
        "clientInfo": {
            "clientId": CLIENT_ID,
            "redirectUris": [REDIRECT_URI],
        },
        "codeVerifier": verifier,
        "tokens": {
            "accessToken": access_token,
            "refreshToken": refresh_token,
            "expiresAt": expires_at,
            "scope": scope,
        },
    }
    cache_path.write_text(json.dumps(cache_data, indent=2) + "\n")
    cache_path.chmod(0o600)
    cache_path.parent.chmod(0o700)
    return cache_path


def main() -> int:
    verifier, challenge = pkce_pair()
    state = secrets.token_urlsafe(16)
    auth_url = build_auth_url(challenge, state)

    print("Opening Slack OAuth in your browser for Pi-only MCP auth...")
    print(f"If the browser does not open, visit:\n  {auth_url}\n")
    webbrowser.open(auth_url)

    print(f"Waiting for callback on localhost:{CALLBACK_PORT}...")
    code = run_local_server(state)
    if not code:
        print("ERROR: No auth code received, timed out or cancelled", file=sys.stderr)
        return 1

    print("Exchanging code for Slack token...")
    token_result = exchange_code(code, verifier)
    cache_path = write_pi_cache(verifier, token_result)
    team_name = token_result.get("team", {}).get("name", "unknown")
    print(f"Authenticated to {team_name} Slack workspace")
    print(f"Wrote Pi-only Slack MCP token cache to {cache_path}")
    print("This script did not read or write Claude Code's keychain credentials.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
