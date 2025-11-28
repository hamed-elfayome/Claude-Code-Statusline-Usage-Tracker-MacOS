#!/bin/bash

# Claude Code Statusline - Usage Tracker Installer
# This script installs the Claude usage tracker for your Claude Code statusline

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if script is run from the correct directory
if [ ! -f "scripts/fetch-claude-usage.swift" ]; then
    print_error "Error: This script must be run from the claude-code-statusline directory"
    echo "Please cd into the repository directory and run ./install.sh"
    exit 1
fi

print_header "Claude Code Statusline - Usage Tracker Installer"

# Check prerequisites
print_info "Checking prerequisites..."

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This installer only works on macOS"
    exit 1
fi
print_success "macOS detected"

# Check Swift
if ! command -v swift &> /dev/null; then
    print_error "Swift is not installed. Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi
print_success "Swift is installed"

# Check jq
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed"
    echo ""
    echo "jq is required for parsing JSON. Install it with:"
    echo "  brew install jq"
    echo ""
    read -p "Do you want to install jq now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew is not installed. Please install it first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
        brew install jq
        print_success "jq installed"
    else
        print_error "Installation cancelled. Please install jq and try again."
        exit 1
    fi
else
    print_success "jq is installed"
fi

# Create .claude directory if it doesn't exist
mkdir -p ~/.claude
print_success "Created ~/.claude directory"

# Get session key
print_header "Step 1: Claude Session Key"

echo "You need to obtain your Claude session key from your browser."
echo ""
echo "Instructions:"
echo "  1. Open your browser and go to https://claude.ai"
echo "  2. Open Developer Tools (Cmd+Option+I)"
echo "  3. Go to the 'Application' tab"
echo "  4. In the left sidebar, expand 'Cookies' → 'https://claude.ai'"
echo "  5. Find the 'sessionKey' cookie (starts with sk-ant-sid01-)"
echo "  6. Copy the entire value"
echo ""

# Check if session key already exists
if [ -f ~/.claude-session-key ]; then
    print_warning "Session key file already exists at ~/.claude-session-key"
    read -p "Do you want to replace it with a new key? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing session key"
    else
        rm ~/.claude-session-key
        read -p "Paste your session key here: " session_key
        echo "$session_key" > ~/.claude-session-key
        chmod 600 ~/.claude-session-key
        print_success "Session key saved"
    fi
else
    read -p "Paste your session key here: " session_key

    # Validate session key format
    if [[ ! "$session_key" =~ ^sk-ant-sid ]]; then
        print_error "Invalid session key format. Session keys should start with 'sk-ant-sid'"
        exit 1
    fi

    echo "$session_key" > ~/.claude-session-key
    chmod 600 ~/.claude-session-key
    print_success "Session key saved to ~/.claude-session-key"
fi

# Install Swift script
print_header "Step 2: Installing Scripts"

cp scripts/fetch-claude-usage.swift ~/.claude/fetch-claude-usage.swift
chmod +x ~/.claude/fetch-claude-usage.swift
print_success "Installed fetch-claude-usage.swift"

cp scripts/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
print_success "Installed statusline-command.sh"

# Test the Swift script
print_header "Step 3: Testing Installation"

print_info "Testing Claude API connection..."
test_result=$(swift ~/.claude/fetch-claude-usage.swift 2>&1)

if [[ $test_result == ERROR* ]]; then
    print_error "Test failed: $test_result"
    echo ""
    echo "Possible causes:"
    echo "  - Invalid session key"
    echo "  - Session key has expired"
    echo "  - No internet connection"
    echo "  - Claude API is unavailable"
    echo ""
    echo "Please check your session key and try again."
    exit 1
elif [[ $test_result =~ ^[0-9]+\| ]]; then
    utilization=$(echo "$test_result" | cut -d'|' -f1)
    print_success "Test successful! Current usage: ${utilization}%"
else
    print_warning "Unexpected response: $test_result"
    echo "The scripts are installed, but there may be an issue."
fi

# Configure Claude Code settings
print_header "Step 4: Configuring Claude Code"

settings_file=~/.claude/settings.json

# Check if settings file exists
if [ ! -f "$settings_file" ]; then
    print_info "Creating settings.json..."
    echo '{
  "statusLine": {
    "type": "command",
    "command": "bash '"$HOME"'/.claude/statusline-command.sh"
  }
}' > "$settings_file"
    print_success "Created settings.json with statusline configuration"
else
    print_info "Settings file already exists"

    # Check if statusLine is already configured
    if grep -q '"statusLine"' "$settings_file"; then
        print_warning "statusLine is already configured in settings.json"
        echo ""
        echo "Your current statusLine configuration:"
        grep -A3 '"statusLine"' "$settings_file" || echo "(could not read configuration)"
        echo ""
        read -p "Do you want to replace it with the usage tracker? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup current settings
            cp "$settings_file" "${settings_file}.backup"
            print_success "Backed up current settings to ${settings_file}.backup"

            # Update statusLine configuration using jq
            temp_file=$(mktemp)
            jq '.statusLine = {"type": "command", "command": "bash '"$HOME"'/.claude/statusline-command.sh"}' "$settings_file" > "$temp_file"
            mv "$temp_file" "$settings_file"
            print_success "Updated statusLine configuration"
        else
            print_info "Keeping existing statusLine configuration"
            echo ""
            echo "You can manually update your statusLine configuration to:"
            echo '  "statusLine": {'
            echo '    "type": "command",'
            echo '    "command": "bash '"$HOME"'/.claude/statusline-command.sh"'
            echo '  }'
        fi
    else
        # Add statusLine to existing settings
        print_info "Adding statusLine to existing settings..."

        # Backup current settings
        cp "$settings_file" "${settings_file}.backup"
        print_success "Backed up current settings to ${settings_file}.backup"

        # Add statusLine using jq
        temp_file=$(mktemp)
        jq '. + {"statusLine": {"type": "command", "command": "bash '"$HOME"'/.claude/statusline-command.sh"}}' "$settings_file" > "$temp_file"
        mv "$temp_file" "$settings_file"
        print_success "Added statusLine configuration"
    fi
fi

# Final instructions
print_header "Installation Complete!"

echo "Your Claude Code statusline is now configured to show usage statistics."
echo ""
echo "Next steps:"
echo "  1. ${GREEN}Restart Claude Code${NC} to see the changes"
echo "  2. Your statusline will show: ${BLUE}directory │ ⎇ branch │ Usage: XX% ▓▓▓░░░░░░░ → Reset: HH:MM AM/PM${NC}"
echo ""
echo "Example:"
echo "  ${BLUE}my-project │ ⎇ main │ Usage: 29% ▓▓▓░░░░░░░ → Reset: 12:00 AM${NC}"
echo ""
echo "Color Gradient:"
echo "  The entire usage section changes color from dark green (low usage) to deep red (high usage)"
echo ""
echo "Files installed:"
echo "  - ~/.claude-session-key (your session key)"
echo "  - ~/.claude/fetch-claude-usage.swift (usage fetcher)"
echo "  - ~/.claude/statusline-command.sh (statusline formatter)"
echo "  - ~/.claude/settings.json (Claude Code configuration)"
echo ""
print_info "If your statusline shows 'Usage: ~' instead of percentage, check the Troubleshooting"
print_info "section in the README.md"
echo ""
print_success "Installation complete!"
echo ""
