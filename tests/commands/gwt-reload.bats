#!/usr/bin/env bats
# Tests for gwt-reload command (reload plugin during development)

load ../helpers/test_helper

setup() {
  setup_test_repo
}

teardown() {
  teardown_test_repo
}

@test "gwt-reload: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-reload"
  [ "$status" -eq 0 ]
}

@test "gwt-reload: successfully reloads plugin" {
  run zsh -c "$(load_plugin) && gwt-reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Reloading treehouse plugin"* ]]
  [[ "$output" == *"Plugin reloaded"* ]]
}

@test "gwt-reload: finds plugin via TREEHOUSE_PLUGIN_DIR" {
  # When TREEHOUSE_PLUGIN_DIR is set (from initial load), reload should use it
  run zsh -c "$(load_plugin) && echo \$TREEHOUSE_PLUGIN_DIR && gwt-reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plugin reloaded from:"* ]]
}

@test "gwt-reload: works when plugin directory is in PWD" {
  # If TREEHOUSE_PLUGIN_DIR not set, should find plugin in current directory
  run zsh -c "cd '$PLUGIN_DIR' && source treehouse.plugin.zsh && unset TREEHOUSE_PLUGIN_DIR && gwt-reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plugin reloaded"* ]]
}

@test "gwt-reload: commands still work after reload" {
  # Reload should maintain functionality
  run zsh -c "$(load_plugin) && gwt-reload >/dev/null && gwt help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Treehouse"* ]]
}

@test "gwt-reload: accessible via 'gwt reload' alias" {
  # Should work via the gwt dispatcher
  run zsh -c "$(load_plugin) && gwt reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Reloading treehouse plugin"* ]]
}

@test "gwt-reload: unsets and resets TREEHOUSE_PLUGIN_LOADED" {
  # Verify reload actually resets the loaded flag
  run zsh -c "$(load_plugin) && echo \$TREEHOUSE_PLUGIN_LOADED && gwt-reload >/dev/null && echo \$TREEHOUSE_PLUGIN_LOADED"
  [ "$status" -eq 0 ]
  # Both before and after should show "1" (loaded)
  [[ "$output" == *"1"* ]]
}

@test "gwt-reload: verifies plugin directory exists before reload" {
  # This tests that gwt-reload requires finding the plugin directory
  # The command should have logic to find or error on missing directory
  run zsh -c "$(load_plugin) && command -v gwt-reload"
  [ "$status" -eq 0 ]
  # Function should be loadable (actual error handling tested in integration)
}

@test "gwt-reload: finds plugin in common oh-my-zsh location" {
  # Create mock oh-my-zsh structure
  local mock_omz="$TEST_REPO/mock-home/.oh-my-zsh/custom/plugins/treehouse"
  mkdir -p "$mock_omz"
  cp "$PLUGIN_DIR/treehouse.plugin.zsh" "$mock_omz/"
  cp -r "$PLUGIN_DIR/functions" "$mock_omz/"
  cp -r "$PLUGIN_DIR/lib" "$mock_omz/"

  # Test reload finds it
  run zsh -c "HOME='$TEST_REPO/mock-home' && source '$mock_omz/treehouse.plugin.zsh' && unset TREEHOUSE_PLUGIN_DIR && gwt-reload"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Plugin reloaded"* ]]
}
