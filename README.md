# TwoWells Homebrew Tap

Homebrew formulae for [Themis](https://github.com/TwoWells/Themis) — a theme orchestrator CLI for
Linux and macOS.

## Install

```sh
brew install twowells/tap/themis
```

This installs the prebuilt `themis` binary plus bash/zsh/fish shell completions. The only targets
Themis ships are **macOS Apple Silicon** and **Linux x86_64**; on Intel macOS or ARM Linux
`brew install` stops with a clear "no prebuilt binary" error — build [Themis](https://github.com/TwoWells/Themis)
from source there instead.

## How it stays current

This tap is the **canonical home** for the `themis` formula. An hourly GitHub Actions job
([`bump.yml`](.github/workflows/bump.yml)) watches Themis releases; when a new version ships it opens
a pull request that bumps the version and the per-platform `sha256`s (read from the release's
`themis-<target>.tar.gz.sha256` assets). That PR **auto-merges once [`brew test-bot`](.github/workflows/tests.yml)
is green** on both Linux and macOS.

No manual copy step. To force a check or bump the formula locally, run `make bump`. Other dev helpers
(`make style`, `make audit`, `make test`) are listed via `make help` — see
[CONTRIBUTING.md](./CONTRIBUTING.md).
