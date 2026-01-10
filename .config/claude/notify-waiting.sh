#!/bin/bash

TITLE="${1:-Claude Code}"
BODY="${2:-Waiting}"

# Get current time in 12-hour format (e.g., "1:04 PM")
TIME=$(date "+%-l:%M %p")
BODY="${BODY} - ${TIME}"

printf "\033]777;notify;%s;%s\033\\" "$TITLE" "$BODY" > /dev/tty
