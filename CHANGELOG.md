# Changelog

All notable changes to treehouse will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Modular plugin architecture** - Complete rewrite from monolithic to modular structure
  - 26 user-facing commands in `functions/` directory
  - 8 internal helper functions in `functions/internal/`
  - 3 shell completion functions in `completions/`
  - Configuration management in `lib/config.zsh`
  - Color support system in `lib/colors.zsh`
  - Minimal 74-line autoload-based loader in `treehouse.plugin.zsh`
- **Comprehensive test suite** - 34 tests with bats-core
  - 8 core tests for plugin loading and functionality
  - 26 command tests verifying autoloadability
  - Shared test helpers in `tests/helpers/test_helper.bash`
  - Test documentation in `tests/README.md` and `tests/commands/README.md`
  - Makefile targets: `test`, `test-core`, `test-commands`
- **All 26 commands fully functional**:
  - Core: `list`, `add`, `rm`, `status`, `switch`, `open`, `main`, `prune`
  - Advanced: `migrate`, `clean`, `mv`, `lock`, `unlock`, `locks`
  - Archiving: `archive`, `unarchive`, `archives`
  - GitHub: `pr`, `diff`, `stash-list`
  - File management: `ignore`, `unignore`, `ignored`, `excludes`, `excludes-list`, `excludes-edit`
- CODE_OF_CONDUCT.md following Contributor Covenant 2.1
- SECURITY.md with vulnerability reporting guidelines
- Issue templates for bug reports and feature requests
- Pull request template with checklist
- CI workflow for automated testing on Ubuntu and macOS with Zsh 5.8/5.9
- Release workflow for automated GitHub releases from version tags
- .editorconfig for consistent code formatting across editors
- .gitattributes for consistent line endings
- CITATION.cff for academic citations
- .github/FUNDING.yml for sponsorship options
- .github/dependabot.yml for automated dependency updates
- CI badge in README.md
- .markdownlint.json with VS Code extension compatible rules
- .markdownlintignore to exclude PROMPT.md
- Markdown linting to CI workflow

### Changed

- **Complete architectural overhaul** - Migrated from monolithic 1946-line file to modular structure
- Plugin now uses Zsh autoload for lazy loading (improves startup performance)
- Functions are individually loadable and testable
- Removed duplicate `worktrees.plugin.zsh` file (renamed to `treehouse.plugin.zsh`)

### Infrastructure

- Established complete GitHub Actions CI/CD pipeline
- Added Dependabot for keeping GitHub Actions updated
- Automated release process with changelog extraction
- Test framework with bats-core integration

## [0.1.0] - 2025-10-16

### Added

- Initial project structure
- MIT License
- Basic README with project vision
- VERSION file for semantic versioning
- CHANGELOG for tracking changes
- Complete worktrees plugin functionality (monolithic prototype)

### Project

- Renamed from "worktrees" to "treehouse" for better branding
- Established foundation for open source release
- Set up for modularization in upcoming releases

[unreleased]: https://github.com/linnjs/treehouse/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/linnjs/treehouse/releases/tag/v0.1.0
