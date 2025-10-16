# 🏡 treehouse

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/linnjs/treehouse/releases)
[![Zsh](https://img.shields.io/badge/zsh-%3E%3D5.8-green.svg)](https://www.zsh.org/)
[![Tests](https://github.com/linnjs/treehouse/actions/workflows/test.yml/badge.svg)](https://github.com/linnjs/treehouse/actions/workflows/test.yml)

> Multiple branches, zero context switching hassle, live in worktrees!

**treehouse** brings the power of git worktrees to your fingertips. Work on multiple branches simultaneously without the context switching hassle - no more stashing, no more lost work, just pure productivity. Run tests on one branch while developing on another, and keep your main branch always ready to ship.

## ✨ Features

### Core Operations

- **Quick Switching**: Switch between worktrees with `gwt <branch>` (creates if needed)
- **Create Worktrees**: Create worktrees with `gwt add <branch>`
- **Safe Removal**: Remove worktrees and branches with `gwt rm`
- **Listing**: View all worktrees with `gwt list`
- **Status Overview**: Track uncommitted changes across all worktrees with `gwt status`

### Organization & Management

- **Organized Layout**: Structured worktree organization in `~/.worktrees`
- **Branch Operations**: Move/rename worktrees while preserving git state
- **Main Branch Access**: Quick navigation to main/master branch
- **Migration Tools**: Convert existing repos to worktree workflow
- **Pruning**: Remove stale worktree references

### Protection & Archiving

- **Lock System**: Protect important worktrees from accidental deletion
- **Archive Management**: Hide inactive worktrees without deleting them
- **Lock Status**: View all locked worktrees at a glance

### GitHub Integration

- **PR Worktrees**: Create worktrees from GitHub PR numbers
- **Diff Viewing**: Compare worktrees and branches
- **Stash Management**: List stashes across all worktrees

### File Management

- **Per-Worktree Ignores**: Add file patterns to `.git/info/exclude`
- **Ignore Management**: List and remove ignored patterns
- **Excludes Editor**: Edit exclusion rules with your preferred editor

### Cleanup & Maintenance

- **Bulk Cleanup**: Remove merged, stale, or old worktrees
- **Age-Based Cleanup**: Remove worktrees older than specified days
- **Dry Run**: Preview what will be removed before cleanup

### Tool Integration

- **fzf Support**: Interactive worktree selection with fuzzy finder
- **tmux Integration**: Automatic session management
- **direnv Support**: Per-worktree environment variables
- **Editor Integration**: Open worktrees in your preferred editor

## 🚀 Quick Start

### Prerequisites

- **Zsh** 5.8 or later
- **Git** 2.20 or later (for worktree support)
- **Optional**: fzf (for interactive selection), gh (for GitHub integration)

### Installation

#### Option 1: Oh My Zsh (Recommended)

```zsh
# Clone the plugin
git clone https://github.com/linnjs/treehouse ~/.oh-my-zsh/custom/plugins/treehouse

# Add to your ~/.zshrc
plugins=(... treehouse)

# Reload your shell
source ~/.zshrc
```

#### Option 2: Quick Start Script

```zsh
# Clone and run quick start
git clone https://github.com/linnjs/treehouse
cd treehouse
./quick-start.sh  # Interactive setup guide
```

#### Option 3: Manual Test

```zsh
# Clone and test locally
git clone https://github.com/linnjs/treehouse
cd treehouse

# Quick test
make quick  # or: zsh -c 'source treehouse.plugin.zsh && gwt help'

# Run full tests (requires bats)
brew install bats-core  # macOS
make test
```

### First Steps

```zsh
# After installation, test the plugin
gwt help                      # Show all commands

# Basic workflow
gwt main                      # Switch to main branch worktree
gwt feature-auth              # Create & switch to new feature
gwt list                      # List all worktrees
gwt status                    # Show status of all worktrees

# Advanced features
gwt lock main                 # Protect important worktrees
gwt clean --merged            # Clean up merged branches
gwt pr 123                    # Create worktree from GitHub PR
```

## 📦 Installation

### Oh My Zsh

```zsh
git clone https://github.com/linnjs/treehouse ~/.oh-my-zsh/custom/plugins/treehouse
```

Add to your `.zshrc`:

```zsh
plugins=(... treehouse)
```

### Zinit

```zsh
zinit light linnjs/treehouse
```

### Antidote

```zsh
# In ~/.zsh_plugins.txt
linnjs/treehouse
```

### Manual

```zsh
git clone https://github.com/linnjs/treehouse ~/treehouse
```

Add to your `.zshrc`:

```zsh
source ~/treehouse/treehouse.plugin.zsh
```

## ⚙️ Configuration

Customize treehouse by setting these variables in your `.zshrc` before loading the plugin:

```zsh
export GWT_ROOT="$HOME/projects/worktrees"  # Base directory for worktrees
export GWT_OPEN_CMD="nvim"                   # Editor command
export GWT_USE_TMUX="1"                      # Enable tmux integration
```

See full configuration options in the documentation (coming soon).

## 📚 Documentation

### Guides

- [Development Guide](docs/DEVELOPMENT.md) - Local setup, testing, and contributing code
- [Installation Guide](docs/INSTALLATION.md) - Coming in v0.2.0
- [Usage Guide](docs/USAGE.md) - Coming in v0.2.0
- [Configuration Reference](docs/CONFIGURATION.md) - Coming in v0.2.0

### Project Information

- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards
- [Security Policy](SECURITY.md) - Reporting vulnerabilities
- [Changelog](CHANGELOG.md) - Version history and changes

## 🎯 Project Status

**Current Version**: v0.1.0 (Initial Release)

The plugin features a complete modular architecture with 26 commands, comprehensive test coverage (67 tests), and lazy loading for optimal performance.

**Roadmap**:

- ✅ v0.1.0 - Initial release with modular architecture and testing
- 📋 v0.2.0 - Documentation improvements and additional features
- 📋 v0.3.0 - Enhanced integrations and performance optimizations

## 🛠️ Development

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for complete development guide including:
- Local testing and debugging
- Project structure
- Adding new commands
- Running tests
- CI/CD workflow

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

---

**Note**: treehouse is a rewrite of an earlier personal git worktrees workflow, now structured as a proper Zsh plugin.
