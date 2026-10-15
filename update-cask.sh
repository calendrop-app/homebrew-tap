#!/usr/bin/env bash
# Write Casks/calendrop.rb for the latest release of Calendrop from the app it
# ships. The latest, not a given one: a prerelease or a rerun of an older
# release would otherwise hand that version to every brew upgrade.
set -euo pipefail

tag="$(gh release view --repo calendrop-app/Calendrop --json tagName --jq .tagName)"
version="${tag#v}"
root="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

zip="Calendrop-$version-macos-arm64.zip"
gh release download "$tag" --repo calendrop-app/Calendrop --pattern "$zip" --dir "$work"
sha256="$(sha256sum "$work/$zip" | cut -d' ' -f1)"

mkdir -p "$root/Casks"
cat >"$root/Casks/calendrop.rb" <<RUBY
cask "calendrop" do
  version "$version"
  sha256 "$sha256"

  url "https://github.com/calendrop-app/Calendrop/releases/download/v#{version}/Calendrop-#{version}-macos-arm64.zip"
  name "Calendrop"
  desc "Menu bar app that covers every screen before your next Google Calendar meeting"
  homepage "https://calendrop-app.github.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Calendrop.app"

  # Calendrop is signed by its own identity rather than notarized, so Gatekeeper
  # would refuse it while it carries the quarantine Homebrew gives downloads.
  preflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "Calendrop.app"], chdir: "{{staged_path}}"
  end

  uninstall quit: "com.lambdalisue.calendrop"

  # The settings on iCloud Drive are shared with the user's other Macs, so zap
  # leaves them; the sign-in tokens live in the Keychain, which zap cannot reach.
  zap trash: [
    "~/Library/Application Support/Calendrop",
    "~/Library/Preferences/com.lambdalisue.calendrop.plist",
  ]

  caveats <<~EOS
    macOS asks once for Keychain access after each update, even when it was
    always allowed: Calendrop is signed without an Apple team ID, so macOS ties
    that answer to the build.
  EOS
end
RUBY
