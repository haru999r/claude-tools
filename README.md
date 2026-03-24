# claude-tab

Opens an iTerm2 tab with multiple split panes, each running Claude Code, for a given project. Pane count is auto-detected from screen width (6 or 8 panes). Project definitions are read from a JSON config file.

## Requirements

- macOS
- iTerm2
- `jq`
- Claude Code CLI (`claude`)

## Install

```bash
git clone https://github.com/haru999r/claude-tab.git
cd claude-tab
make install
```

This installs `tab` to `~/.local/bin/` and creates a starter config at `~/.config/tab/projects.json` if one does not exist. Ensure `~/.local/bin` is in your `PATH`.

## Uninstall

```bash
make uninstall
```

## Configuration

Edit `~/.config/tab/projects.json`. Override the config path with the `TAB_CONFIG` environment variable.

### Schema

```json
{
  "projects": {
    "<project-name>": {
      "dir": "~/path/to/project",
      "claude_cmd": "claude",
      "claude_opts": "--enable-auto-mode",
      "panes": "auto",
      "last_pane_prompt": "/some-slash-command"
    }
  }
}
```

### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `dir` | string | yes | — | Project directory. `~` is expanded. |
| `claude_cmd` | string | no | `"claude"` | Claude binary or alias name. |
| `claude_opts` | string | no | `""` | CLI flags passed to Claude (e.g. `"--enable-auto-mode"`). |
| `panes` | int or `"auto"` | no | `"auto"` | Number of panes. `"auto"` detects from screen width (6 or 8). Supported values: 1, 2, 3, 4, 6, 8. |
| `last_pane_prompt` | string or null | no | `null` | Initial prompt sent to Claude in the last pane only. Useful for auto-starting a dev server. |

### Example

```json
{
  "projects": {
    "frontend": {
      "dir": "~/works/frontend",
      "claude_cmd": "claude",
      "claude_opts": "--enable-auto-mode",
      "last_pane_prompt": null
    },
    "api": {
      "dir": "~/works/api",
      "claude_cmd": "claude",
      "claude_opts": "",
      "panes": 4,
      "last_pane_prompt": "/run-server"
    }
  }
}
```

## Usage

```bash
tab <project>   # Open panes for the project
tab list        # List configured projects
```

## Layout

Layout is determined by screen width (logical pixels):

| Screen width | Layout | Panes |
|-------------|--------|-------|
| >= 2560px | 4x2 grid | 8 |
| < 2560px | 3x2 grid | 6 |

Override per-project with the `panes` field.

## iTerm2 Setup (one-time)

iTerm2 → Settings → Profiles → General → Title:
1. Uncheck "Applications in terminal may change the title"
2. Set Title to "Session Name"

## License

MIT
