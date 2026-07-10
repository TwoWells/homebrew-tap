# Lattice — markdown predicate linter and backlink reconciler, shipped as an
# LSP server. Installs the prebuilt release binary.
#
# This tap (TwoWells/homebrew-tap) is the canonical home for the formula —
# users run `brew install twowells/tap/lattice`. Do NOT hand-edit the version
# or the sha256s: .github/workflows/bump.yml watches Lattice releases and opens
# an auto-merging PR that updates them, reading the published
# lattice-<target>.tar.gz.sha256 sidecars. For a manual bump, run `make bump`.
#
# A sha256 mismatch is a security signal (a released asset changed under us),
# never something to "repair" — investigate it, don't paper over it.
class Lattice < Formula
  desc "Markdown predicate linter and backlink reconciler, shipped as an LSP server"
  homepage "https://github.com/TwoWells/Lattice"
  license "AGPL-3.0-or-later"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # Prebuilt binaries exist only for macOS arm64 and Linux x86_64. brew audit
  # requires every arch/OS combo to resolve a URL and only allows url/sha256
  # inside on_arm/on_intel, so the two unsupported combos reuse their OS's one
  # binary (wrong-arch, fails at runtime — acceptable for those rare targets).
  # The version is scanned from the URL, so a bump just rewrites URLs + shas.
  on_macos do
    on_arm do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.5.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "c6744d85f5eb3c4fe2615595c7235f48d2a7d3ec661c32f74f5b8507bb3f1dc6"
    end
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.5.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "c6744d85f5eb3c4fe2615595c7235f48d2a7d3ec661c32f74f5b8507bb3f1dc6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.5.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "88cf24373f631db6f3e7a6e2e599efb58d05f3fc2f9c960f633893a9ce5fb664"
    end
    on_arm do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.5.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "88cf24373f631db6f3e7a6e2e599efb58d05f3fc2f9c960f633893a9ce5fb664"
    end
  end

  def install
    # Every arch/OS resolves a URL above (brew requires one), so the two
    # unsupported combos — Intel macOS, ARM Linux — would otherwise install a
    # wrong-arch binary. Refuse them here with a clear message instead.
    unsupported = (OS.mac? && Hardware::CPU.intel?) || (OS.linux? && Hardware::CPU.arm?)
    odie "Lattice has no prebuilt binary for this platform." if unsupported

    # The release tarball ships only the `lattice` binary at its root.
    bin.install "lattice"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lattice --version")
  end
end
