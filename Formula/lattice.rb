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
      url "https://github.com/TwoWells/Lattice/releases/download/v0.7.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "e85a11b12159022df4a456f661af0fa9cff496c721a4cd5119f414dc1b9995a8"
    end
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.7.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "e85a11b12159022df4a456f661af0fa9cff496c721a4cd5119f414dc1b9995a8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.7.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "60155c84a3303b66f3991782ad5c9978b188237f9aca44b118c7a107ca6b9c32"
    end
    on_arm do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.7.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "60155c84a3303b66f3991782ad5c9978b188237f9aca44b118c7a107ca6b9c32"
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
