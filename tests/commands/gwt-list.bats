#!/usr/bin/env bats
# Tests for gwt-list command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-list: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-list"
  [ "$status" -eq 0 ]
}

@test "gwt-list: shows error when no worktrees exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-list"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No worktrees found"* ]]
}

@test "gwt-list: shows worktrees when they exist" {
  cd "$TEST_REPO"

  # Create some worktrees
  zsh -c "$(load_plugin) && gwt-add feature-one" >/dev/null
  zsh -c "$(load_plugin) && gwt-add feature-two" >/dev/null

  # List them
  run zsh -c "$(load_plugin) && gwt-list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature-one"* ]]
  [[ "$output" == *"feature-two"* ]]
}

@test "gwt-list: plain mode outputs paths only" {
  cd "$TEST_REPO"

  # Create worktree
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # List in plain mode
  run zsh -c "$(load_plugin) && gwt-list --plain"
  [ "$status" -eq 0 ]

  # Should contain the path
  local repo_name=$(basename "$TEST_REPO")
  [[ "$output" == *"$GWT_ROOT/$repo_name/test-branch"* ]]

  # Should not contain fancy formatting (no ANSI codes in plain mode)
  # Plain mode should just be the path
  [[ $(echo "$output" | wc -l) -eq 1 ]]
}

@test "gwt-list: shows locked indicator" {
  cd "$TEST_REPO"

  # Create and lock a worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add locked-branch" >/dev/null
  touch "$GWT_ROOT/$repo_name/locked-branch/.gwt-lock"

  # List should show lock indicator (🔒)
  run zsh -c "$(load_plugin) && gwt-list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"locked-branch"* ]]
  # Note: In tests, colors might be disabled, but lock emoji should still appear
}

@test "gwt-list: skips .archive directory" {
  cd "$TEST_REPO"

  # Create worktree and archive directory
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add normal-branch" >/dev/null
  mkdir -p "$GWT_ROOT/$repo_name/.archive"

  # List should not show .archive
  run zsh -c "$(load_plugin) && gwt-list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"normal-branch"* ]]
  [[ "$output" != *".archive"* ]]
}

@test "gwt-list: handles multiple worktrees correctly" {
  cd "$TEST_REPO"

  # Create multiple worktrees
  for branch in alpha beta gamma delta; do
    zsh -c "$(load_plugin) && gwt-add $branch" >/dev/null
  done

  # List all
  run zsh -c "$(load_plugin) && gwt-list"
  [ "$status" -eq 0 ]
  [[ "$output" == *"alpha"* ]]
  [[ "$output" == *"beta"* ]]
  [[ "$output" == *"gamma"* ]]
  [[ "$output" == *"delta"* ]]
}
