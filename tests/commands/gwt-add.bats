#!/usr/bin/env bats
# Tests for gwt-add command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-add: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-add"
  [ "$status" -eq 0 ]
}

@test "gwt-add: shows usage when no branch provided" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-add"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "gwt-add: creates new worktree with new branch" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-add feature-test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Created worktree"* ]]

  # Verify worktree was created
  local repo_name=$(basename "$TEST_REPO")
  [ -d "$GWT_ROOT/$repo_name/feature-test" ]
}

@test "gwt-add: fails when worktree already exists" {
  cd "$TEST_REPO"

  # Create first worktree
  run zsh -c "$(load_plugin) && gwt-add feature-dup"
  [ "$status" -eq 0 ]

  # Try to create again
  run zsh -c "$(load_plugin) && gwt-add feature-dup"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "gwt-add: creates worktree from existing branch" {
  cd "$TEST_REPO"

  # Create a branch manually
  git checkout -b existing-branch
  git checkout main

  # Create worktree from existing branch
  run zsh -c "$(load_plugin) && gwt-add existing-branch"
  [ "$status" -eq 0 ]

  local repo_name=$(basename "$TEST_REPO")
  [ -d "$GWT_ROOT/$repo_name/existing-branch" ]
}

@test "gwt-add: creates worktree with --from option" {
  cd "$TEST_REPO"

  # Create a feature branch from main
  run zsh -c "$(load_plugin) && gwt-add feature-from --from main"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Created worktree"* ]]

  local repo_name=$(basename "$TEST_REPO")
  [ -d "$GWT_ROOT/$repo_name/feature-from" ]
}

@test "gwt-add: rejects unknown options" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-add feature-test --invalid-option"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "gwt-add: creates parent directory if needed" {
  cd "$TEST_REPO"

  # Remove GWT_ROOT to test directory creation
  rm -rf "$GWT_ROOT"

  run zsh -c "$(load_plugin) && gwt-add new-feature"
  [ "$status" -eq 0 ]

  local repo_name=$(basename "$TEST_REPO")
  [ -d "$GWT_ROOT/$repo_name/new-feature" ]
}
