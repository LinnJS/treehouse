#!/usr/bin/env bash
# Script to update CHANGELOG.md with new version
# Usage: ./scripts/update-changelog.sh <version>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NEW_VERSION="${1:-}"
if [[ -z "$NEW_VERSION" ]]; then
  echo -e "${RED}Error: Version argument required${NC}"
  echo "Usage: $0 <version>"
  exit 1
fi

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}Updating CHANGELOG.md for version $NEW_VERSION...${NC}"

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -z "$LAST_TAG" ]]; then
  echo -e "${YELLOW}No previous tag found, generating initial changelog entry...${NC}"
  COMMITS=$(git log --pretty=format:"%s" --no-merges)
else
  echo -e "${BLUE}Generating changelog since $LAST_TAG...${NC}"
  COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s" --no-merges)
fi

# Categorize commits
BREAKING_CHANGES=""
FEATURES=""
FIXES=""
PERFORMANCE=""
REFACTOR=""
DOCS=""
TESTS=""
CHORE=""
OTHER=""

while IFS= read -r commit; do
  # Skip empty commits
  [[ -z "$commit" ]] && continue

  # Extract commit type and message
  if [[ "$commit" =~ ^([a-z]+)(\([a-z0-9_-]+\))?(!)?: ]]; then
    TYPE="${BASH_REMATCH[1]}"
    BREAKING="${BASH_REMATCH[3]}"
    MESSAGE="${commit#*: }"

    # Check for breaking change
    if [[ "$BREAKING" == "!" ]] || [[ "$commit" =~ BREAKING[[:space:]]CHANGE ]]; then
      BREAKING_CHANGES="${BREAKING_CHANGES}- ${MESSAGE}\n"
    fi

    case "$TYPE" in
      feat)
        FEATURES="${FEATURES}- ${MESSAGE}\n"
        ;;
      fix)
        FIXES="${FIXES}- ${MESSAGE}\n"
        ;;
      perf)
        PERFORMANCE="${PERFORMANCE}- ${MESSAGE}\n"
        ;;
      refactor)
        REFACTOR="${REFACTOR}- ${MESSAGE}\n"
        ;;
      docs)
        DOCS="${DOCS}- ${MESSAGE}\n"
        ;;
      test)
        TESTS="${TESTS}- ${MESSAGE}\n"
        ;;
      chore|ci|build)
        CHORE="${CHORE}- ${MESSAGE}\n"
        ;;
      *)
        OTHER="${OTHER}- ${MESSAGE}\n"
        ;;
    esac
  else
    # Non-conventional commit
    OTHER="${OTHER}- ${commit}\n"
  fi
done <<< "$COMMITS"

# Build changelog entry
CHANGELOG_ENTRY="## [$NEW_VERSION] - $DATE\n"

[[ -n "$BREAKING_CHANGES" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### ⚠️ BREAKING CHANGES\n\n${BREAKING_CHANGES}"
[[ -n "$FEATURES" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Added\n\n${FEATURES}"
[[ -n "$FIXES" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Fixed\n\n${FIXES}"
[[ -n "$PERFORMANCE" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Performance\n\n${PERFORMANCE}"
[[ -n "$REFACTOR" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Refactored\n\n${REFACTOR}"
[[ -n "$DOCS" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Documentation\n\n${DOCS}"
[[ -n "$TESTS" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Tests\n\n${TESTS}"
[[ -n "$CHORE" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Maintenance\n\n${CHORE}"
[[ -n "$OTHER" ]] && CHANGELOG_ENTRY="${CHANGELOG_ENTRY}\n### Other\n\n${OTHER}"

# Create temporary file
TEMP_FILE=$(mktemp)

# Read the changelog and insert new version
IN_UNRELEASED=0
UNRELEASED_WRITTEN=0

while IFS= read -r line; do
  # Check if we're at the [Unreleased] section
  if [[ "$line" =~ ^\[unreleased\]:|^\[Unreleased\]:|^##[[:space:]]*\[Unreleased\] ]]; then
    IN_UNRELEASED=1
  fi

  # If we hit the first version section and haven't written the entry yet
  if [[ "$line" =~ ^##[[:space:]]*\[[0-9]+\.[0-9]+\.[0-9]+\] ]] && [[ $UNRELEASED_WRITTEN -eq 0 ]]; then
    # Write the new version entry before this line
    echo -e "$CHANGELOG_ENTRY" >> "$TEMP_FILE"
    UNRELEASED_WRITTEN=1
  fi

  # Skip the Unreleased section header if we're in it
  if [[ $IN_UNRELEASED -eq 1 ]] && [[ "$line" =~ ^##[[:space:]]*\[Unreleased\] ]]; then
    # Write fresh Unreleased section
    echo "## [Unreleased]" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    IN_UNRELEASED=0
    continue
  fi

  # Skip content in unreleased section (until next ## or [unreleased] link)
  if [[ $IN_UNRELEASED -eq 1 ]]; then
    if [[ "$line" =~ ^##[[:space:]] ]] || [[ "$line" =~ ^\[unreleased\]:|^\[Unreleased\]: ]]; then
      IN_UNRELEASED=0
    else
      continue
    fi
  fi

  # Update the [unreleased] comparison link at the bottom
  if [[ "$line" =~ ^\[unreleased\]:[[:space:]]*(.*)/compare/(v[0-9]+\.[0-9]+\.[0-9]+)\.\.\.HEAD|^\[Unreleased\]:[[:space:]]*(.*)/compare/(v[0-9]+\.[0-9]+\.[0-9]+)\.\.\.HEAD ]]; then
    REPO_URL="${BASH_REMATCH[1]}"
    # Write updated unreleased link
    echo "[unreleased]: ${REPO_URL}/compare/v${NEW_VERSION}...HEAD" >> "$TEMP_FILE"
    # Write new version link
    echo "[${NEW_VERSION}]: ${REPO_URL}/compare/${BASH_REMATCH[2]}...v${NEW_VERSION}" >> "$TEMP_FILE"
    continue
  fi

  # Write the line
  echo "$line" >> "$TEMP_FILE"
done < "$CHANGELOG_FILE"

# If we never found a version section, append at the end
if [[ $UNRELEASED_WRITTEN -eq 0 ]]; then
  echo -e "\n$CHANGELOG_ENTRY" >> "$TEMP_FILE"
fi

# Replace the original file
mv "$TEMP_FILE" "$CHANGELOG_FILE"

echo -e "${GREEN}✓ CHANGELOG.md updated successfully${NC}"

# Show a preview of what was added
echo -e "\n${BLUE}Changelog entry:${NC}"
echo -e "$CHANGELOG_ENTRY" | head -20
