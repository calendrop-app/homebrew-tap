# homebrew-tap

The [Homebrew](https://brew.sh/) tap for [Calendrop](https://calendrop-app.github.io/).

```sh
brew install --cask calendrop-app/tap/calendrop
```

Calendrop needs macOS 14 or later on Apple silicon. Open it once from Applications;
it lives in the menu bar.

## Update and uninstall

```sh
brew upgrade --cask calendrop
brew uninstall --cask calendrop
```

`brew uninstall --zap --cask calendrop` also removes the settings kept on this Mac.
It leaves the settings on iCloud Drive, which your other Macs share, and the
sign-in tokens in the Keychain. To delete the tokens, remove the accounts in
Calendrop's settings before uninstalling; that removes them from your other Macs
too.

The cask is rewritten by `.github/workflows/update.yml` on every release of
Calendrop.
