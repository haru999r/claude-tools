# claude-tools

A collection of macOS utilities for running Claude Code sessions.

## Tools

| Tool | Description | Docs |
|------|-------------|------|
| [tab](tab/) | iTerm2 workspace launcher — opens split panes with Claude Code for a project | [tab/README.md](tab/README.md) |
| [disablesleep](disablesleep/) | Prevent macOS sleep with lid closed so long-running sessions stay alive | [disablesleep/README.md](disablesleep/README.md) |

## Requirements

- macOS
- `~/.local/bin` in your `PATH`

## Install

```bash
git clone https://github.com/haru999r/claude-tools.git
cd claude-tools
make install          # Install all tools
```

Individual install:

```bash
make install-tab
make install-disablesleep
```

## Uninstall

```bash
make uninstall
```

## License

MIT
