# TwoWells Homebrew Tap

Homebrew formulae for TwoWells tools:

- **[Themis](https://github.com/TwoWells/Themis)** — a theme orchestrator CLI for Linux and macOS.
- **[Lattice](https://github.com/TwoWells/Lattice)** — a markdown predicate linter and backlink
  reconciler, shipped as an LSP server.
- **[Catenary](https://github.com/TwoWells/Catenary)** — LSP-powered code intelligence for AI
  coding agents.

## Install

```sh
brew install twowells/tap/themis
brew install twowells/tap/lattice
brew install twowells/tap/catenary
```

Each formula installs the prebuilt binary (Themis also ships bash/zsh/fish shell completions).
The only targets these projects ship are **macOS Apple Silicon** and **Linux x86_64**; on Intel
macOS or ARM Linux `brew install` stops with a clear "no prebuilt binary" error — build from
source there instead.

## How it stays current

This tap is the **canonical home** for these formulae. An hourly GitHub Actions job
([`bump.yml`](.github/workflows/bump.yml), one matrix job per formula) watches upstream releases;
when a new version ships it opens a pull request that bumps the version and the per-platform
`sha256`s (read from the release's `.sha256` sidecar assets, falling back to hashing the
assets themselves). That PR **auto-merges once
[`brew test-bot`](.github/workflows/tests.yml) is green** on both Linux and macOS.

No manual copy step. To force a check or bump the formulae locally, run `make bump`. Other dev
helpers (`make style`, `make audit`, `make test` — per-formula via `FORMULA=Formula/<name>.rb`)
are listed via `make help` — see [CONTRIBUTING.md](./CONTRIBUTING.md).
