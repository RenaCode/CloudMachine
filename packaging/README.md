# Packaging: releases and Homebrew

```sh
brew install --cask renacode/tap/cloudmachine
```

The cask lives in [RenaCode/homebrew-tap](https://github.com/RenaCode/homebrew-tap)
and is generated: `.github/workflows/release.yml` fills
`homebrew/cloudmachine.rb.in` with the version and the DMG's sha256 and pushes
it to the tap. Edit the template here, never the copy in the tap.

## Cutting a release

1. Bump `mac-app/VERSION` on `main`.
2. `git tag v$(cat mac-app/VERSION) && git push origin --tags`

The workflow refuses a tag that does not match `VERSION`, runs the tests,
builds a universal (Apple Silicon + Intel) `CloudMachine.app`, publishes
`CloudMachine-<version>.dmg` with its `.sha256` as a GitHub Release, and
updates the cask.

A pull request that touches the build or the cask runs the same pipeline dry:
ad-hoc signature, no release, no tap push; the DMG and the rendered cask are
attached to the run as artifacts.

## One-time setup

### 1. Signing certificate (`CM_SIGNING_P12_BASE64`, `CM_SIGNING_P12_PASSWORD`)

Releases are signed with a self-signed certificate named
`CloudMachine Release Signing`. It is not an Apple Developer ID and does not
satisfy Gatekeeper; its only job is a **stable identity**. An ad-hoc signature
changes with every build, and macOS silently withdraws Full Disk Access after
every upgrade. The release job fails rather than publish an ad-hoc build.

Generate it once and store it as repository secrets; the key never stays on
disk:

```sh
work="$(mktemp -d)"
cat >"$work/cnf" <<'CNF'
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = CloudMachine Release Signing
[v3]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
CNF
/usr/bin/openssl req -x509 -newkey rsa:2048 -sha256 -days 7300 -nodes \
  -config "$work/cnf" -keyout "$work/key.pem" -out "$work/cert.pem"
pass="$(/usr/bin/openssl rand -hex 24)"
/usr/bin/openssl pkcs12 -export -inkey "$work/key.pem" -in "$work/cert.pem" \
  -out "$work/cert.p12" -passout "pass:$pass"
base64 -i "$work/cert.p12" | gh secret set CM_SIGNING_P12_BASE64 -R RenaCode/CloudMachine
printf '%s' "$pass" | gh secret set CM_SIGNING_P12_PASSWORD -R RenaCode/CloudMachine
rm -rf "$work"
```

Do this **once**. A new certificate is a new identity: every Mac would have to
grant Full Disk Access again.

### 2. The tap repository and `HOMEBREW_TAP_TOKEN`

1. Create the public repository `RenaCode/homebrew-tap` (empty is fine; the
   workflow creates `Casks/`).
2. Create a fine-grained token limited to that repository with
   *Contents: Read and write*, and store it:
   `gh secret set HOMEBREW_TAP_TOKEN -R RenaCode/CloudMachine`

Without the token the release is still published, but the job fails and
prints the cask, so a missing tap update cannot go unnoticed.

## What the cask does and deliberately does not do

- **Removes the quarantine attribute** after install. The app is not notarized,
  so Gatekeeper would otherwise block it.
- **Does not stop launchd agents** on uninstall. Homebrew runs `uninstall`
  directives on `brew upgrade` too, and stopping `gdrive-buffer` kills the
  rclone process that holds the mount.
- **Does not reload agents** after an upgrade. Cask install steps run in a
  sandbox without access to `~/Library/LaunchAgents`, and an upgrade replaces
  the bundle with new files, after which the agents start normally.
  `drive-status` reports a watchdog that stopped running.
- **`zap` leaves `~/.cloudmachine` alone.** It holds the upload buffer, which
  may contain backups that have not reached Google Drive yet.

## Already installed from source?

`brew install` refuses to overwrite an existing `/Applications/CloudMachine.app`.
Take it over with `--adopt`, run from a terminal, not unattended:

```sh
brew install --cask --adopt renacode/tap/cloudmachine
```

The release certificate differs from the local `CloudMachine Local Signing`
one, so grant Full Disk Access once more afterwards.
