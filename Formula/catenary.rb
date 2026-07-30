# Catenary — LSP-powered code intelligence for AI coding agents. Installs the
# prebuilt release binary.
#
# This tap (TwoWells/homebrew-tap) is the canonical home for the formula —
# users run `brew install twowells/tap/catenary` (the Claude Code plugin's
# missing-binary hint suggests exactly that command). Do NOT hand-edit the
# version or the sha256s: .github/workflows/bump.yml
# watches Catenary releases and opens an auto-merging PR that updates them
# (passing the bare-binary asset names explicitly — see scripts/bump.sh).
# For a manual bump, run `make bump`.
#
# A sha256 mismatch is a security signal (a released asset changed under us),
# never something to "repair" — investigate it, don't paper over it.
class Catenary < Formula
  desc "LSP-powered code intelligence for AI coding agents"
  homepage "https://github.com/TwoWells/Catenary"
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
  # The version is scanned from the release-URL path (/download/vX.Y.Z/), so
  # a bump just rewrites URLs + shas.
  on_macos do
    on_arm do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.1.2/catenary-macos-arm64"
      sha256 "4b072ff69760de093daf9d315b7ed3f33967bb2924e8b06ebd1f912638a3d48f"
    end
    on_intel do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.1.2/catenary-macos-arm64"
      sha256 "4b072ff69760de093daf9d315b7ed3f33967bb2924e8b06ebd1f912638a3d48f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.1.2/catenary-linux-amd64"
      sha256 "0bde1c25253e8dc7bcae6efe6c1148138cb593d51ebb8150147843f33a06eb4d"
    end
    on_arm do
      url "https://github.com/TwoWells/Catenary/releases/download/v2.1.2/catenary-linux-amd64"
      sha256 "0bde1c25253e8dc7bcae6efe6c1148138cb593d51ebb8150147843f33a06eb4d"
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
