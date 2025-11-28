#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Get current directory (basename only)
current_dir=$(basename "$(echo "$input" | jq -r '.workspace.current_dir')")

# ANSI color codes - using $'...' syntax for proper escape sequence interpretation
BLUE=$'\033[0;34m'
GREEN=$'\033[0;32m'
GRAY=$'\033[0;90m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

# 10-level gradient: dark green → deep red
LEVEL_1=$'\033[38;5;22m'   # dark green
LEVEL_2=$'\033[38;5;28m'   # soft green
LEVEL_3=$'\033[38;5;34m'   # medium green
LEVEL_4=$'\033[38;5;100m'  # green-yellowish dark
LEVEL_5=$'\033[38;5;142m'  # olive/yellow-green dark
LEVEL_6=$'\033[38;5;178m'  # muted yellow
LEVEL_7=$'\033[38;5;172m'  # muted yellow-orange
LEVEL_8=$'\033[38;5;166m'  # darker orange
LEVEL_9=$'\033[38;5;160m'  # dark red
LEVEL_10=$'\033[38;5;124m' # deep red

# Get git branch if in a git repo
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null)
  [ -n "$branch" ] && git_info=$(printf " ${GRAY}│${RESET} ${GREEN}⎇ %s${RESET}" "$branch")
fi

# Fetch usage data using Swift script
swift_result=$(swift "$HOME/.claude/fetch-claude-usage.swift" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$swift_result" ]; then
  utilization=$(echo "$swift_result" | cut -d'|' -f1)
  resets_at=$(echo "$swift_result" | cut -d'|' -f2)

  if [ -n "$utilization" ] && [ "$utilization" != "ERROR" ]; then
    # Select color based on utilization percentage
    if [ "$utilization" -le 10 ]; then
      usage_color="$LEVEL_1"
    elif [ "$utilization" -le 20 ]; then
      usage_color="$LEVEL_2"
    elif [ "$utilization" -le 30 ]; then
      usage_color="$LEVEL_3"
    elif [ "$utilization" -le 40 ]; then
      usage_color="$LEVEL_4"
    elif [ "$utilization" -le 50 ]; then
      usage_color="$LEVEL_5"
    elif [ "$utilization" -le 60 ]; then
      usage_color="$LEVEL_6"
    elif [ "$utilization" -le 70 ]; then
      usage_color="$LEVEL_7"
    elif [ "$utilization" -le 80 ]; then
      usage_color="$LEVEL_8"
    elif [ "$utilization" -le 90 ]; then
      usage_color="$LEVEL_9"
    else
      usage_color="$LEVEL_10"
    fi

    # Build progress bar with single color (based on current usage level)
    bar_width=10
    filled_blocks=$(( (utilization * bar_width) / 100 ))
    empty_blocks=$(( bar_width - filled_blocks ))

    # Build progress bar - all blocks use the same color
    progress_bar=""
    for i in $(seq 1 $filled_blocks); do
      progress_bar="${progress_bar}▓"
    done
    for i in $(seq 1 $empty_blocks); do
      progress_bar="${progress_bar}░"
    done

    # Format reset time if available
    reset_time_display=""
    if [ -n "$resets_at" ] && [ "$resets_at" != "null" ]; then
      iso_time=$(echo "$resets_at" | sed 's/\.[0-9]*Z$//')
      epoch=$(date -ju -f "%Y-%m-%dT%H:%M:%S" "$iso_time" "+%s" 2>/dev/null)

      if [ -n "$epoch" ]; then
        reset_time=$(date -r "$epoch" "+%I:%M %p" 2>/dev/null)
        [ -n "$reset_time" ] && reset_time_display=$(printf " → Reset: %s" "$reset_time")
      fi
    fi

    # Apply single color to entire usage section
    usage_info=$(printf " ${GRAY}│${RESET} ${usage_color}Usage: %s%% %s%s${RESET}" "$utilization" "$progress_bar" "$reset_time_display")
  else
    usage_info=$(printf " ${GRAY}│${RESET} ${YELLOW}Usage: ~${RESET}")
  fi
else
  usage_info=$(printf " ${GRAY}│${RESET} ${YELLOW}Usage: ~${RESET}")
fi

# Output status line: directory-name │ ⎇ branch │ Usage: XX% ▓▓▓▓▓░░░░░ → Reset: HH:MM AM/PM
printf "${BLUE}%s${RESET}%s%s\n" "$current_dir" "$git_info" "$usage_info"
