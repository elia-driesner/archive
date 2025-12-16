#!/usr/bin/env python3
"""
Fetch all public repositories for a GitHub user and clone each into the
current directory using the pattern: <repo_name>-<DD-MM-YYYY_of_last_update>.
After cloning, remove each repo's inner .git directory so everything can live
as one monorepo-style workspace.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


API_ROOT = "https://api.github.com"
DEFAULT_PER_PAGE = 100


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Clone all public repositories for a GitHub user into folders "
            "named <repo>-<DD-MM-YYYY_of_last_update>."
        )
    )
    parser.add_argument(
        "--user",
        default="elia-driesner",
        help="GitHub username (default: elia-driesner)",
    )
    parser.add_argument(
        "--max",
        type=int,
        default=None,
        help="Maximum number of repositories to process (default: all)",
    )
    parser.add_argument(
        "--token",
        default=None,
        help="GitHub token; if omitted, falls back to GITHUB_TOKEN env var",
    )
    return parser.parse_args()


def fetch_repos(user: str, max_repos: Optional[int], token: Optional[str]) -> List[Dict[str, Any]]:
    repos: List[Dict[str, Any]] = []
    page = 1

    while True:
        per_page = min(DEFAULT_PER_PAGE, max_repos - len(repos)) if max_repos else DEFAULT_PER_PAGE
        url = (
            f"{API_ROOT}/users/{quote(user)}/repos"
            f"?per_page={per_page}&page={page}&type=owner&sort=updated"
        )
        headers = {
            "Accept": "application/vnd.github+json",
            "User-Agent": "fetch-github-repos-script",
        }
        if token:
            headers["Authorization"] = f"Bearer {token}"

        try:
            with urlopen(Request(url, headers=headers)) as resp:
                payload = json.load(resp)
        except HTTPError as exc:
            error_body = exc.read().decode("utf-8", errors="ignore") if hasattr(exc, "read") else ""
            print(f"[error] HTTP {exc.code} fetching repos: {exc.reason}\n{error_body}", file=sys.stderr)
            sys.exit(1)
        except URLError as exc:
            print(f"[error] Network error fetching repos: {exc.reason}", file=sys.stderr)
            sys.exit(1)

        if not isinstance(payload, list):
            print("[error] Unexpected response from GitHub API", file=sys.stderr)
            sys.exit(1)

        if not payload:
            break

        repos.extend(payload)

        if max_repos and len(repos) >= max_repos:
            repos = repos[:max_repos]
            break

        if len(payload) < per_page:
            break

        page += 1

    return repos


def format_date(updated_at: str) -> str:
    try:
        dt = datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        dt = datetime.fromisoformat(updated_at.replace("Z", "+00:00"))
    return dt.strftime("%d-%m-%Y")


def clone_repo(clone_url: str, target_dir: Path) -> bool:
    try:
        subprocess.run(
            ["git", "clone", clone_url, str(target_dir)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        print(f"[ok] Cloned to {target_dir}")
        return True
    except subprocess.CalledProcessError as exc:
        stdout = exc.stdout.decode("utf-8", errors="ignore")
        stderr = exc.stderr.decode("utf-8", errors="ignore")
        print(f"[error] git clone failed for {target_dir}\n{stdout}\n{stderr}", file=sys.stderr)
        return False


def remove_git_dir(target_dir: Path) -> None:
    git_dir = target_dir / ".git"
    if not git_dir.exists():
        print(f"[info] No .git to remove in {target_dir}")
        return

    try:
        shutil.rmtree(git_dir)
        print(f"[ok] Removed {git_dir} to flatten into monorepo")
    except OSError as exc:
        print(f"[warn] Failed to remove {git_dir}: {exc}", file=sys.stderr)


def process_repos(repos: Iterable[Dict[str, Any]]) -> None:
    for repo in repos:
        name = repo.get("name")
        updated_at = repo.get("updated_at")
        clone_url = repo.get("clone_url")

        if not name or not updated_at or not clone_url:
            print(f"[skip] Missing data for repo entry: {repo}", file=sys.stderr)
            continue

        folder_name = f"{name}-{format_date(updated_at)}"
        target_dir = Path.cwd() / folder_name

        if target_dir.exists():
            print(f"[skip] {target_dir} already exists")
            continue

        if clone_repo(clone_url, target_dir):
            remove_git_dir(target_dir)


def main() -> None:
    args = parse_args()
    token = args.token or os.getenv("GITHUB_TOKEN")

    print(f"[info] Fetching repos for user '{args.user}' (max={args.max or 'all'})")
    if token:
        print("[info] Using provided GitHub token for requests")

    repos = fetch_repos(args.user, args.max, token)
    if not repos:
        print("[info] No repositories found")
        return

    print(f"[info] Retrieved {len(repos)} repos; starting clones")
    process_repos(repos)


if __name__ == "__main__":
    main()

