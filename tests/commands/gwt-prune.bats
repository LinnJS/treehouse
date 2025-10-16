#!/usr/bin/env bats
# Tests for gwt-prune command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-prune: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-prune"
  [ "$status" -eq 0 ]
}

@test "gwt-prune: runs successfully" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-prune"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Pruned"* ]]
}
