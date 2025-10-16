# Contributing to treehouse

Thank you for your interest in contributing to treehouse! This document provides guidelines and instructions for contributing.

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please
read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Environment details** (Zsh version, OS, plugin manager)
- **Code samples** or error messages if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** explaining why this would be useful
- **Possible implementation** if you have ideas
- **Examples** from other tools if relevant

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** used throughout the project
3. **Write clear commit messages** using Conventional Commits format:
   - Format: `type(dir): Description` where `dir` is the component/directory/command
   - `feat(dir): Description` for new features
   - `fix(dir): Description` for bug fixes
   - `docs(dir): Description` for documentation changes
   - `test(dir): Description` for test additions/changes
   - `refactor(dir): Description` for code refactoring
   - `chore(dir): Description` for maintenance tasks

   Examples:
   - `feat(lock): Add archive support`
   - `fix(completion): Resolve branch name completion`
   - `docs(readme): Update installation instructions`
   - `test(core): Add worktree creation tests`
   - `refactor(functions): Modularize helper functions`
   - `chore(deps): Update dependencies`
4. **Update documentation** if you're changing functionality
5. **Add tests** if applicable
6. **Ensure all tests pass** before submitting
7. **Reference issues** in your PR description

## Development Setup

### Prerequisites

- Zsh 5.8 or higher
- Git 2.20 or higher
- Make (usually pre-installed)
- BATS for testing: `brew install bats-core` (macOS) or `sudo apt-get install bats` (Linux)

### Local Development

```zsh
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/treehouse
cd treehouse

# 2. Create a feature branch
git checkout -b feature/your-feature-name

# 3. Quick test that plugin loads
make quick

# 4. Load plugin in current shell for development
source treehouse.plugin.zsh

# 5. Test your changes interactively
gwt help                      # Test help
gwt main                      # Test main command

# 6. Run full test suite
make test

# 7. Commit with conventional commit format
git commit -m "feat(add): Support creating from remote branches"
```

### Testing

```zsh
# Quick load test
make quick

# Run full test suite (requires BATS)
make test

# Test specific commands manually
zsh -c 'source treehouse.plugin.zsh && gwt-list'

# Clean up test artifacts
make clean

# See all available commands
make help
```

### Makefile Commands

- `make help` - Show all available commands
- `make quick` - Quick plugin load test
- `make test` - Run all tests (67 tests: 8 core + 59 command tests)
- `make test-core` - Run core tests only (8 tests)
- `make test-commands` - Run command tests only (59 tests)
- `make install` - Install to Oh My Zsh
- `make clean` - Clean test artifacts

## Coding Style

### Zsh Best Practices

- Use `local` for function-scoped variables
- Quote variables: `"$variable"` not `$variable`
- Use `[[ ]]` for conditionals, not `[ ]`
- Prefer `${variable}` over `$variable` for clarity
- Use 2-space indentation (no tabs)
- Add comments for complex logic

### Function Documentation

Every function should have a documentation header:

```zsh
# Function: gwt-example
# Description: Brief description of what the function does
# Usage: gwt-example [options] <arguments>
# Arguments:
#   $1 - Description of first argument
# Options:
#   --option - Description of option
```

### Naming Conventions

- User commands: `gwt-command-name`
- Internal helpers: `_gwt_helper_name`
- Completion functions: `_gwt_command_completion`
- Use kebab-case for multi-word names

## Project Structure

```text
treehouse/
├── treehouse.plugin.zsh       # Minimal autoload loader (74 lines)
├── functions/                 # User-facing commands (26 files)
│   ├── gwt-*                  # Individual command files
│   └── internal/              # Internal helpers (8 files)
├── completions/               # Shell completions (3 files)
├── lib/                       # Core libraries
│   ├── config.zsh             # Configuration
│   └── colors.zsh             # Color support
├── tests/                     # Test suite (34 tests)
│   ├── core.bats              # Core tests (8)
│   ├── commands/              # Command tests (26)
│   ├── helpers/               # Test utilities
│   └── README.md              # Test documentation
├── docs/                      # Documentation
│   └── DEVELOPMENT.md         # Development guide
└── .github/                   # GitHub templates & workflows
```

## Version Support

- **Zsh**: 5.8+ (we test on 5.8 and 5.9)
- **Git**: 2.20+ (for worktree support)
- **OS**: macOS, Linux, WSL

## Commit Message Format

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated versioning and
changelog generation. All commits **must** follow this format:

```text
type(dir): Description
```

Where `type` is the commit type, `dir` is the component/directory/command name, and `Description` is a brief summary.

### Commit Types & Version Impact

- **feat** - New feature (triggers MINOR version bump)
- **fix** - Bug fix (triggers PATCH version bump)
- **perf** - Performance improvement (triggers PATCH version bump)
- **refactor** - Code refactoring (triggers PATCH version bump)
- **docs** - Documentation only (no version bump)
- **test** - Test changes (no version bump)
- **chore** - Maintenance tasks (no version bump)
- **ci** - CI configuration (no version bump)
- **style** - Code formatting (no version bump)
- **build** - Build system changes (no version bump)

### Breaking Changes

For breaking changes, add `!` after the type/scope or include `BREAKING CHANGE:` in the footer:

```text
feat(api)!: Remove deprecated authentication method

BREAKING CHANGE: Old auth method removed. Use OAuth2 instead.
```

This triggers a **MAJOR** version bump.

### Examples

```text
feat(lock): Add bulk lock operation for multiple worktrees
fix(status): Resolve issue with uncommitted changes detection
perf(list): Optimize worktree listing performance
docs(readme): Update installation instructions
chore(ci): Add automated release workflow
```

## Release Process

Releases are **fully automated** using GitHub Actions:

### Automated Release (Recommended)

1. Merge PR to `main` with conventional commits
2. GitHub Actions automatically:
   - Analyzes commits since last tag
   - Determines version bump (major/minor/patch)
   - Updates VERSION and CHANGELOG.md
   - Creates git tag
   - Creates GitHub release with changelog

### Manual Release (Emergency Only)

For hotfixes or manual releases:

```bash
# Bump version (auto-detects from commits)
./scripts/bump-version.sh

# Or specify bump type
./scripts/bump-version.sh major|minor|patch

# Update changelog
./scripts/update-changelog.sh $(cat VERSION)

# Commit and push
git add VERSION CHANGELOG.md
git commit -m "chore(release): bump version to $(cat VERSION) [skip ci]"
git tag -a "v$(cat VERSION)" -m "Release v$(cat VERSION)"
git push origin main --tags
```

For detailed information about versioning and releases, see [docs/VERSIONING.md](docs/VERSIONING.md).

## Questions?

- Open an issue with the `question` label
- Check existing documentation in `docs/`
- Review closed issues for similar questions

## Recognition

Contributors will be recognized in:

- GitHub contributors page
- Release notes for significant contributions
- CHANGELOG.md for feature additions

Thank you for contributing to treehouse!
