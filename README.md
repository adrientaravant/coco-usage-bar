# CodexUsageBar

A tiny macOS menu bar app for Codex and Claude Code usage.

Website: https://adrientaravant.github.io/codex-usage-bar/

Download: https://github.com/adrientaravant/codex-usage-bar/releases/latest/download/CodexUsageBar.zip

It stays small: no browser cookie scraping and no embedded web view. It reads local JSONL logs for token/cost usage, and reads Claude Code OAuth credentials from the local Claude Code Keychain item when available so it can show Claude limit percentages.

Codex limit percentages come from local Codex rate-limit events. Claude Code limit percentages come from the Claude Code OAuth usage endpoint using the existing `Claude Code-credentials` Keychain item or `~/.claude/.credentials.json` fallback. Tokens are never printed or stored by this app.

## What It Shows

Menu bar:

- Codex and Claude Code provider marks.
- Each provider shows its 5-hour usage percent when local limit data is available.
- Codex can fall back to the last 30 days token total if limit data is missing.
- Claude Code is hidden from the menu bar only when its limit percent is unavailable, because showing only token volume there is too noisy.
- Providers with no data are hidden from the menu bar.

Menu:

- Updated timestamp.
- Codex 5-hour and weekly limit windows when available.
- Claude Code 5-hour and weekly limit windows when available from local Claude Code OAuth credentials.
- Last 30 days tokens for each provider with local usage.
- Refresh and Quit.

## Data Sources

- Codex: `~/.codex/sessions/**/*.jsonl`
- Claude Code: `~/.claude/projects/**/*.jsonl`
- Claude Code limits: Keychain item `Claude Code-credentials`, with `~/.claude/.credentials.json` fallback.

The app caches the latest computed snapshot in `~/Library/Application Support/CodexUsageBar/snapshot.json`, then refreshes in the background so launch stays snappy.

## Cost Notes

The menu intentionally does not show dollar estimates. Codex and Claude Code are subscription products here, and API-equivalent pricing can look wildly high when local logs include billions of prompt-cache read tokens. Treat token volume and limit percentages as the useful signals.

- Codex uses a default GPT-5.4 short-context estimate.
- Claude Code estimates by model family when the local log line includes the model name.
- Prompt cache reads/writes are estimated separately when the logs expose them.

The price table remains local code in `Sources/CodexUsageBar/main.swift` for diagnostic snapshots, but it is not presented as spend in the menu.

## Install

Build, install into `/Applications`, and launch:

```bash
./script/install.sh
```

Install and add a login item:

```bash
./script/install.sh --login
```

Run from the working tree:

```bash
./script/build_and_run.sh
```

Print a one-shot snapshot:

```bash
./script/build_and_run.sh --print-snapshot
```

## Sharing With Teammates

Fast path:

1. Open https://adrientaravant.github.io/codex-usage-bar/
2. Click Download.
3. Unzip `CodexUsageBar.zip`.
4. Move `CodexUsageBar.app` to `/Applications`.
5. Open it once.

The current public zip is ad-hoc signed, not Developer ID signed or notarized. macOS may require right-click > Open the first time. For a true one-click install with no Gatekeeper warning, publish a Developer ID signed and notarized release.

Source install:

1. Clone the repo.
2. Run:

```bash
./script/install.sh --login
```

This builds locally, installs `/Applications/CodexUsageBar.app`, and adds it as a login item.

You can also build a quick internal zip:

```bash
./script/package.sh
```

That writes `dist/CodexUsageBar.zip` and `dist/CodexUsageBar.zip.sha256`. Without a Developer ID certificate, macOS may warn teammates when they open the downloaded app. For a small internal group, the source-install path is smoother.

Polished distribution:

1. Join/use an Apple Developer team.
2. Create a Developer ID Application certificate.
3. Build with `SIGN_IDENTITY="Developer ID Application: ..."` `./script/package.sh`.
4. Notarize the zip with `xcrun notarytool`.
5. Attach the notarized zip to a GitHub Release.

Update options:

- Simple: publish a new GitHub Release and tell teammates to replace the app.
- Low-maintenance: add a Homebrew Cask once the repo has releases.
- Best app experience: add Sparkle with an appcast so the menu bar app can self-update.

I would start with GitHub Releases, then add Sparkle only if more than a few people use it daily.

## Open Source Notes

- MIT licensed.
- Uses tiny bundled template PNG provider marks for Codex and Claude Code.
- Provider names and marks may be trademarks of their respective owners; replace the bundled marks before public distribution if you want a stricter trademark posture.
- Works best when `rg` is available. The app looks for Codex's bundled `rg`, Homebrew `rg`, and common system locations, then falls back to a pure Swift scan.
