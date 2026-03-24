#!/bin/bash
# claude-tab: Open iTerm2 tab with split panes for a Claude Code workspace
# Usage: tab <project> | tab list
#
# Reads project definitions from ~/.config/tab/projects.json
#
# Pane layout is auto-detected based on screen width:
#   Screen width >= 2560 (logical px) → 4x2 (8 panes)
#   Screen width <  2560              → 3x2 (6 panes)
#
# Per-pane initial prompt:
#   Set "last_pane_prompt" in config to auto-send a prompt to Claude in the last pane.
#
# Setup (one-time):
#   iTerm2 → Settings → Profiles → General → Title
#     1. Uncheck "Applications in terminal may change the title"
#     2. Set Title to "Session Name"

set -euo pipefail

CONFIG_FILE="${TAB_CONFIG:-$HOME/.config/tab/projects.json}"

# ── Helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" &>/dev/null || die "$1 is required but not found"
}

# ── Config parsing (jq) ─────────────────────────────────────────────────────

require_cmd jq

_project_names() {
  jq -r '.projects | keys[]' "$CONFIG_FILE" 2>/dev/null || true
}

_project_field() {
  local project="$1" field="$2"
  jq -r --arg p "$project" --arg f "$field" '.projects[$p][$f] // empty' "$CONFIG_FILE"
}

# ── Screen detection ─────────────────────────────────────────────────────────

_detect_columns() {
  local width
  width=$(osascript -e '
    tell application "Finder"
      set db to bounds of window of desktop
      return (item 3 of db) - (item 1 of db)
    end tell
  ' 2>/dev/null || echo 1920)

  if (( width >= 2560 )); then
    echo 4
  else
    echo 3
  fi
}

COLUMNS=$(_detect_columns)
PANES=$((COLUMNS * 2))

# ── Usage ────────────────────────────────────────────────────────────────────

show_usage() {
  echo "Usage: tab <project> | tab list"
  echo ""
  echo "Projects (from $CONFIG_FILE):"
  local names
  names=$(_project_names)
  if [[ -z "$names" ]]; then
    echo "  (none — edit $CONFIG_FILE to add projects)"
  else
    while IFS= read -r name; do
      local dir
      dir=$(_project_field "$name" "dir")
      echo "  $name  →  $dir"
    done <<< "$names"
  fi
  echo ""
  echo "Detected layout: ${COLUMNS}x2 (${PANES} panes)"
}

# ── Entry builder ────────────────────────────────────────────────────────────

_build_entries() {
  local dir="$1"
  local total="$2"
  local last_prompt="${3:-}"

  for ((i = 1; i <= total; i++)); do
    if [[ $i -eq $total && -n "$last_prompt" ]]; then
      echo "${dir}::${last_prompt}"
    else
      echo "$dir"
    fi
  done
}

# Build the shell command for a single pane.
# If the entry contains "::", the part after is passed as an initial prompt to Claude.
# Output is pre-escaped for embedding in AppleScript double-quoted strings.
_build_cmd() {
  local entry="$1"
  local claude_base="$2"
  local dir="${entry%%::*}"

  # Expand ~ to $HOME
  dir="${dir/#\~/$HOME}"

  if [[ "$entry" == *"::"* ]]; then
    local prompt="${entry#*::}"
    echo "cd ${dir} && ${claude_base} \\\"${prompt}\\\""
  else
    echo "cd ${dir} && ${claude_base}"
  fi
}

# ── iTerm2 pane layout via AppleScript ───────────────────────────────────────

open_panes() {
  local name="$1"
  local claude_opts="$2"
  local claude_cmd="${3:-claude}"
  shift 3
  local entries=("$@")
  local count=${#entries[@]}
  local claude_base="${claude_cmd}${claude_opts:+ $claude_opts}"

  local cmds=()
  for entry in "${entries[@]}"; do
    cmds+=("$(_build_cmd "$entry" "$claude_base")")
  done

  case $count in
    1)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  tell current session of t
    set name to "${name}"
    write text "${cmds[0]}"
  end tell
end tell
OSASCRIPT
      ;;
    2)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  tell current session of t
    set name to "${name}"
    write text "${cmds[0]}"
    set s2 to (split vertically with default profile)
  end tell
  tell s2
    set name to "${name}"
    write text "${cmds[1]}"
  end tell
end tell
OSASCRIPT
      ;;
    3)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  tell current session of t
    set name to "${name}"
    write text "${cmds[0]}"
    set s2 to (split vertically with default profile)
  end tell
  tell s2
    set name to "${name}"
    write text "${cmds[1]}"
    set s3 to (split horizontally with default profile)
  end tell
  tell s3
    set name to "${name}"
    write text "${cmds[2]}"
  end tell
