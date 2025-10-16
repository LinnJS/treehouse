#!/usr/bin/env bats
# Tests for gwt-unarchive command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-unarchive: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-unarchive"
  [ "$status" -eq 0 ]
}

@test "gwt-unarchive: restores archived worktree" {
  cd "$TEST_REPO"

  # Create, archive, then unarchive
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null
  zsh -c "$(load_plugin) && gwt-archive test-branch" >/dev/null

  # Unarchive it
  run zsh -c "$(load_plugin) && gwt-unarchive test-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Restored"* ]]

  # Verify moved back from archive
  [ -d "$GWT_ROOT/$repo_name/test-branch" ]
  [ ! -d "$GWT_ROOT/$repo_name/.archive/test-branch" ]
}

@test "gwt-unarchive: fails when archived worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-unarchive nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}
