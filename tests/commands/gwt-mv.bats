#!/usr/bin/env bats
# Tests for gwt-mv command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-mv: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-mv"
  [ "$status" -eq 0 ]
}

@test "gwt-mv: shows usage when arguments missing" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-mv"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]

  run zsh -c "$(load_plugin) && gwt-mv old-name"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "gwt-mv: renames worktree successfully" {
  cd "$TEST_REPO"

  # Create worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add old-name" >/dev/null

  # Rename it
  run zsh -c "$(load_plugin) && gwt-mv old-name new-name"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Moved worktree"* ]]

  # Verify old path gone, new path exists
  [ ! -d "$GWT_ROOT/$repo_name/old-name" ]
  [ -d "$GWT_ROOT/$repo_name/new-name" ]
}

@test "gwt-mv: fails when source does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-mv nonexistent new-name"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "gwt-mv: fails when destination already exists" {
  cd "$TEST_REPO"

  # Create two worktrees
  zsh -c "$(load_plugin) && gwt-add first" >/dev/null
  zsh -c "$(load_plugin) && gwt-add second" >/dev/null

  # Try to rename first to second
  run zsh -c "$(load_plugin) && gwt-mv first second"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}
