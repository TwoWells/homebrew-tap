# TwoWells Homebrew Tap

Homebrew formulae for [Themis](https://github.com/TwoWells/Themis) — a theme orchestrator CLI for
Linux and macOS.

## Install

```sh
brew install twowells/tap/themis
```

This installs the prebuilt `themis` binary (macOS Apple Silicon and Linux x86_64) plus bash/zsh/fish
shell completions. Intel macOS and ARM Linux have no prebuilt binary; on those, build from source
(`cargo install themis-cli`) or use another channel.

## Updating the formula

The canonical formula lives in the main repo at
[`packaging/homebrew/themis.rb`](https://github.com/TwoWells/Themis/blob/main/packaging/homebrew/themis.rb).
On each Themis release, copy it here to `Formula/themis.rb` with the new version and the real
sha256s pinned (read them off the release's `themis-<target>.tar.gz.sha256` assets).
