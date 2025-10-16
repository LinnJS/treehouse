# Development Guide

This guide covers everything you need to know for developing and testing treehouse locally.

## Quick Start

```zsh
# Clone the repo
git clone https://github.com/linnjs/treehouse
cd treehouse

# Quick test
make quick

# Full test suite
brew install bats-core  # Install BATS first (macOS)
make test
```

## Project Structure

```zsh
treehouse/
├── treehouse.plugin.zsh       # Minimal autoload loader (74 lines)
├── functions/                 # User-facing commands (26 files)
│   ├── gwt, gwt-help, gwt-list, gwt-add, gwt-rm, gwt-status
│   ├── gwt-switch, gwt-open, gwt-main, gwt-prune
│   ├── gwt-migrate, gwt-clean, gwt-mv
│   ├── gwt-lock, gwt-unlock, gwt-locks
│   ├── gwt-archive, gwt-unarchive, gwt-archives
│   ├── gwt-pr, gwt-diff, gwt-stash-list
│   ├── gwt-ignore, gwt-unignore, gwt-ignored
│   ├── gwt-excludes, gwt-excludes-list, gwt-excludes-edit
│   └── internal/              # Internal helper functions (8 files)
│       ├── _gwt_repo, _gwt_name, _gwt_branch
│       ├── _gwt_path_for, _gwt_current_path
│       └── _gwt_has_fzf, _gwt_has_tmux, _gwt_has_direnv
├── completions/               # Shell completions (3 files)
│   ├── _gwt, _gwt_branches, _gwt_clean_options
├── lib/                       # Core libraries
│   ├── config.zsh             # Configuration variables
│   └── colors.zsh             # Color support
├── tests/                     # Test suite
│   ├── core.bats              # Core plugin tests (8 tests)
│   ├── commands/              # Command tests (26 files)
│   │   ├── gwt-*.bats         # One test per command
│   │   └── README.md          # Test expansion guide
│   ├── helpers/               # Test utilities
│   │   └── test_helper.bash   # Shared test setup
│   └── README.md              # Test documentation
├── docs/                      # Documentation
├── .github/                   # GitHub workflows and templates
├── Makefile                   # Build/test commands
├── reload.sh                  # Development reload script
├── quick-start.sh             # Interactive setup script
├── README.md                  # Main documentation
├── CHANGELOG.md               # Version history
├── CONTRIBUTING.md            # Contribution guidelines
├── LICENSE                    # MIT License
└── VERSION                    # Current version
```

## Local Testing

### Method 1: Using Make (Recommended)

```zsh
# Show available commands
make help

# Quick load test
make quick

# Run full test suite
make test

# Install to Oh My Zsh
make install

# Clean test artifacts
make clean
```

### Method 2: Manual Testing

```zsh
# Load in current shell
source treehouse.plugin.zsh

# Test commands
gwt help
gwt origin
gwt-list
gwt-status

# Test with clean environment
zsh -c 'source treehouse.plugin.zsh && gwt help'
```

### Method 3: Test in Docker (Clean Environment)

```zsh
# Create test container with Zsh
docker run -it --rm -v $(pwd):/plugin alpine:latest sh -c '
  apk add --no-cache zsh git make &&
  cd /plugin &&
  zsh -c "source treehouse.plugin.zsh && gwt help"
'
```

## Running Tests

### Prerequisites

Install BATS (Bash Automated Testing System):

```zsh
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt-get install bats

# From source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

### Running Tests

```zsh
# Run all tests (67 tests: 8 core + 59 command tests)
make test

# Run core tests only (8 tests)
make test-core

# Run command tests only (59 tests)
make test-commands

# Run tests directly with BATS
bats tests/core.bats

# Run specific command test
bats tests/commands/gwt-add.bats

# Verbose output
bats --verbose-run tests/core.bats
```

### Writing Tests

Create new test files in `tests/commands/` with `.bats` extension:

```zsh
#!/usr/bin/env bats
# Tests for gwt-my-feature command

load ../helpers/test_helper

