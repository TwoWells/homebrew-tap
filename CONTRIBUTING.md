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

## Editing the formula

`brew audit` / `brew style` (run by `tests.yml`) enforce a few non-obvious rules
that cost a multi-PR debugging loop to learn. Before touching `Formula/themis.rb`:

- **No explicit `version`** — it's scanned from the URL; declaring it trips the
  "redundant with version scanned from URL" audit.
- **`url`/`sha256` go inside `on_arm`/`on_intel`**, never directly in
  `on_macos`/`on_linux` (`FormulaAudit/ComponentsOrder`).
- **Every arch/OS combo must resolve a URL** or audit rejects the formula
  ("requires at least a URL"). That's why all four combos are defined and the
  two unsupported ones (Intel macOS, ARM Linux) reuse their OS's binary — the
  duplication is deliberate, not a bug. `install` refuses those combos at
  runtime with a clear error.
- **No `odie`/`raise` in the formula body** — it runs at _evaluation_ time, and
  audit evaluates every platform, so it aborts as "Invalid formula." Guard at
  install time instead.
- **Edit via a PR.** The ruleset blocks direct pushes to `main`; `tests.yml`
  (test-bot on Linux + macOS) gates the merge. Locally,
  `make style && make audit` catches most of it — on a machine with Homebrew.

## Arming the automation

Already configured; documented here so it can be rebuilt (e.g. when the PAT
expires).

1. **PAT** (the `TAP_BUMP_TOKEN` secret) — a fine-grained token with
   **resource owner = the `TwoWells` org**, repository `homebrew-tap`, and
   **Contents: Read and write** + **Pull requests: Read and write**; set via
   `gh secret set TAP_BUMP_TOKEN`. It must be a PAT, not `GITHUB_TOKEN`: a PR
   opened by `GITHUB_TOKEN` does not trigger `tests.yml`, so auto-merge would
   never see a green check. (Org-owned, so it may need owner approval.)
2. **Auto-merge** — "Allow auto-merge" and "Automatically delete head branches"
   enabled in Settings → General.
3. **Ruleset** on `main` (Settings → Rules) — require a PR with **0 approvals**,
   require the **`test-bot (ubuntu-latest)`** and **`test-bot (macos-14)`**
   checks, squash-only, block force-pushes. No bypass actors, so even
   maintainers land changes through a green PR.

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
