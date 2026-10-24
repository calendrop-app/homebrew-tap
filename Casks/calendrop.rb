cask "calendrop" do
  version "0.5.1"
  sha256 "f90d0064312bfc2815ba542d90ad85d135536296e9af6b7869342b2012ab02cb"

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
