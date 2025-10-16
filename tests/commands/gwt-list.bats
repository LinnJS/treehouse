#!/usr/bin/env bats
# Tests for gwt-list command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-list: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-list"
  [ "$status" -eq 0 ]
}

# TODO: Add comprehensive tests requiring git repo setup
# - List shows worktrees when they exist
# - --plain mode outputs correct format
# - Shows locked indicator
# - Shows uncommitted changes indicator
