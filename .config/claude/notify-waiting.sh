#!/bin/bash

TITLE="${1:-Claude Code}"
BODY="${2:-Waiting}"

printf "\033]777;notify;%s;%s\033\\" "$TITLE" "$BODY" > /dev/tty
