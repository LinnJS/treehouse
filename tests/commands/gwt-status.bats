#!/usr/bin/env bats
# Tests for gwt-status command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-status: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-status"
  [ "$status" -eq 0 ]
}

# TODO: Add comprehensive tests
# See tests/commands/README.md for guidelines
