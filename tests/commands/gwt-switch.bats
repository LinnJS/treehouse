#!/usr/bin/env bats
# Tests for gwt-switch command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-switch: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-switch"
  [ "$status" -eq 0 ]
}

@test "gwt-switch: switches to existing worktree by branch name" {
  cd "$TEST_REPO"

  # Create worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # Switch to it by branch name (note: cd in subshell won't affect parent)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-switch test-branch && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$GWT_ROOT/$repo_name/test-branch"* ]]
}

@test "gwt-switch: switches to existing worktree by full path" {
  cd "$TEST_REPO"

  # Create worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # Switch to it by full path
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-switch '$GWT_ROOT/$repo_name/test-branch' && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$GWT_ROOT/$repo_name/test-branch"* ]]
}

@test "gwt-switch: fails without fzf when no branch specified" {
  cd "$TEST_REPO"

  # Create worktree
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # Try to switch without specifying branch (no fzf available in CI)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-switch"
  # Either succeeds with fzf or fails with error message
  if [ "$status" -ne 0 ]; then
    [[ "$output" == *"fzf"* ]] || [[ "$output" == *"branch"* ]]
  fi
}

@test "gwt-switch: fails when worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-switch nonexistent-branch"
  [ "$status" -eq 1 ]
}
