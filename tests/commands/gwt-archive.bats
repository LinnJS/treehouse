#!/usr/bin/env bats
# Tests for gwt-archive command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-archive: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-archive"
  [ "$status" -eq 0 ]
}

@test "gwt-archive: shows usage when no branch provided" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-archive"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "gwt-archive: archives existing worktree" {
  cd "$TEST_REPO"

  # Create worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add test-branch" >/dev/null

  # Archive it
  run zsh -c "$(load_plugin) && gwt-archive test-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Archived worktree"* ]]

  # Verify moved to archive directory
  [ ! -d "$GWT_ROOT/$repo_name/test-branch" ]
  [ -d "$GWT_ROOT/$repo_name/.archive/test-branch" ]
}

@test "gwt-archive: fails when worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-archive nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "gwt-archive: fails when archived worktree already exists" {
  cd "$TEST_REPO"

  # Create and archive worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add dup-archive" >/dev/null
  zsh -c "$(load_plugin) && gwt-archive dup-archive" >/dev/null

  # Manually create a duplicate in the archive to test the error condition
  mkdir -p "$GWT_ROOT/$repo_name/.archive/dup-archive-2"

  # Create another worktree and try to archive with the duplicate name
  zsh -c "$(load_plugin) && gwt-add dup-archive-2" >/dev/null
  run zsh -c "$(load_plugin) && gwt-archive dup-archive-2"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}
