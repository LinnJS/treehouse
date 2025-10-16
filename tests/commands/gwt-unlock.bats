#!/usr/bin/env bats
# Tests for gwt-unlock command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-unlock: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-unlock"
  [ "$status" -eq 0 ]
}

@test "gwt-unlock: unlocks specified worktree" {
  cd "$TEST_REPO"

  # Create and lock worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null
  zsh -c "$(load_plugin) && gwt-lock test-branch" >/dev/null

  # Verify locked
  [ -f "$GWT_ROOT/$repo_name/test-branch/.gwt-lock" ]

  # Unlock it
  run zsh -c "$(load_plugin) && gwt-unlock test-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Unlocked"* ]]

  # Verify lock file removed
  [ ! -f "$GWT_ROOT/$repo_name/test-branch/.gwt-lock" ]
}

@test "gwt-unlock: fails when worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-unlock nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "gwt-unlock: allows removal after unlocking" {
  cd "$TEST_REPO"

  # Create and lock worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null
  zsh -c "$(load_plugin) && gwt-lock test-branch" >/dev/null

  # Unlock it
  zsh -c "$(load_plugin) && gwt-unlock test-branch" >/dev/null

  # Now remove should work
  run zsh -c "$(load_plugin) && echo 'n' | gwt-rm test-branch"
  [ "$status" -eq 0 ]

  # Verify removed
  [ ! -d "$GWT_ROOT/$repo_name/test-branch" ]
}
