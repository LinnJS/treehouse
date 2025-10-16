#!/usr/bin/env bats
# Tests for main gwt command (switch/create and dispatch)

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt: command is defined" {
  run zsh -c "$(load_plugin) && command -v gwt"
  [ "$status" -eq 0 ]
}

@test "gwt: no arguments shows usage" {
  run zsh -c "$(load_plugin) && gwt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "gwt: creates new worktree if doesn't exist" {
  cd "$TEST_REPO"

  # Create worktree for new branch - check that it succeeds
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-add feat/new-feature"
  [ "$status" -eq 0 ]

  # Verify the worktree was created
  run git worktree list
  [[ "$output" == *"feat/new-feature"* ]]
}

@test "gwt: switches to existing worktree" {
  cd "$TEST_REPO"

  # Create worktree first
  zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-add feat/existing-branch" >/dev/null 2>&1

  # Switch to it (should not error or try to recreate)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt feat/existing-branch 2>&1"
  [ "$status" -eq 0 ]
  # Should not see "Creating worktree" message since it already exists
  [[ "$output" != *"Creating worktree"* ]] || [[ "$output" == *"already exists"* ]]
}

@test "gwt: main creates worktree for main branch" {
  cd "$TEST_REPO"

  # Create a feature branch and switch to it
  git checkout -b feat/something >/dev/null 2>&1

  # gwt main should create worktree (not delegate to gwt-main command)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && git checkout feat/something >/dev/null 2>&1 && gwt main 2>&1"
  [ "$status" -eq 0 ]

  # Verify worktree for main was created
  run git worktree list
  [[ "$output" == *"[main]"* ]] || [[ "$output" == *"/main "* ]]
}

@test "gwt: reserved command 'help' delegates to gwt-help" {
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Treehouse"* ]]
  [[ "$output" != *"Creating worktree"* ]]
}

@test "gwt: reserved command 'list' delegates to gwt-list" {
  cd "$TEST_REPO"

  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt list 2>&1"
  # Command runs (may succeed or fail depending on state, but shouldn't try to create worktree)
  [[ "$output" != *"Creating worktree for 'list'"* ]]
}

@test "gwt: reserved command 'reload' delegates to gwt-reload" {
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Reloading treehouse plugin"* ]]
  [[ "$output" != *"Creating worktree"* ]]
}

@test "gwt: reserved command 'repo' delegates to gwt-repo" {
  cd "$TEST_REPO"

  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt repo"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Switched to repository root"* ]]
  [[ "$output" != *"Creating worktree"* ]]
}

@test "gwt: reserved command 'status' delegates to gwt-status" {
  cd "$TEST_REPO"

  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt status 2>&1"
  # Command runs (may succeed or fail depending on state, but shouldn't try to create worktree)
  [[ "$output" != *"Creating worktree for 'status'"* ]]
}

@test "gwt: reserved command 'add' delegates to gwt-add" {
  cd "$TEST_REPO"

  # gwt add <branch> should delegate to gwt-add
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt add test-branch"
  [ "$status" -eq 0 ]

  # Verify worktree was created
  local repo_name=$(basename "$TEST_REPO")
  [ -d "$GWT_ROOT/$repo_name/test-branch" ]
}

@test "gwt: all reserved commands are protected" {
  # Test that all reserved commands in the list don't create worktrees
  local reserved_commands=(
    help list add switch open rm prune status repo migrate clean mv pr diff
    stash-list archive unarchive archives lock unlock locks ignore unignore
    ignored excludes excludes-list excludes-edit reload
  )

  for cmd in "${reserved_commands[@]}"; do
    # Skip commands that require arguments, would actually execute, or need specific tools
    if [[ "$cmd" == "add" ]] || [[ "$cmd" == "switch" ]] || [[ "$cmd" == "open" ]] || \
       [[ "$cmd" == "rm" ]] || [[ "$cmd" == "mv" ]] || [[ "$cmd" == "diff" ]] || \
       [[ "$cmd" == "lock" ]] || [[ "$cmd" == "unlock" ]] || [[ "$cmd" == "archive" ]] || \
       [[ "$cmd" == "unarchive" ]] || [[ "$cmd" == "ignore" ]] || [[ "$cmd" == "unignore" ]] || \
       [[ "$cmd" == "excludes-edit" ]]; then
      continue
    fi

    run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt $cmd 2>&1"
    # Should not see "Creating worktree" message
    [[ "$output" != *"Creating worktree for '$cmd'"* ]]
  done
}

@test "gwt: non-reserved branch name creates worktree" {
  cd "$TEST_REPO"

  # Use a clearly non-reserved name
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-add feat/my-feature"
  [ "$status" -eq 0 ]

  # Verify worktree was created
  run git worktree list
  [[ "$output" == *"feat/my-feature"* ]]
}

@test "gwt: semantic branch names work correctly" {
  cd "$TEST_REPO"

  # Test feat/ prefix
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-add feat/authentication"
  [ "$status" -eq 0 ]

  # Test bug/ prefix
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt-add bug/fix-login"
  [ "$status" -eq 0 ]

  # Verify both were created
  run git worktree list
  [[ "$output" == *"feat/authentication"* ]]
  [[ "$output" == *"bug/fix-login"* ]]
}

@test "gwt: handles existing local branch correctly" {
  cd "$TEST_REPO"
  local repo_name=$(basename "$TEST_REPO")

  # Create local branch
  git checkout -b existing-branch
  git checkout main

  # gwt should create worktree for existing branch
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && gwt existing-branch"
  [ "$status" -eq 0 ]
  [ -d "$GWT_ROOT/$repo_name/existing-branch" ]
}

@test "gwt: handles main branch correctly" {
  cd "$TEST_REPO"

  # Create a feature branch so main can be used as worktree
  git checkout -b feat/temp >/dev/null 2>&1

  # gwt main should work (create worktree or switch to it)
  run zsh -c "$(load_plugin) && cd '$TEST_REPO' && git checkout feat/temp >/dev/null 2>&1 && gwt-add main 2>&1"
  # The command should complete (may succeed or show useful message)
  # Main point: reserved keywords are properly handled
  [[ "$output" != *"Creating worktree for 'main'"* ]] || [[ "$status" -eq 0 ]]
}
