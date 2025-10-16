# Semantic Versioning & Release Process

This document describes how treehouse uses semantic versioning and automated releases.

## Overview

Treehouse follows [Semantic Versioning 2.0.0](https://semver.org/) and uses
[Conventional Commits](https://www.conventionalcommits.org/) to automate version bumping and changelog generation.

## Semantic Versioning

Given a version number `MAJOR.MINOR.PATCH`:

- **MAJOR** - Incremented for incompatible API changes or breaking changes
- **MINOR** - Incremented for new features in a backwards-compatible manner
- **PATCH** - Incremented for backwards-compatible bug fixes

## Conventional Commits

All commits must follow the Conventional Commits specification:

```text
type(dir): Description

[optional body]

[optional footer]
```

Where `type` is the commit type, `dir` is the component/directory/command name, and `Description` is a brief summary.

### Commit Types

- **feat** - New feature (triggers MINOR version bump)
- **fix** - Bug fix (triggers PATCH version bump)
- **perf** - Performance improvement (triggers PATCH version bump)
- **refactor** - Code refactoring (triggers PATCH version bump)
- **docs** - Documentation changes (no version bump)
- **style** - Code style changes (no version bump)
- **test** - Test changes (no version bump)
- **chore** - Maintenance tasks (no version bump)
- **ci** - CI configuration changes (no version bump)
- **build** - Build system changes (no version bump)
- **revert** - Revert a previous commit (no version bump)

### Breaking Changes

To indicate a breaking change, add `!` after the type/scope or include `BREAKING CHANGE:` in the footer:

```text
feat(api)!: Remove deprecated authentication method

BREAKING CHANGE: The old authentication method has been removed.
Use the new OAuth2 flow instead.
```

Breaking changes trigger a **MAJOR** version bump.

### Examples

```text
feat(lock): Add bulk lock operation for multiple worktrees
fix(status): Resolve issue with uncommitted changes detection
perf(list): Optimize worktree listing performance
docs(readme): Update installation instructions
refactor(clean): Simplify cleanup logic
chore(ci): Add automated release workflow
```

## Automated Release Process

### How It Works

1. **Developer Workflow**
   - Create feature branch
   - Make changes with conventional commits
   - Create pull request to `main`
   - CI validates commit messages

2. **On Merge to Main**
   - Release workflow analyzes commits since last tag
   - Determines version bump type (major/minor/patch)
   - Updates `VERSION` file
   - Updates `CHANGELOG.md` with categorized changes
   - Updates `README.md` version badge automatically
   - Creates commit: `chore(release): bump version to X.Y.Z [skip ci]`
   - Creates git tag: `vX.Y.Z`
   - Creates GitHub release with changelog excerpt

3. **Release Triggers**
   - Automatic: On push to `main` with conventional commits
   - Manual: Via GitHub Actions workflow dispatch

### What Gets Released

A release is created when commits include:

- `feat:` - New features
- `fix:` - Bug fixes
- `perf:` - Performance improvements
- `refactor:` - Code refactoring

Commits like `docs:`, `chore:`, `ci:` do NOT trigger releases by themselves.

## Manual Versioning

For local testing or manual releases, use the provided scripts:

### Bump Version

```bash
# Auto-detect version bump from commits
./scripts/bump-version.sh

# Specify bump type manually
./scripts/bump-version.sh major
./scripts/bump-version.sh minor
./scripts/bump-version.sh patch
```

### Update Changelog

```bash
# Update changelog for specific version
./scripts/update-changelog.sh 0.2.0
```

## Version Files

### VERSION

Contains the current version number:

```text
0.1.0
```

### CHANGELOG.md

Follows [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [Unreleased]

## [0.2.0] - 2025-10-16

### Added

- New feature descriptions

### Fixed

- Bug fix descriptions
```

## CI Workflows

### Release Workflow (`.github/workflows/release.yml`)

- **Triggers**: Push to `main`, manual dispatch
- **Purpose**: Create automated releases
- **Actions**:
  - Analyzes commits
  - Bumps version
  - Updates changelog
  - Updates README version badge
  - Creates tag and GitHub release

### Commit Lint Workflow (`.github/workflows/commit-lint.yml`)

- **Triggers**: Pull requests to `main`/`develop`
- **Purpose**: Validate commit messages
- **Actions**:
  - Checks all PR commits
  - Validates against conventional commits spec
  - Fails if invalid commits found

### PR Auto-Labeler Workflow (`.github/workflows/pr-labeler.yml`)

- **Triggers**: Pull requests opened, synchronized, or reopened
- **Purpose**: Automatically label PRs based on content
- **Actions**:
  - Analyzes commit types in PR
  - Adds type labels (enhancement, bug, documentation, etc.)
  - Adds size label based on lines changed (XS/S/M/L/XL)
  - Adds breaking change label if detected
  - Posts summary comment on PR

#### Labels Added

**Type Labels** (based on conventional commits):

- `enhancement` - New features (feat)
- `bug` - Bug fixes (fix)
- `documentation` - Documentation updates (docs)
- `style` - Code style changes
- `refactor` - Code refactoring
- `performance` - Performance improvements (perf)
- `testing` - Test updates (test)
- `maintenance` - Maintenance tasks (chore)
- `ci/cd` - CI/CD changes
- `breaking change` - Breaking changes (major version)

**Size Labels** (based on lines changed):

- `size/XS` - < 10 lines
- `size/S` - < 50 lines
- `size/M` - < 200 lines
- `size/L` - < 500 lines
- `size/XL` - >= 500 lines

## Best Practices

### For Contributors

1. **Write Clear Commits**
   - Use descriptive commit messages
   - Follow `type(dir): Description` format
   - Use component/directory/command as the scope
   - Capitalize the description
   - Reference issues when applicable

2. **One Feature Per PR**
   - Keep pull requests focused
   - Makes release notes clearer
   - Easier to review and revert if needed

3. **Test Before Committing**
   - Run `make test` locally
   - Ensure all tests pass
   - Validate syntax with `make quick`

### For Maintainers

1. **Review Commit Messages**
   - Ensure PR commits follow conventions
   - Request changes if needed
   - Use "Squash and merge" with proper commit message

2. **Manual Releases**
   - Use workflow dispatch for hotfixes
   - Specify bump type when needed
   - Review changelog before releasing

3. **Version Branches**
   - `main` - Latest stable release
   - `develop` - Development branch (if using git-flow)
   - Feature branches - Individual features

## Troubleshooting

### Release Not Created

If a release wasn't created after merging:

1. Check if commits follow conventional format
2. Verify commits include `feat:`, `fix:`, `perf:`, or `refactor:`
3. Check GitHub Actions logs
4. Manually trigger release via workflow dispatch

### Invalid Commit Messages

If commit lint fails on PR:

1. Review the failing commits
2. Amend or rebase to fix commit messages
3. Force push to update PR
4. Or use "Squash and merge" with proper message

### Manual Release

To create a release manually:

```bash
# Bump version
./scripts/bump-version.sh minor

# Update changelog
./scripts/update-changelog.sh $(cat VERSION)

# Commit and tag
git add VERSION CHANGELOG.md
git commit -m "chore(release): bump version to $(cat VERSION)"
git tag -a "v$(cat VERSION)" -m "Release v$(cat VERSION)"

# Push
git push origin main
git push origin "v$(cat VERSION)"
```

## References

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Questions?

If you have questions about versioning or releases:

1. Check existing [GitHub Discussions](https://github.com/linnjs/treehouse/discussions)
2. Review closed issues with `release` label
3. Open a new discussion for guidance
