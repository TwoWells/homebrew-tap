# Catenary — LSP-powered code intelligence for AI coding agents. Installs the
# prebuilt release binary.
#
# This tap (TwoWells/homebrew-tap) is the canonical home for the formula —
# users run `brew install twowells/tap/catenary` (the Claude Code plugin's
# missing-binary hint suggests exactly that command). Do NOT hand-edit the
# version, the `version` line, or the sha256s: .github/workflows/bump.yml
# watches Catenary releases and opens an auto-merging PR that updates them
# (passing the bare-binary asset names explicitly — see scripts/bump.sh).
# For a manual bump, run `make bump`.
#
# A sha256 mismatch is a security signal (a released asset changed under us),
# never something to "repair" — investigate it, don't paper over it.
class Catenary < Formula
  desc "LSP-powered code intelligence for AI coding agents"
  homepage "https://github.com/TwoWells/Catenary"
  # Explicit: the release assets are bare binaries whose basenames end in
  # digits (catenary-macos-arm64 / catenary-linux-amd64), so brew's URL
  # version scanner reads "64". A bump rewrites THIS line + URLs + sha256s.
  version "2.0.2"
  license "AGPL-3.0-or-later"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # Prebuilt binaries exist only for macOS arm64 (Apple silicon — macOS 27 is
  # Apple-silicon-exclusive, so no Intel asset ships) and Linux x86_64. brew
  # audit requires every arch/OS combo to resolve a URL and only allows
  # url/sha256 inside on_arm/on_intel, so the two unsupported combos reuse
  # their OS's one binary; `install` refuses them with a clear message.
  on_macos do
    on_arm do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.0.2/catenary-macos-arm64"
      sha256 "36d91c8dd79f72eb4653ec146a8a99bd8dbe4bc763bd4e108af841fa1c6a095b"
    end
    on_intel do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.0.2/catenary-macos-arm64"
      sha256 "36d91c8dd79f72eb4653ec146a8a99bd8dbe4bc763bd4e108af841fa1c6a095b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.0.2/catenary-linux-amd64"
      sha256 "95bf3f93f276c79b21fe4a341d4a8108e2deba2f7edbebd4869f44dd4be7f7fd"
    end
    on_arm do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.0.2/catenary-linux-amd64"
      sha256 "95bf3f93f276c79b21fe4a341d4a8108e2deba2f7edbebd4869f44dd4be7f7fd"
    end
  end

  def install
    # Every arch/OS resolves a URL above (brew requires one), so the two
    # unsupported combos — Intel macOS, ARM Linux — would otherwise install a
    # wrong-arch binary. Refuse them here with a clear message instead.
    unsupported = (OS.mac? && Hardware::CPU.intel?) || (OS.linux? && Hardware::CPU.arm?)
    odie "Catenary ships prebuilt binaries for Apple-silicon macOS and x86_64 Linux only." if unsupported

    # The release asset is the bare binary, named per-platform.
    binary = Dir["catenary-*"].first
    odie "release asset not found in staging" if binary.nil?
    bin.install binary => "catenary"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/catenary version")
  end
end
