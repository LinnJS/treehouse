#!/usr/bin/env bats
# Tests for gwt-migrate command

PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."

@test "gwt-migrate: command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-migrate"
  [ "$status" -eq 0 ]
}

# NOTE: Baseline coverage (autoload test) is sufficient for this command.
# This is a utility/integration command that either:
# - Requires external dependencies (gh, fzf, etc.)
# - Is a simple wrapper around git/editor commands
# - Would be complex to test in isolation
# Comprehensive functional tests can be added in future iterations if needed.
