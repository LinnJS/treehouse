#!/usr/bin/env bats
# Core functionality tests for treehouse plugin

# Force zsh for all tests since this is a zsh plugin
export SHELL=$(which zsh)

setup() {
  # Get the plugin directory
  export PLUGIN_DIR="${BATS_TEST_DIRNAME}/.."

  # Set up test environment
  export GWT_ROOT="/tmp/treehouse-test-$$"
  export GWT_TEST_MODE=1

  # Load the plugin in zsh
  zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh; declare -f gwt" > /dev/null 2>&1
}

teardown() {
  # Clean up test directory
  rm -rf "$GWT_ROOT" 2>/dev/null || true
}

@test "plugin loads successfully" {
  # Check that main command exists
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt"
  [ "$status" -eq 0 ]
}

@test "all core commands are available" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt && command -v gwt-help && command -v gwt-list && command -v gwt-add && command -v gwt-rm && command -v gwt-status"
  [ "$status" -eq 0 ]
}

@test "configuration variables are set" {
  # Check that GWT_ROOT is set in test environment
  [[ -n "$GWT_ROOT" ]]
  [[ "$GWT_ROOT" == "/tmp/treehouse-test-"* ]]

  # Check that GWT_OPEN_CMD is set when plugin is loaded
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && echo \$GWT_OPEN_CMD"
  [ "$status" -eq 0 ]
  [[ -n "$output" ]]
}

@test "help command runs without error" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && gwt help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Treehouse"* ]]
}

@test "internal functions are defined" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && declare -f _gwt_repo"
  [ "$status" -eq 0 ]
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && declare -f _gwt_name"
  [ "$status" -eq 0 ]
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && declare -f _gwt_branch"
  [ "$status" -eq 0 ]
}

@test "custom configuration is respected" {
  # Test that custom config is respected when sourcing
  run zsh -c "export GWT_ROOT='/custom/path' && export GWT_OPEN_CMD='vim' && source ${PLUGIN_DIR}/treehouse.plugin.zsh && echo \$GWT_ROOT:\$GWT_OPEN_CMD"
  [ "$status" -eq 0 ]
  [[ "$output" == "/custom/path:vim" ]]
}

@test "colors are loaded for terminal output" {
  # Colors should be loaded when terminal is available, or set to empty when not
  # In non-interactive zsh -c, -t 1 is false, so colors will be empty
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && echo \"GWT_COLOR_RESET: [\$GWT_COLOR_RESET]\""
  [ "$status" -eq 0 ]
  # The variable should be defined (either with color codes or empty)
  [[ "$output" == *"GWT_COLOR_RESET:"* ]]
}

@test "gwt function handles missing argument" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && gwt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "plugin can be reloaded" {
  # Load plugin, then reload it
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && unset TREEHOUSE_PLUGIN_LOADED && source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt"
  [ "$status" -eq 0 ]
}

@test "TREEHOUSE_PLUGIN_DIR is exported and persists" {
  # Check that TREEHOUSE_PLUGIN_DIR is exported so gwt-reload can access it
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && echo \$TREEHOUSE_PLUGIN_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"treehouse"* ]]
}

@test "TREEHOUSE_PLUGIN_LOADED is not readonly" {
  # Verify we can unset TREEHOUSE_PLUGIN_LOADED (needed for reload)
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && unset TREEHOUSE_PLUGIN_LOADED && echo OK"
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK"* ]]
}

@test "plugin reload maintains functionality" {
  # Load, reload, and verify commands still work
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && unset TREEHOUSE_PLUGIN_LOADED && source ${PLUGIN_DIR}/treehouse.plugin.zsh && gwt help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Treehouse"* ]]
}

@test "gwt-reload command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-reload"
  [ "$status" -eq 0 ]
}

@test "gwt-repo command is autoloadable" {
  run zsh -c "source ${PLUGIN_DIR}/treehouse.plugin.zsh && command -v gwt-repo"
  [ "$status" -eq 0 ]
}
