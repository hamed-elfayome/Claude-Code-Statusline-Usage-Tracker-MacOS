# Quick Start Guide

Get your Claude usage tracking up and running in 3 minutes!

## Prerequisites Check

```bash
# Check if jq is installed
jq --version

# If not installed:
brew install jq
```

## Installation Steps

### 1. Get Your Session Key

1. Go to [claude.ai](https://claude.ai) in your browser
2. Press `Cmd+Option+I` to open Developer Tools
3. Click **Application** tab
4. Expand **Cookies** → **https://claude.ai**
5. Find `sessionKey` (starts with `sk-ant-sid01-`)
6. Copy the entire value

### 2. Run Installer

```bash
cd ~/Desktop/claude-code-statusline
./install.sh
```

**Follow the prompts:**
- Paste your session key when asked
- Confirm installation steps
- Wait for completion

### 3. Restart Claude Code

- Press `Cmd+Q` to quit Claude Code completely
- Reopen Claude Code

### 4. Verify

Your statusline should now show:

```
directory │ ⎇ branch │ Usage: XX% ▓▓▓░░░░░░░ → Reset: HH:MM AM/PM
```

Example:
```
my-project │ ⎇ main │ Usage: 29% ▓▓▓░░░░░░░ → Reset: 12:00 AM
```

The entire usage section will be colored based on your usage level (dark green for low, deep red for high).

## Testing

If it shows `Usage: ~` instead of a percentage:

```bash
# Test the Swift script
swift ~/.claude/fetch-claude-usage.swift

# Should output something like:
# 29|2025-11-28T04:00:00.424405+00:00
```

If you get an error, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## That's It!

You now have real-time Claude usage tracking in your statusline.

---

**Next Steps:**
- Read [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) to personalize your statusline
- Star the repo if you find it useful!
- Share with other Claude Code users

**Having issues?** Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
