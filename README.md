# Claude Code Statusline - Usage Tracker

[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Display your Claude AI usage statistics directly in your Claude Code statusline. Monitor your API usage in real-time without leaving your terminal.

![Claude Code Statusline Example](https://hamedelfayome.dev/m/gcuts)

## Features

- **Real-time Usage Tracking** - See your current Claude usage percentage
- **Visual Progress Bar** - 10-block progress indicator with color gradient
- **10-Level Color Gradient** - Dark green to deep red based on usage
- **Reset Timer** - Know exactly when your usage quota resets
- **Fast & Lightweight** - Uses native Swift for optimal performance
- **Secure** - No third-party services, all data stays local
- **Auto-refresh** - Updates automatically with your statusline

## Display Format

```
directory │ ⎇ branch │ Usage: XX% ▓▓▓░░░░░░░ → Reset: HH:MM AM/PM
```

**Example:**
```
my-project │ ⎇ main │ Usage: 29% ▓▓▓░░░░░░░ → Reset: 12:00 AM
```

**Color Gradient:**
The entire usage section changes color based on usage level:
- 0-10%: Dark green
- 11-20%: Soft green
- 21-30%: Medium green
- 31-40%: Green-yellowish
- 41-50%: Olive/yellow-green
- 51-60%: Muted yellow
- 61-70%: Muted yellow-orange
- 71-80%: Darker orange
- 81-90%: Dark red
- 91-100%: Deep red

## Prerequisites

- macOS 11.0 or later
- Claude Code installed
- Swift (comes pre-installed with macOS)
- `jq` command-line JSON processor

## Quick Start

### 1. Install jq (if not already installed)

```bash
brew install jq
```

### 2. Get Your Claude Session Key

1. Open your browser and navigate to [claude.ai](https://claude.ai)
2. Open Developer Tools (Cmd+Option+I)
3. Go to the **Application** tab
4. In the left sidebar, expand **Cookies** → **https://claude.ai**
5. Find the `sessionKey` cookie (starts with `sk-ant-sid01-`)
6. Copy the entire value

### 3. Run the Installation Script

```bash
cd ~/Desktop/claude-code-statusline
./install.sh
```

The installer will:
- Prompt you to paste your session key
- Install the Swift usage fetcher script
- Install the statusline command script
- Configure your Claude Code settings
- Set proper file permissions

### 4. Restart Claude Code

Close and reopen Claude Code to see your usage stats in the statusline!

## Manual Installation

If you prefer to install manually:

### 1. Save Your Session Key

```bash
# Create the session key file
echo "sk-ant-sid01-YOUR_SESSION_KEY_HERE" > ~/.claude-session-key
chmod 600 ~/.claude-session-key
```

### 2. Install the Swift Fetcher Script

```bash
# Copy the Swift script
cp scripts/fetch-claude-usage.swift ~/.claude/fetch-claude-usage.swift
chmod +x ~/.claude/fetch-claude-usage.swift
```

### 3. Install the Statusline Script

```bash
# Copy the statusline command script
cp scripts/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

### 4. Configure Claude Code Settings

Add this to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

Replace `YOUR_USERNAME` with your actual username, or use `$HOME`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash $HOME/.claude/statusline-command.sh"
  }
}
```

## How It Works

1. **Swift Fetcher** (`fetch-claude-usage.swift`):
   - Reads your session key from `~/.claude-session-key`
   - Fetches your organization ID from Claude's API
   - Retrieves current usage statistics
   - Returns: `UTILIZATION|RESETS_AT`

2. **Statusline Script** (`statusline-command.sh`):
   - Calls the Swift fetcher
   - Parses the output
   - Selects color based on usage level (10-level gradient system)
   - Builds visual progress bar with filled and empty blocks
   - Formats the display with directory, branch, usage info, and reset time
   - Outputs to Claude Code's statusline with proper color codes

3. **Why Swift?**
   - Native macOS URLSession has browser-like TLS fingerprinting
   - Bypasses Cloudflare bot detection (unlike curl)
   - Fast and reliable
   - No external dependencies

## Troubleshooting

### Statusline shows `Usage: ~` instead of usage percentage

**Causes:**
- Session key is missing or invalid
- Session key has expired
- Swift script has errors

**Solutions:**

1. **Verify session key exists:**
   ```bash
   cat ~/.claude-session-key
   ```

2. **Test the Swift script directly:**
   ```bash
   swift ~/.claude/fetch-claude-usage.swift
   ```
   Should output: `29|2025-11-28T04:00:00.424405+00:00`

3. **Check for errors:**
   ```bash
   swift ~/.claude/fetch-claude-usage.swift 2>&1
   ```

4. **Refresh your session key:**
   - Session keys expire periodically
   - Follow step 2 in Quick Start to get a new key
   - Update `~/.claude-session-key` with the new key

### Script runs slowly

The Swift script typically runs in 1-2 seconds. If it's slower:

1. **Check your internet connection**
2. **Verify Claude API is accessible:**
   ```bash
   curl -I https://claude.ai
   ```

### Permission denied errors

```bash
chmod 600 ~/.claude-session-key
chmod +x ~/.claude/fetch-claude-usage.swift
chmod +x ~/.claude/statusline-command.sh
```

## Customization

### Change Time Format

Edit `~/.claude/statusline-command.sh` and modify the date format on line 87:

```bash
# 12-hour format (default)
reset_time=$(date -r "$epoch" "+%I:%M %p" 2>/dev/null)

# 24-hour format
reset_time=$(date -r "$epoch" "+%H:%M" 2>/dev/null)

# Full date and time
reset_time=$(date -r "$epoch" "+%b %d %I:%M %p" 2>/dev/null)
```

## Security & Privacy

- Your session key is stored locally at `~/.claude-session-key` with `600` permissions (owner read/write only)
- No data is sent to third-party services
- All API calls go directly to Claude.ai
- Session keys should be treated like passwords - never commit them to git

## Uninstalling

```bash
rm ~/.claude-session-key
rm ~/.claude/fetch-claude-usage.swift
rm ~/.claude/statusline-command.sh
```

Then remove the `statusLine` configuration from `~/.claude/settings.json`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Related Projects

- [Claude Usage Tracker (macOS App)](https://github.com/hamed-elfayome/Claude-Usage-Tracker) - Menu bar app for usage tracking

## Support

If you encounter any issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Open an issue on GitHub
3. Ensure you're using the latest version

---

**Note:** This is an unofficial tool and is not affiliated with or endorsed by Anthropic.
