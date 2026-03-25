# disablesleep

Prevent macOS from sleeping even with the lid closed. Designed to keep Claude Code and other long-running processes alive during unattended sessions.

Uses `pmset disablesleep` under the hood (requires `sudo`).

## Usage

```bash
disablesleep          # Show current status
disablesleep on       # Enable — PC stays awake with lid closed
disablesleep off      # Disable — restore normal sleep
```

## Behavior

- **`on`**: Sets `pmset disablesleep 1` and enters a foreground loop that sends a macOS notification every 30 minutes as a reminder.
- **Ctrl-C / terminal close**: Automatically restores normal sleep via `trap`.
- **`off`**: Manually restores normal sleep (`pmset disablesleep 0`).

## Install

From the repository root:

```bash
make install-disablesleep
```

Or standalone:

```bash
cp disablesleep.sh ~/.local/bin/disablesleep
chmod +x ~/.local/bin/disablesleep
```
