#!/usr/bin/env bats
# Tests for gwt-unlock command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-unlock: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-unlock"
  [ "$status" -eq 0 ]
}

# TODO: Add comprehensive tests
# See tests/commands/README.md for guidelines
