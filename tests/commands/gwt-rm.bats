#!/usr/bin/env bats
# Tests for gwt-rm command

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-rm: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-rm"
  [ "$status" -eq 0 ]
}

@test "gwt-rm: shows usage when no branch provided" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-rm"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "gwt-rm: fails when worktree does not exist" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-rm nonexistent-branch"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "gwt-rm: fails when worktree is locked" {
  cd "$TEST_REPO"

  # Create and lock a worktree
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add locked-branch" >/dev/null
  touch "$GWT_ROOT/$repo_name/locked-branch/.gwt-lock"

  # Try to remove
  run zsh -c "$(load_plugin) && gwt-rm locked-branch"
  [ "$status" -eq 1 ]
  [[ "$output" == *"locked"* ]]
}

@test "gwt-rm: removes clean worktree with no changes" {
  cd "$TEST_REPO"

  # Create worktree
  zsh -c "$(load_plugin) && gwt-add test-remove" >/dev/null

  # Remove it (provide 'n' to branch deletion prompt)
  run zsh -c "$(load_plugin) && echo 'n' | gwt-rm test-remove"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree"* ]]

  # Verify it's gone
  local repo_name=$(basename "$TEST_REPO")
  [ ! -d "$GWT_ROOT/$repo_name/test-remove" ]
}

@test "gwt-rm: prompts for confirmation when changes exist" {
  cd "$TEST_REPO"

  # Create worktree with changes
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add dirty-branch" >/dev/null

  # Make changes
  echo "modified" >> "$GWT_ROOT/$repo_name/dirty-branch/README.md"

  # Decline removal
  run zsh -c "$(load_plugin) && echo 'n' | gwt-rm dirty-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"uncommitted changes"* ]]
  [[ "$output" == *"Cancelled"* ]]

  # Verify still exists
  [ -d "$GWT_ROOT/$repo_name/dirty-branch" ]
}

@test "gwt-rm: removes worktree with changes when confirmed" {
  cd "$TEST_REPO"

  # Create worktree with changes
  local repo_name=$(basename "$TEST_REPO")
  zsh -c "$(load_plugin) && gwt-add dirty-branch" >/dev/null

  # Make changes
  echo "modified" >> "$GWT_ROOT/$repo_name/dirty-branch/README.md"

  # Confirm removal (y for changes, n for branch deletion)
  run zsh -c "$(load_plugin) && echo -e 'y\nn' | gwt-rm dirty-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removed worktree"* ]]

  # Verify it's gone
  [ ! -d "$GWT_ROOT/$repo_name/dirty-branch" ]
}

@test "gwt-rm: does not prompt to delete main branch" {
  cd "$TEST_REPO"

  # Create main worktree
  zsh -c "$(load_plugin) && gwt-add main" >/dev/null 2>&1 || true

  # Remove should not ask about deleting main branch
  # This test just verifies the logic - actual removal depends on git allowing it
  run zsh -c "$(load_plugin) && echo 'n' | gwt-rm main 2>&1 || echo 'Expected to fail or succeed without branch prompt'"
  # Either succeeds or fails, but shouldn't ask about branch deletion for main
  [[ "$output" != *"Delete branch 'main'"* ]]
}

@test "gwt-rm: removes branch when confirmed" {
  cd "$TEST_REPO"

  # Create and remove worktree, confirm branch deletion
  zsh -c "$(load_plugin) && gwt-add feature-delete" >/dev/null

  # Remove worktree and delete branch (answer 'n' to branch prompt since no changes, then 'y' to branch deletion)
  run zsh -c "$(load_plugin) && echo 'y' | gwt-rm feature-delete"
  [ "$status" -eq 0 ]

  # Verify branch is deleted
  cd "$TEST_REPO"
  run git branch --list feature-delete
  [ "$status" -eq 0 ]
  [[ -z "$output" ]]
}
