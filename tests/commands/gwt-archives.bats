#!/usr/bin/env bats
# Tests for gwt-archives command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-archives: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-archives"
  [ "$status" -eq 0 ]
}

@test "gwt-archives: shows message when no archives exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-archives"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No archived worktrees"* ]]
}

@test "gwt-archives: lists archived worktrees" {
  cd "$TEST_REPO"

  # Create and archive a worktree
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null
  zsh -c "$(load_plugin) && gwt-archive test-branch" >/dev/null

  # List archives
  run zsh -c "$(load_plugin) && gwt-archives"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Archived Worktrees"* ]]
  [[ "$output" == *"test-branch"* ]]
}

@test "gwt-archives: lists multiple archived worktrees" {
  cd "$TEST_REPO"

  # Create and archive multiple worktrees
  for name in alpha beta gamma; do
    zsh -c "$(load_plugin) && gwt-add $name" >/dev/null
    zsh -c "$(load_plugin) && gwt-archive $name" >/dev/null
  done

  # List all archives
  run zsh -c "$(load_plugin) && gwt-archives"
  [ "$status" -eq 0 ]
  [[ "$output" == *"alpha"* ]]
  [[ "$output" == *"beta"* ]]
  [[ "$output" == *"gamma"* ]]
}
