#!/bin/bash
# Prevent macOS from sleeping even with lid closed.
# Usage:
#   disablesleep on    Enable (keeps PC awake)
#   disablesleep off   Disable (restore normal sleep)
#   disablesleep       Show current status
#
# While active, sends a macOS notification every 30 min as a reminder.
# Ctrl-C or 'disablesleep off' to restore normal sleep.

set -euo pipefail

_status() {
  if pmset -g | grep -q 'DisableSleep.*1'; then
    echo "disablesleep: ON (PC will not sleep with lid closed)"
    return 0
  else
    echo "disablesleep: OFF (normal sleep behavior)"
    return 1
  fi
}

_on() {
  sudo pmset disablesleep 1
  echo "disablesleep ON — PC will stay awake with lid closed."
  echo "Press Ctrl-C or run 'disablesleep off' to restore."

  # Restore on exit
  trap '_off_quiet' EXIT INT TERM

  # Notification reminder loop
  while true; do
    sleep 1800
    osascript -e 'display notification "disablesleep is ON. Run: disablesleep off" with title "⚠️ disablesleep" sound name "Ping"'
  done
}

_off_quiet() {
  sudo pmset disablesleep 0 2>/dev/null || true
  echo "disablesleep OFF — normal sleep behavior restored."
}

_off() {
  sudo pmset disablesleep 0
  echo "disablesleep OFF — normal sleep behavior restored."
}

case "${1:-}" in
  on)  _on ;;
  off) _off ;;
  *)   _status ;;
esac