setup() {
  setup_test_repo  # Creates test git repo
}

teardown() {
  teardown_test_repo  # Cleans up
}

@test "gwt-my-feature: command is autoloadable" {
  run zsh -c "$(load_plugin) && command -v gwt-my-feature"
  [ "$status" -eq 0 ]
}

@test "gwt-my-feature: works correctly" {
  cd "$TEST_REPO"
  run zsh -c "$(load_plugin) && gwt-my-feature"
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected output"* ]]
}
```

See `tests/README.md` and `tests/commands/README.md` for detailed guidelines.

## Debugging

### Enable Debug Output

```zsh
# Set debug mode
export GWT_DEBUG=1

# Source plugin
source treehouse.plugin.zsh

# Commands will now show debug output
gwt main
```

### Trace Execution

```zsh
# Enable shell tracing
set -x
source treehouse.plugin.zsh
gwt help
set +x
```

### Test Configuration

```zsh
# Test with custom configuration
export GWT_ROOT="/tmp/test-worktrees"
export GWT_OPEN_CMD="echo"
export GWT_USE_TMUX="0"

source treehouse.plugin.zsh
gwt help
```

## Testing with Different Plugin Managers

### Oh My Zsh

```zsh
# Symlink to Oh My Zsh custom plugins
ln -sf $(pwd) ~/.oh-my-zsh/custom/plugins/treehouse

# Add to ~/.zshrc
plugins=(... treehouse)

# Reload
source ~/.zshrc
```

### Zinit

```zsh
# Load directly from local directory
zinit load $(pwd)
```

### Antidote

```zsh
# Add to ~/.zsh_plugins.txt
/full/path/to/treehouse

# Reload
antidote load
```

### Manual

```zsh
# Add to ~/.zshrc
source /path/to/treehouse/treehouse.plugin.zsh

# Reload
source ~/.zshrc
```

## Common Development Tasks

### Adding a New Command

1. Create new file in `functions/gwt-mycommand` (no .zsh extension)
2. Write function body WITHOUT function wrapper (for autoload compatibility)
3. Add to autoload list in `treehouse.plugin.zsh`
4. Add completion if needed (in `completions/`)
5. Create test file `tests/commands/gwt-mycommand.bats`
6. Add to help command in `functions/gwt-help`
7. Update CHANGELOG.md

Example function structure:

```zsh
# functions/gwt-mycommand
# Description of the command

local arg="$1"

if [[ -z "$arg" ]]; then
  echo "Usage: gwt mycommand <arg>" >&2
  return 1
fi

# Command logic here
echo "✓ Command executed: $arg"
```

### Performance Testing

```zsh
# Time plugin load
time (source treehouse.plugin.zsh)

# Profile with zprof
zmodload zsh/zprof
source treehouse.plugin.zsh
zprof
```

## Troubleshooting

### Plugin Not Loading

```zsh
# Check for errors
zsh -xv -c 'source treehouse.plugin.zsh' 2>&1 | less

# Check dependencies
command -v git
echo $ZSH_VERSION
```

### Commands Not Found

```zsh
# Check if functions are loaded
declare -f gwt
declare -f _gwt_repo

# Check fpath
echo $fpath

# Reload completions
autoload -U compinit && compinit
```

### Tests Failing

```zsh
# Run with verbose output
bats --verbose-run tests/core.bats

# Check BATS version
bats --version  # Should be 1.0 or higher

# Clean environment test
env -i HOME=$HOME PATH=$PATH zsh -c 'source treehouse.plugin.zsh && gwt help'
```

## Continuous Integration (Local)

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```zsh
#!/bin/sh
make quick || exit 1
make test || exit 1
```

Make it executable:

```zsh
chmod +x .git/hooks/pre-commit
```

## Tips

1. **Always test in clean shell**: Use `zsh -c` for isolated testing
2. **Check both Zsh versions**: Test with 5.8 and 5.9 if possible
3. **Test error cases**: Don't just test happy path
4. **Use `make clean`**: Clean up test artifacts regularly
5. **Document changes**: Update help text and README