end tell
OSASCRIPT
      ;;
    4)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  tell current session of t
    set name to "${name}"
    write text "${cmds[0]}"
    set s2 to (split vertically with default profile)
    set s3 to (split horizontally with default profile)
  end tell
  tell s2
    set name to "${name}"
    write text "${cmds[1]}"
    set s4 to (split horizontally with default profile)
  end tell
  tell s3
    set name to "${name}"
    write text "${cmds[2]}"
  end tell
  tell s4
    set name to "${name}"
    write text "${cmds[3]}"
  end tell
end tell
OSASCRIPT
      ;;
    6)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  set s1 to current session of t

  tell s1
    set s2 to (split vertically with default profile)
  end tell
  tell s2
    set s3 to (split vertically with default profile)
  end tell

  tell s1
    set s4 to (split horizontally with default profile)
  end tell
  tell s2
    set s5 to (split horizontally with default profile)
  end tell
  tell s3
    set s6 to (split horizontally with default profile)
  end tell

  tell s1
    set name to "${name}"
    write text "${cmds[0]}"
  end tell
  tell s2
    set name to "${name}"
    write text "${cmds[1]}"
  end tell
  tell s3
    set name to "${name}"
    write text "${cmds[2]}"
  end tell
  tell s4
    set name to "${name}"
    write text "${cmds[3]}"
  end tell
  tell s5
    set name to "${name}"
    write text "${cmds[4]}"
  end tell
  tell s6
    set name to "${name}"
    write text "${cmds[5]}"
  end tell
end tell
OSASCRIPT
      ;;
    8)
      osascript <<OSASCRIPT
tell application "iTerm"
  set w to current window
  if w is missing value then set w to (create window with default profile)
  set t to (create tab with default profile) of w
  set s1 to current session of t

  tell s1
    set s2 to (split vertically with default profile)
  end tell
  tell s2
    set s3 to (split vertically with default profile)
  end tell
  tell s3
    set s4 to (split vertically with default profile)
  end tell

  tell s1
    set s5 to (split horizontally with default profile)
  end tell
  tell s2
    set s6 to (split horizontally with default profile)
  end tell
  tell s3
    set s7 to (split horizontally with default profile)
  end tell
  tell s4
    set s8 to (split horizontally with default profile)
  end tell

  tell s1
    set name to "${name}"
    write text "${cmds[0]}"
  end tell
  tell s2
    set name to "${name}"
    write text "${cmds[1]}"
  end tell
  tell s3
    set name to "${name}"
    write text "${cmds[2]}"
  end tell
  tell s4
    set name to "${name}"
    write text "${cmds[3]}"
  end tell
  tell s5
    set name to "${name}"
    write text "${cmds[4]}"
  end tell
  tell s6
    set name to "${name}"
    write text "${cmds[5]}"
  end tell
  tell s7
    set name to "${name}"
    write text "${cmds[6]}"
  end tell
  tell s8
    set name to "${name}"
    write text "${cmds[7]}"
  end tell
end tell
OSASCRIPT
      ;;
    *)
      die "Unsupported pane count: $count (supported: 1-4, 6, 8)"
      ;;
  esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

[[ -f "$CONFIG_FILE" ]] || die "Config not found: $CONFIG_FILE\nRun 'make install' or copy config.example.json to $CONFIG_FILE"

project="${1:-}"

if [[ -z "$project" || "$project" == "list" ]]; then
  show_usage
  [[ -n "$project" ]] || exit 1
  exit 0
fi

# Validate project exists in config
dir=$(_project_field "$project" "dir")
[[ -n "$dir" ]] || die "Unknown project: $project\nRun 'tab list' to see available projects."

claude_cmd=$(_project_field "$project" "claude_cmd")
claude_opts=$(_project_field "$project" "claude_opts")
last_pane_prompt=$(_project_field "$project" "last_pane_prompt")
panes_override=$(_project_field "$project" "panes")

# Use override pane count if set, otherwise auto-detect
if [[ -n "$panes_override" && "$panes_override" != "null" && "$panes_override" != "auto" ]]; then
  target_panes="$panes_override"
else
  target_panes="$PANES"
fi

: "${claude_cmd:=claude}"
: "${claude_opts:=}"

entries=()
while IFS= read -r line; do entries+=("$line"); done < <(_build_entries "$dir" "$target_panes" "$last_pane_prompt")

open_panes "$project" "$claude_opts" "$claude_cmd" "${entries[@]}"
