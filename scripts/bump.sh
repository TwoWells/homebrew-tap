#!/usr/bin/env bash
set -euo pipefail

# bump.sh: detect the latest Themis release and update Formula/themis.rb in
# place. Shared by `make bump` and .github/workflows/bump.yml.
#
# Requires: gh (authenticated), python3. Writes BUMPED/VERSION to GITHUB_OUTPUT
# when running under Actions; otherwise just edits the file and prints a summary.

REPO="TwoWells/Themis"
FORMULA="Formula/themis.rb"

out() { echo "$1" >> "${GITHUB_OUTPUT:-/dev/null}"; }

latest_tag=$(gh api "repos/${REPO}/releases/latest" --jq .tag_name)
latest_ver=${latest_tag#v}
current_ver=$(awk -F'"' '/^[[:space:]]*version "/{print $2; exit}' "$FORMULA")

echo "current: ${current_ver}  latest: ${latest_ver}"
if [ "$current_ver" = "$latest_ver" ]; then
    echo "Formula is up to date."
    out "BUMPED=false"
    exit 0
fi

# Pull the per-target sha256 sidecars published alongside the release assets.
fetch_sha() {
    gh release download "$latest_tag" --repo "$REPO" --pattern "$1.sha256" --output - | awk '{print $1}'
}
sha_darwin_arm=$(fetch_sha "themis-aarch64-apple-darwin.tar.gz")
sha_linux_x86=$(fetch_sha "themis-x86_64-unknown-linux-gnu.tar.gz")

# Rewrite the version line and each platform's sha256. The sha is matched via
# the release filename on the url line directly above it, so the right hash
# always lands in the right on_os block regardless of ordering.
NEW_VER="$latest_ver" SHA_DARWIN="$sha_darwin_arm" SHA_LINUX="$sha_linux_x86" \
    python3 - "$FORMULA" << 'PY'
import os, re, sys

path = sys.argv[1]
s = open(path).read()
s = re.sub(r'version "[^"]+"', f'version "{os.environ["NEW_VER"]}"', s, count=1)
s = re.sub(r'(themis-aarch64-apple-darwin\.tar\.gz"\s*\n\s*sha256 ")[0-9a-f]{64}',
           lambda m: m.group(1) + os.environ["SHA_DARWIN"], s)
s = re.sub(r'(themis-x86_64-unknown-linux-gnu\.tar\.gz"\s*\n\s*sha256 ")[0-9a-f]{64}',
           lambda m: m.group(1) + os.environ["SHA_LINUX"], s)
open(path, "w").write(s)
PY

echo "Bumped ${FORMULA} to ${latest_ver}"
out "BUMPED=true"
out "VERSION=${latest_ver}"
