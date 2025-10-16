#!/usr/bin/env zsh
# Quick reload script for treehouse plugin development
# Usage: source reload.sh

# Unset the loaded flag to allow reload
unset TREEHOUSE_PLUGIN_LOADED

# Source the plugin
source "${0:A:h}/treehouse.plugin.zsh"

echo "✓ Treehouse plugin reloaded"
