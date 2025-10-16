#!/usr/bin/env bats
# Tests for gwt-lock command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-lock: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-lock"
  [ "$status" -eq 0 ]
}

@test "gwt-lock: locks specified worktree" {
  cd "$TEST_REPO"

  # Create worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # Lock it
  run zsh -c "$(load_plugin) && gwt-lock test-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Locked worktree"* ]]

  # Verify lock file exists
  [ -f "$GWT_ROOT/$repo_name/test-branch/.gwt-lock" ]
}

@test "gwt-lock: fails when worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-lock nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "gwt-lock: prevents removal of locked worktree" {
  cd "$TEST_REPO"

  # Create and lock worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add locked-test" >/dev/null
  zsh -c "$(load_plugin) && gwt-lock locked-test" >/dev/null

  # Try to remove
  run zsh -c "$(load_plugin) && gwt-rm locked-test"
  [ "$status" -eq 1 ]
  [[ "$output" == *"locked"* ]]

  # Verify still exists
  [ -d "$GWT_ROOT/$repo_name/locked-test" ]
}
