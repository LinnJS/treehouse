# Command Tests

## Status

These are **skeleton tests** - basic autoload verification only.

Each test file contains:
- ✅ Single test: Verifies command is autoloadable (fast)
- 📝 TODO comments for adding comprehensive tests later

**Why so minimal?** To keep `make test` fast while still verifying all commands exist and can be loaded.

## Running Tests

All tests run quickly (no git repo setup in skeleton tests):

```bash
# All tests (34 tests: 8 core + 26 commands)
make test

# Core tests only (8 tests)
make test-core

# Command tests only (26 tests)
make test-commands

# Single command test
bats tests/commands/gwt-add.bats
```

**Current results:** All 34 tests passing ✅

## Expanding Tests

When adding comprehensive coverage to a command:

1. Use `load ../helpers/test_helper` to get shared setup
2. Add `setup()` with `setup_test_repo` for git repo
3. Add `teardown()` with `teardown_test_repo` for cleanup
4. Add tests for actual command behavior
5. Consider adding integration tests separately

Example:
```bash
#!/usr/bin/env bats
# Tests for gwt-add command

load ../helpers/test_helper

setup() {
  setup_test_repo  # Creates git repo in /tmp
}

teardown() {
  teardown_test_repo  # Cleans up
}

@test "gwt-add: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-add"
  [ "$status" -eq 0 ]
}

@test "gwt-add: creates worktree successfully" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-add feature-branch"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Created worktree"* ]]
}
```

## Current Test Coverage

- **Core plugin**: ✅ 8/8 tests passing
- **Commands**: 📝 26 skeleton files ready for expansion
- **Total**: 26 commands with test structure in place
