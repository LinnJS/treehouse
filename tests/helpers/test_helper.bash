#!/usr/bin/env bash
# Shared test helpers for treehouse tests

# Common setup for most tests
setup_test_repo() {
  export PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."
  export GWT_ROOT="/tmp/treehouse-test-$$"
  export GWT_TEST_MODE=1
  
  # Create a test git repository
  export TEST_REPO="/tmp/test-repo-$$"
  mkdir -p "$TEST_REPO"
  cd "$TEST_REPO"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test User"
  echo "test" > README.md
  git add README.md
  git commit -q -m "Initial commit"
  git checkout -b main 2>/dev/null || git branch -M main
}

# Common teardown
teardown_test_repo() {
  rm -rf "$GWT_ROOT" "$TEST_REPO" 2>/dev/null || true
}

# Load the plugin in a subshell
load_plugin() {
  echo "source ${PLUGIN_DIR}/treehouse.plugin.zsh"
}
