#!/usr/bin/env bats
# Tests for gwt-switch command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-switch: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-switch"
  [ "$status" -eq 0 ]
}

# TODO: Add comprehensive tests
# See tests/commands/README.md for guidelines
