# Treehouse Test Suite

## Structure

```text
tests/
├── core.bats                    # Plugin loading and core functionality tests
├── commands/                    # One test file per command (26 files)
│   ├── gwt-add.bats
│   ├── gwt-list.bats
│   ├── gwt-rm.bats
│   └── ... (23 more)
└── helpers/
    └── test_helper.bash         # Shared setup/teardown functions
```

## Running Tests

**All tests (default):**

```bash
make test
```

**Core tests only:**

```bash
make test-core
```

**Command tests only:**

```bash
make test-commands
```

**Single command test:**

```bash
bats tests/commands/gwt-add.bats
```

## Test Structure

Each command test file follows this pattern:

1. **Basic structure test** - Verifies command is autoloadable
2. **Usage test** - Checks error messages and help text
3. **Flag/argument tests** - Validates accepted options
4. **TODO comments** - Placeholder for comprehensive tests

## Adding Comprehensive Tests

Each test file has TODO comments indicating what should be tested:

```bash
# TODO: Add comprehensive tests
# - Creates worktree successfully
# - Creates worktree from specific branch with --from
# - Sets up tracking with --track
```

To add full coverage:

1. Expand the TODO section with actual test cases
2. Use `setup_test_repo` helper for git repo setup
3. Use `load_plugin` helper to source the plugin
4. Add teardown with `teardown_test_repo`

## Test Helpers

Located in `tests/helpers/test_helper.bash`:

- `setup_test_repo()` - Creates a test git repository
- `teardown_test_repo()` - Cleans up test artifacts
- `load_plugin()` - Returns command to source the plugin

## Requirements

- [bats-core](https://github.com/bats-core/bats-core) - Test framework
- zsh - Shell interpreter
- git - Version control

Install bats:

```bash
# macOS
brew install bats-core

# Linux
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```
