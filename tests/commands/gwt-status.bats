#!/usr/bin/env bats
# Tests for gwt-status command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-status: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-status"
  [ "$status" -eq 0 ]
}

@test "gwt-status: shows error when no worktrees exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-status"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No worktrees found"* ]]
}

@test "gwt-status: shows all worktrees are clean when no changes" {
  cd "$TEST_REPO"

  # Create some worktrees
  zsh -c "$(load_plugin) && gwt-add feature-one" >/dev/null
  zsh -c "$(load_plugin) && gwt-add feature-two" >/dev/null

  # Check status
  run zsh -c "$(load_plugin) && gwt-status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"All worktrees are clean"* ]]
}

@test "gwt-status: shows worktrees with uncommitted changes" {
  cd "$TEST_REPO"

  # Create worktree with changes
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add dirty-branch" >/dev/null

  # Make changes
  echo "new content" >> "$GWT_ROOT/$repo_name/dirty-branch/README.md"

  # Check status
  run zsh -c "$(load_plugin) && gwt-status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"dirty-branch"* ]]
  [[ "$output" == *"README.md"* ]]
}

@test "gwt-status: verbose mode shows all worktrees" {
  cd "$TEST_REPO"

  # Create clean worktrees
  zsh -c "$(load_plugin) && gwt-add clean-one" >/dev/null
  zsh -c "$(load_plugin) && gwt-add clean-two" >/dev/null

  # Verbose status should show all
  run zsh -c "$(load_plugin) && gwt-status -v"
  [ "$status" -eq 0 ]
  [[ "$output" == *"clean-one"* ]]
  [[ "$output" == *"clean-two"* ]]
  [[ "$output" == *"clean"* ]]
}

@test "gwt-status: shows lock indicator for locked worktrees" {
  cd "$TEST_REPO"

  # Create and lock a worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add locked-branch" >/dev/null
  touch "$GWT_ROOT/$repo_name/locked-branch/.gwt-lock"

  # Status should show lock indicator
  run zsh -c "$(load_plugin) && gwt-status -v"
  [ "$status" -eq 0 ]
  [[ "$output" == *"locked-branch"* ]]
}

@test "gwt-status: skips .archive directory" {
  cd "$TEST_REPO"

  # Create worktree and archive directory
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add normal-branch" >/dev/null
  mkdir -p "$GWT_ROOT/$repo_name/.archive"

  # Status should not show .archive
  run zsh -c "$(load_plugin) && gwt-status -v"
  [ "$status" -eq 0 ]
  [[ "$output" == *"normal-branch"* ]]
  [[ "$output" != *".archive"* ]]
}
