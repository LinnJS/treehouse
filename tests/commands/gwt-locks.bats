#!/usr/bin/env bats
# Tests for gwt-locks command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-locks: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-locks"
  [ "$status" -eq 0 ]
}

@test "gwt-locks: shows message when no locks exist" {
  cd "$TEST_REPO"

  # Create worktree without locking
  zsh -c "$(load_plugin) && gwt-add unlocked" >/dev/null

  run zsh -c "$(load_plugin) && gwt-locks"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No locked worktrees"* ]]
}

@test "gwt-locks: lists locked worktrees" {
  cd "$TEST_REPO"

  # Create and lock a worktree
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null
  zsh -c "$(load_plugin) && gwt-lock test-branch" >/dev/null

  # List locks
  run zsh -c "$(load_plugin) && gwt-locks"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Locked Worktrees"* ]]
  [[ "$output" == *"test-branch"* ]]
}

@test "gwt-locks: lists multiple locked worktrees" {
  cd "$TEST_REPO"

  # Create and lock multiple worktrees
  for name in alpha beta gamma; do
    zsh -c "$(load_plugin) && gwt-add $name" >/dev/null
    zsh -c "$(load_plugin) && gwt-lock $name" >/dev/null
  done

  # List all locks
  run zsh -c "$(load_plugin) && gwt-locks"
  [ "$status" -eq 0 ]
  [[ "$output" == *"alpha"* ]]
  [[ "$output" == *"beta"* ]]
  [[ "$output" == *"gamma"* ]]
}

@test "gwt-locks: does not list unlocked worktrees" {
  cd "$TEST_REPO"

  # Create locked and unlocked worktrees
  zsh -c "$(load_plugin) && gwt-add locked-one" >/dev/null
  zsh -c "$(load_plugin) && gwt-lock locked-one" >/dev/null
  zsh -c "$(load_plugin) && gwt-add unlocked-one" >/dev/null

  # List locks - should only show locked-one
  run zsh -c "$(load_plugin) && gwt-locks"
  [ "$status" -eq 0 ]
  [[ "$output" == *"locked-one"* ]]
  [[ "$output" != *"unlocked-one"* ]]
}
