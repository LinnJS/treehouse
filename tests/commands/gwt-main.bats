#!/usr/bin/env bats
# Tests for gwt-main command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-main: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-main"
  [ "$status" -eq 0 ]
}

@test "gwt-main: switches to main repository root" {
  cd "$TEST_REPO"

  # Switch to main (note: cd in subshell won't affect parent, but pwd will show it)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-main && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_REPO"* ]]
  [[ "$output" == *"Switched to main repository"* ]]
}

@test "gwt-main: works from within a worktree" {
  cd "$TEST_REPO"

  # Create and switch to worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add feature-branch" >/dev/null

  # From within worktree, go back to main (pwd will show new location)
  run zsh -c "$(load_plugin) && cd '$GWT_ROOT/$repo_name/feature-branch' && gwt-main && pwd"
  [ "$status" -eq 0 ]
  # Output includes both the "Switched to main repository" message and pwd
  [[ "$output" == *"Switched to main repository"* ]]
}
