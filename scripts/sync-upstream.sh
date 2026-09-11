#!/usr/bin/env bash
# Mirror only a fetched upstream Git tree. Never execute upstream content.
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
upstream_url="${UPSTREAM_URL:-https://github.com/wusel76/Prophet2012.git}"
sync_tmp="$(mktemp -d)"
trap 'rm -rf "$sync_tmp"' EXIT

git init --quiet "$sync_tmp/repo"
git -C "$sync_tmp/repo" fetch --quiet --depth=1 "$upstream_url" HEAD
upstream_sha="$(git -C "$sync_tmp/repo" rev-parse FETCH_HEAD)"
mkdir "$sync_tmp/tree"
git -C "$sync_tmp/repo" archive "$upstream_sha" | tar -x -C "$sync_tmp/tree"
archive_path="$repo_root/legacy-prophet2012"
if [[ -L "$archive_path" || ! -d "$archive_path" ]]; then
  echo 'Expected an existing, non-symlink legacy-prophet2012 directory.' >&2
  exit 1
fi
# Preserve the explicitly curated local reference section and HTML snapshots.
python3 - "$archive_path/README.md" "$sync_tmp/reference-section" <<'PYSECTION'
from pathlib import Path
import sys
source = Path(sys.argv[1])
text = source.read_text() if source.exists() else ""
start = "<!-- archived-reference-materials:start -->"
end = "<!-- archived-reference-materials:end -->"
if start in text:
    section = text.split(start, 1)[1].split(end, 1)
    if len(section) != 2:
        raise SystemExit("Unclosed archived reference section; refusing to sync")
    Path(sys.argv[2]).write_text(start + section[0] + end + "\n")
PYSECTION
rsync -a --delete \
  --exclude='/docs/Prophet2012_WebArchive.html' \
  --exclude='/docs/Prophet2012_Manual.html' \
  "$sync_tmp/tree/" "$archive_path/"
if [[ -f "$sync_tmp/reference-section" ]]; then
  # Upstream symlinks must never redirect writes outside the archive.
  if [[ -L "$archive_path/README.md" ]]; then
    echo 'Upstream README is a symlink; refusing to append local references.' >&2
    exit 1
  fi
  printf '\n\n' >> "$archive_path/README.md"
  cat "$sync_tmp/reference-section" >> "$archive_path/README.md"
fi
printf 'Mirrored upstream commit %s\n' "$upstream_sha"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  printf 'sha=%s\n' "$upstream_sha" >> "$GITHUB_OUTPUT"
fi
