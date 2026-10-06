# Building CloudMachine from source

Most people install with Homebrew (see the [README](../README.md)). This page is
for working on CloudMachine itself: building, running a local build, releases
and the measurement harnesses.

## Requirements

- macOS 14 (Sonoma) or newer
- Xcode, or a Swift 5.9+ toolchain
- `swift-format` for the lint CI runs: `brew install swift-format`

## Build and install a local copy

```sh
cd mac-app
swift run cloudmachine-agent setup-signing-cert   # optional, once per Mac
swift run cloudmachine-agent build-app            # -> mac-app/build/CloudMachine.app
rm -rf /Applications/CloudMachine.app             # never copy over a live bundle
cp -R build/CloudMachine.app /Applications/
```

Removing the installed copy first is not optional. `cp -R` onto an existing
bundle overwrites its files in place; macOS still holds the old signature for
them and kills every agent started from the bundle
(`last exit reason = OS_REASON_CODESIGNING`), while `codesign --verify` keeps
passing. Removed and copied anew, the files get new identities. The mount
survives this: the rclone process that holds it lives outside the bundle.

`build-app` puts the menu-bar app and `cloudmachine-agent` side by side in
`Contents/MacOS/`, with the launchd templates as resources, so the installed app
does not need the repository next to it. It must live in `/Applications`: the
launchd agent that starts the app opens `/Applications/CloudMachine.app`.

`setup-signing-cert` creates a local, self-signed code-signing certificate in the
login keychain. Without it every build is signed ad hoc with a new identity, and
macOS revokes permissions such as Full Disk Access after each rebuild. With it,
`build-app` signs with that certificate automatically. A Homebrew release is
signed with a different certificate, so switching between a local build and a
release needs Full Disk Access granted once more.

`swift run cloudmachine-agent make-dmg` packs the built app into
`mac-app/build/CloudMachine-<version>.dmg`; `build-app --universal` builds for
both architectures, as releases do. The version comes from `mac-app/VERSION`,
and `cloudmachine-agent version` prints it together with the build number and
the commit the binary was built from.

## Tests and lint

```sh
cd mac-app
swift test
swift format lint --strict --recursive Sources Tests
```

`L10nTests` fail on any Polish left outside the Polish translation tables, and
on any `L10n.tr` key without a Polish entry. User-facing text goes through
`L10n.tr("English text")` with a Polish entry in
`Sources/CloudMachineCore/L10nPolish+*.swift`; logs stay English.

## Releases

Every merge to `main` that changes the app is released automatically by
`.github/workflows/release.yml` and published to Homebrew. How the version is
chosen and the one-time setup (signing certificate, tap token) are in
[`packaging/README.md`](../packaging/README.md).

## Measurement harnesses

The measurements behind the design — write amplification per band size, and
what survives the cloud layer dying mid-write — are written up in
[`gdrive/README.md`](../gdrive/README.md). The harnesses that produced them are
the separate `cloudmachine-poc` executable (`swift run cloudmachine-poc --help`).
It is deliberately not part of the app bundle: every harness creates and
deletes disk images.
