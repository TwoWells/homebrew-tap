#!/usr/bin/env bash
set -euo pipefail

# bump.sh: detect the latest upstream release for one formula and update
# Formula/<name>.rb in place. Shared by `make bump` and
# .github/workflows/bump.yml (which runs it once per formula via its matrix).
#
# Usage: bump.sh <formula-name> <owner/repo> [<darwin-asset> <linux-asset>]
#   e.g. bump.sh themis TwoWells/Themis
#        bump.sh lattice TwoWells/Lattice
#        bump.sh catenary TwoWells/Catenary catenary-macos-arm64 catenary-linux-amd64
#
# The asset names default to the tap convention — prebuilt
# <name>-<target>.tar.gz release assets for aarch64-apple-darwin and
# x86_64-unknown-linux-gnu. Catenary ships bare per-platform binaries instead,
# so it passes its basenames explicitly.
#
# The version must be embedded in the release-download URLs. If the formula
# also pins an explicit `version "…"` line (catenary does — brew's URL scanner
# reads "64" from its bare-binary basenames), that line is rewritten too; the
# rewrite is a no-op for formulae that let brew scan the URL.
#
# Requires: gh (authenticated), python3. Writes BUMPED/VERSION to GITHUB_OUTPUT
# under Actions; otherwise just edits the file and prints a summary.

NAME="${1:?usage: bump.sh <formula-name> <owner/repo> [<darwin-asset> <linux-asset>]}"
REPO="${2:?usage: bump.sh <formula-name> <owner/repo> [<darwin-asset> <linux-asset>]}"
DARWIN_ASSET="${3:-${NAME}-aarch64-apple-darwin.tar.gz}"
LINUX_ASSET="${4:-${NAME}-x86_64-unknown-linux-gnu.tar.gz}"
FORMULA="Formula/${NAME}.rb"

out() { echo "${1}" >>"${GITHUB_OUTPUT:-/dev/null}"; }

# Per-target sha256: read the published .sha256 sidecar; if the release
# predates sidecars, fall back to downloading the asset and hashing it.
fetch_sha() {
  gh release download "${latest_tag}" --repo "${REPO}" --pattern "${1}.sha256" --output - 2>/dev/null | awk '{print $1}' ||
    gh release download "${latest_tag}" --repo "${REPO}" --pattern "${1}" --output - | sha256sum | awk '{print $1}'
}

latest_tag="$(gh api "repos/${REPO}/releases/latest" --jq .tag_name)"
latest_ver="${latest_tag#v}"
current_ver="$(sed -n 's#.*releases/download/v\([^/]*\)/.*#\1#p' "${FORMULA}" | head -n1)"

echo "${NAME} — current: ${current_ver}  latest: ${latest_ver}"
if [[ "${current_ver}" == "${latest_ver}" ]]
then
  echo "Formula is up to date."
  out "BUMPED=false"
  exit 0
fi

sha_darwin_arm="$(fetch_sha "${DARWIN_ASSET}")"
sha_linux_x86="$(fetch_sha "${LINUX_ASSET}")"

# Rewrite the version in both release URLs, any explicit `version "…"` line,
# and each platform's sha256. Each sha is matched via the release filename on
# the url line above it, so the right hash always lands in the right on_os
# block.
DARWIN_ASSET="${DARWIN_ASSET}" LINUX_ASSET="${LINUX_ASSET}" \
  NEW_VER="${latest_ver}" SHA_DARWIN="${sha_darwin_arm}" SHA_LINUX="${sha_linux_x86}" \
  python3 - "${FORMULA}" <<'PY'
import os, re, sys

path = sys.argv[1]
darwin = re.escape(os.environ["DARWIN_ASSET"])
linux = re.escape(os.environ["LINUX_ASSET"])
s = open(path).read()
s = re.sub(r'(releases/download/)v[^/]+(/)', rf'\g<1>v{os.environ["NEW_VER"]}\g<2>', s)
s = re.sub(r'(?m)^(\s*version ")[^"]+', rf'\g<1>{os.environ["NEW_VER"]}', s)
s = re.sub(rf'({darwin}"\s*\n\s*sha256 ")[0-9a-f]{{64}}',
           lambda m: m.group(1) + os.environ["SHA_DARWIN"], s)
s = re.sub(rf'({linux}"\s*\n\s*sha256 ")[0-9a-f]{{64}}',
           lambda m: m.group(1) + os.environ["SHA_LINUX"], s)
open(path, "w").write(s)
PY

echo "Bumped ${FORMULA} to ${latest_ver}"
out "BUMPED=true"
out "VERSION=${latest_ver}"
