#!/usr/bin/env bats
# Tests for gwt-main command (deprecated, kept for backwards compatibility)

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

@test "gwt-main: shows deprecation notice" {
  cd "$TEST_REPO"

  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-main 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"deprecated"* ]]
  [[ "$output" == *"gwt repo"* ]]
}

@test "gwt-main: delegates to gwt-repo" {
  cd "$TEST_REPO"

  # gwt-main should call gwt-repo
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-main && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_REPO"* ]]
  [[ "$output" == *"Switched to repository root"* ]]
}

@test "gwt-main: still works from within a worktree" {
  cd "$TEST_REPO"
  local repo_name=$(basename "$TEST_REPO")

  # Create worktree
  git worktree add "$GWT_ROOT/$repo_name/feat/feature-branch" -b feat/feature-branch >/dev/null 2>&1

  # From within worktree, gwt-main should still work (via gwt-repo)
  run zsh -c "$(load_plugin) && cd '$GWT_ROOT/$repo_name/feat/feature-branch' && gwt-main 2>&1"
  # Should show deprecation notice
  [[ "$output" == *"deprecated"* ]]
}

@test "gwt-main: backwards compatible with old behavior" {
  cd "$TEST_REPO"

  # Should still navigate to repo root despite deprecation
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-main && pwd"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_REPO"* ]]
}
