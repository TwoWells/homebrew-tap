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
      url "https://github.com/TwoWells/Lattice/releases/download/v0.6.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "9d35e951f72c7d049a4b34e527287ddfc857bd84703872c5678b489452c3ee01"
    end
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.6.0/lattice-aarch64-apple-darwin.tar.gz"
      sha256 "9d35e951f72c7d049a4b34e527287ddfc857bd84703872c5678b489452c3ee01"
    end
  end

  on_linux do
    # brew's URL scanner misparses the x86_64 basename as
    # "64-unknown-linux-gnu", so Linux pins the version explicitly. macOS scans
    # its aarch64 URL fine — and audit rejects a redundant global pin — so the
    # pin lives only here. bump.sh rewrites this line along with URLs + shas.
    # (The ComponentsOrder cop objects to per-OS version pins; CI and
    # `make style` run brew style with --except-cops for it.)
    version "0.6.0"
    on_intel do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.6.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "34944be80ff0f97dd267a08c98434b6563eb286cc071aefaa2647083462789d2"
    end
    on_arm do
      url "https://github.com/TwoWells/Lattice/releases/download/v0.6.0/lattice-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "34944be80ff0f97dd267a08c98434b6563eb286cc071aefaa2647083462789d2"
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
