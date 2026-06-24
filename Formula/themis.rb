# Themis — theme orchestrator CLI. Installs the prebuilt release binary.
#
# This tap (TwoWells/homebrew-tap) is the canonical home for the formula —
# users run `brew install twowells/tap/themis`. Do NOT hand-edit the version or
# the sha256s: .github/workflows/bump.yml watches Themis releases and opens an
# auto-merging PR that updates them, reading the published
# themis-<target>.tar.gz.sha256 sidecars. For a manual bump, run `make bump`.
#
# A sha256 mismatch is a security signal (a released asset changed under us),
# never something to "repair" — investigate it, don't paper over it.
class Themis < Formula
  desc "Theme orchestrator CLI for Linux and macOS"
  homepage "https://github.com/TwoWells/Themis"
  license "AGPL-3.0-or-later"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # Prebuilt binaries exist for macOS arm64 and Linux x86_64. Each OS points at
  # its one binary so every platform brew audits resolves a URL (an unresolved
  # URL fails `brew audit`); macOS Intel / ARM Linux land on the wrong-arch
  # binary and fail at runtime, which is acceptable for those rare targets. The
  # version is scanned from the URL, so a bump just rewrites the URLs + shas.
  on_macos do
    url "https://github.com/TwoWells/Themis/releases/download/v0.1.0/themis-aarch64-apple-darwin.tar.gz"
    sha256 "623693a8ab3b89acaa91713782cac160834906c5d1d2a12aa38c77121ecd9558"
  end

  on_linux do
    url "https://github.com/TwoWells/Themis/releases/download/v0.1.0/themis-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "3ce410c9ecb6381454054ecdb130b985c1f2423194f1ba621fafa4be92bae194"
  end

  def install
    # The release tarball ships only the `themis` binary at its root.
    bin.install "themis"

    # Generate + install shell completions from the binary itself
    # (defaults to bash/zsh/fish).
    generate_completions_from_executable(bin/"themis", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/themis --version")
  end
end
