#!/usr/bin/env zsh
# Quick reload script for development
# Usage: source reload.sh

autoload -U compinit && compinit -q 2>/dev/null
source "$(dirname "$0")/treehouse.plugin.zsh" && echo "✓ Plugin reloaded"
