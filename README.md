# Zellij-Sweep

Zellij-Sweep is a macOS menu bar utility for viewing, pinning, and deleting
[Zellij](https://zellij.dev/) sessions.

It is built with SwiftUI and Tuist, and runs as a menu bar-only app.

## Features

- View current Zellij sessions from the macOS menu bar.
- Delete individual sessions.
- Force delete active sessions when Zellij requires `--force`.
- Pin sessions to hide delete actions and protect them from accidental cleanup.
- Force delete all unpinned sessions.
- Show delete errors directly on the affected session row.

## Requirements

- macOS 14 or newer
- Xcode
- [Tuist](https://tuist.dev/)
- [Zellij](https://zellij.dev/) available on `PATH`

Zellij-Sweep looks for `zellij` through `/usr/bin/env` and includes common
Homebrew paths such as `/opt/homebrew/bin` and `/usr/local/bin`.

## Run Locally

```bash
./run-menubar.sh
```

The script regenerates the Tuist project, builds the app, stops any currently
running instance, and opens the new build.

To stop the app manually:

```bash
./stop-menubar.sh
```

## Build

```bash
TUIST_SKIP_UPDATE_CHECK=1 tuist generate --no-open
TUIST_SKIP_UPDATE_CHECK=1 tuist xcodebuild build -scheme Zellij-Sweep -configuration Debug
```

Generated Xcode projects and workspaces are intentionally ignored. `Project.swift`
is the source of truth.

## Safety Model

Pinned sessions are protected from deletion. When a session is pinned, its delete
and force-delete controls are hidden, and bulk cleanup skips it.

If Zellij reports that a session is active and requires `--force`, Zellij-Sweep
shows a red `Force` button only for that row.

## License

Zellij-Sweep is released under the MIT License. See [LICENSE](LICENSE).
