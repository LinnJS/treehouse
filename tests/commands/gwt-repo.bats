#!/usr/bin/env bats
# Tests for gwt-repo command (navigate to repository root)

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-repo: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-repo"
  [ "$status" -eq 0 ]
}

@test "gwt-repo: switches to repository root" {
  cd "$TEST_REPO"

  # Switch to repo root
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-repo && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_REPO"* ]]
  [[ "$output" == *"Switched to repository root"* ]]
}

@test "gwt-repo: works from within a worktree" {
  cd "$TEST_REPO"
  local repo_name=$(basename "$TEST_REPO")

  # Create worktree directly
  git worktree add "$GWT_ROOT/$repo_name/feat/feature-branch" -b feat/feature-branch >/dev/null 2>&1

  # From within worktree, go back to repo root
  run zsh -c "$(load_plugin) && cd '$GWT_ROOT/$repo_name/feat/feature-branch' && gwt-repo 2>&1"
  # Should show switched message
  [[ "$output" == *"Switched to repository root"* ]]
}

@test "gwt-repo: detects and checks out main branch" {
  cd "$TEST_REPO"

  # Create a feature branch and switch to it
  git checkout -b feat/temp-branch

  # gwt-repo should switch back to main
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && git checkout feat/temp-branch && gwt-repo && git branch --show-current"
  [ "$status" -eq 0 ]
  [[ "$output" == *"main"* ]]
}

@test "gwt-repo: detects master if no main branch" {
  cd "$TEST_REPO"

  # Rename main to master
  git branch -m main master

  # Create a feature branch
  git checkout -b feat/temp-branch

  # gwt-repo should switch to master
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && git checkout feat/temp-branch && gwt-repo && git branch --show-current"
  [ "$status" -eq 0 ]
  [[ "$output" == *"master"* ]]
}

@test "gwt-repo: navigates to repo root successfully" {
  cd "$TEST_REPO"

  # Create a feature branch
  git checkout -b feat/temp-branch >/dev/null 2>&1

  # gwt-repo should navigate to repo root
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-repo 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to repository root"* ]]
}

@test "gwt-repo: accessible via 'gwt repo' alias" {
  cd "$TEST_REPO"

  # Should work via the gwt dispatcher
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt repo && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to repository root"* ]]
  [[ "$output" == *"$TEST_REPO"* ]]
}
