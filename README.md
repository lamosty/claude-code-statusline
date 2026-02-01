# Claude Code Statusline

A minimal, efficient statusline for Claude Code. ~50 lines of bash. Shows what matters: your context usage.

```
Opus 4.5 | Ctx: 42.3k | ⌀ main
               ^^^^^^
               Green (<60%) | Yellow (60-80%) | Red (>80%)
```

## Why?

Claude Code's context window fills up as you work. When it's full, you lose conversation history.

This statusline shows your context usage at a glance so you know when to start fresh.

## Features

- **Context usage** with color-coded warnings (green → yellow → red)
- **Model name** - know which Claude you're using
- **Git branch** - stay oriented
- **Fresh session indicator** - shows "new" before first API call

No bloat. No frameworks. Just bash. Uses `jq` if available, falls back to grep/sed.

## Install

**1. Download the script:**

```bash
curl -fsSL https://raw.githubusercontent.com/lamosty/claude-code-statusline/main/statusline.sh \
  -o ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
```

**2. Enable in Claude Code:**

```bash
claude config set statusLine.type command
claude config set statusLine.command '~/.claude/statusline.sh'
```

**3. Restart Claude Code**

### Optional: Install jq

For more robust JSON parsing, install `jq`:

```bash
brew install jq   # macOS
apt install jq    # Linux
```

**macOS note:** If `jq` isn't in PATH when the script runs, add this line after the shebang in `~/.claude/statusline.sh`:

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
```

Without `jq`, the script falls back to grep/sed parsing which works but is less resilient to JSON schema changes.

## License

MIT - Rastislav Lamoš
