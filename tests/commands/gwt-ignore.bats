#!/usr/bin/env bats
# Tests for gwt-ignore command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-ignore: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-ignore"
  [ "$status" -eq 0 ]
}

# TODO: Add comprehensive tests
# See tests/commands/README.md for guidelines
