# Contributing to the TwoWells tap

This tap is the **canonical home** for the Themis Homebrew formula. There is no
copy in the Themis repo to keep in sync — edit it here.

## How updates work

You normally don't touch the version or checksums by hand. The
[`bump.yml`](.github/workflows/bump.yml) workflow runs hourly, detects new
Themis releases, rewrites `Formula/themis.rb` (version + per-platform `sha256`s,
pulled from the release's `themis-<target>.tar.gz.sha256` sidecars), and opens a
PR that **auto-merges once `brew test-bot` is green** on Linux and macOS.

The bump logic lives in [`scripts/bump.sh`](scripts/bump.sh); the workflow is a
thin wrapper around it, so `make bump` runs the exact same code locally.

### A sha256 mismatch is not a checksum to "repair"

A released asset is immutable. If `brew test-bot` reports a sha mismatch, the
artifact changed under us — **investigate it as a security signal**; do not just
regenerate the hash. (This is deliberately the opposite of a source-archive
repo, where auto-generated tarballs legitimately drift.)

## Arming the automation (one-time)

The bump workflow is inert until these are set:

1. **PAT** — a fine-grained personal access token with **contents** and
   **pull-requests** write on this repo, stored as the `TAP_BUMP_TOKEN` secret.
   It must be a PAT, not `GITHUB_TOKEN`: a PR opened by `GITHUB_TOKEN` does not
   trigger `tests.yml`, so auto-merge would never see a green check.
2. **Allow auto-merge** — enable it in Settings → General.
3. **Branch protection** on `main` requiring the `test-bot` checks, so
   auto-merge actually waits for green instead of merging immediately.

## Local development

The `brew` targets need Homebrew (macOS or Linux — not a plain Arch box);
`make bump` only needs `gh` + `python3`.

```sh
make style      # brew style (rubocop)
make audit      # brew audit --strict --online
make livecheck  # what version brew livecheck detects upstream
make install    # install from this checkout
make test       # run the formula's `test do` block
make bump       # update the formula to the latest Themis release
```

CI (`tests.yml`) runs `brew test-bot` on `ubuntu-latest` + `macos-14` for every
push and PR — passing those locally via `make` matches what CI runs.
