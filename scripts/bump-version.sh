#!/usr/bin/env bash
# Script to bump version based on conventional commits
# Usage: ./scripts/bump-version.sh [major|minor|patch]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current version from VERSION file
CURRENT_VERSION=$(cat VERSION | tr -d '[:space:]')

if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${RED}Error: Invalid version format in VERSION file: $CURRENT_VERSION${NC}"
  exit 1
fi

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Determine bump type
BUMP_TYPE="${1:-}"

if [[ -z "$BUMP_TYPE" ]]; then
  # Auto-detect from commits since last tag
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

  if [[ -z "$LAST_TAG" ]]; then
    echo -e "${YELLOW}No previous tag found, analyzing all commits...${NC}"
    COMMITS=$(git log --pretty=format:"%s")
  else
    echo -e "${BLUE}Analyzing commits since $LAST_TAG...${NC}"
    COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s")
  fi

  # Check for breaking changes or major version indicators
  if echo "$COMMITS" | grep -qE "^[a-z]+(\([a-z-]+\))?!:|BREAKING CHANGE:"; then
    BUMP_TYPE="major"
    echo -e "${YELLOW}Detected breaking changes${NC}"
  # Check for new features
  elif echo "$COMMITS" | grep -qE "^feat(\([a-z-]+\))?:"; then
    BUMP_TYPE="minor"
    echo -e "${BLUE}Detected new features${NC}"
  # Otherwise it's a patch
  elif echo "$COMMITS" | grep -qE "^fix(\([a-z-]+\))?:|^perf(\([a-z-]+\))?:|^refactor(\([a-z-]+\))?:"; then
    BUMP_TYPE="patch"
    echo -e "${GREEN}Detected fixes/patches${NC}"
  else
    echo -e "${YELLOW}No conventional commits found for versioning. Defaulting to patch.${NC}"
    BUMP_TYPE="patch"
  fi
fi

# Calculate new version
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo -e "${RED}Error: Invalid bump type '$BUMP_TYPE'. Use: major, minor, or patch${NC}"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo -e "${GREEN}Bumping version: $CURRENT_VERSION → $NEW_VERSION ($BUMP_TYPE)${NC}"

# Update VERSION file
echo "$NEW_VERSION" > VERSION

# Output for GitHub Actions
if [[ "${GITHUB_OUTPUT:-}" != "" ]]; then
  echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
  echo "old_version=$CURRENT_VERSION" >> "$GITHUB_OUTPUT"
  echo "bump_type=$BUMP_TYPE" >> "$GITHUB_OUTPUT"
fi

echo -e "${GREEN}✓ Version bumped successfully${NC}"
echo -e "${BLUE}New version: $NEW_VERSION${NC}"
