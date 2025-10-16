#!/usr/bin/env bash
# Script to sync GitHub labels from .github/labels.yml
# Usage: ./scripts/sync-labels.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LABELS_FILE=".github/labels.yml"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install with: brew install gh (macOS) or see https://cli.github.com"
    exit 1
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not logged in to GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Check if labels file exists
if [[ ! -f "$LABELS_FILE" ]]; then
    echo -e "${RED}Error: $LABELS_FILE not found${NC}"
    exit 1
fi

echo -e "${BLUE}🏷️  Syncing GitHub labels from $LABELS_FILE${NC}"
echo ""

# Parse YAML and create/update labels
# This uses a simple approach - you could also use yq for more robust parsing
LABEL_NAME=""
LABEL_COLOR=""
LABEL_DESC=""

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Parse name
    if [[ "$line" =~ ^-[[:space:]]*name:[[:space:]]*(.+)$ ]]; then
        # If we have a complete label, process it
        if [[ -n "$LABEL_NAME" ]]; then
            echo -e "${YELLOW}Processing: $LABEL_NAME${NC}"

            # Check if label exists
            if gh api "repos/:owner/:repo/labels/$LABEL_NAME" &> /dev/null; then
                # Update existing label
                gh api --method PATCH "repos/:owner/:repo/labels/$LABEL_NAME" \
                    -f color="$LABEL_COLOR" \
                    -f description="$LABEL_DESC" \
                    > /dev/null && \
                echo -e "${GREEN}  ✓ Updated${NC}" || \
                echo -e "${RED}  ✗ Failed to update${NC}"
            else
                # Create new label
                gh api --method POST "repos/:owner/:repo/labels" \
                    -f name="$LABEL_NAME" \
                    -f color="$LABEL_COLOR" \
                    -f description="$LABEL_DESC" \
                    > /dev/null && \
                echo -e "${GREEN}  ✓ Created${NC}" || \
                echo -e "${RED}  ✗ Failed to create${NC}"
            fi
        fi

        # Extract new label name
        LABEL_NAME="${BASH_REMATCH[1]}"
        LABEL_NAME="${LABEL_NAME#"${LABEL_NAME%%[![:space:]]*}"}"  # Trim leading
        LABEL_NAME="${LABEL_NAME%"${LABEL_NAME##*[![:space:]]}"}"  # Trim trailing
        LABEL_COLOR=""
        LABEL_DESC=""
    fi

    # Parse color
    if [[ "$line" =~ ^[[:space:]]+color:[[:space:]]*[\'\"]*([A-Fa-f0-9]+)[\'\"]*$ ]]; then
        LABEL_COLOR="${BASH_REMATCH[1]}"
    fi

    # Parse description
    if [[ "$line" =~ ^[[:space:]]+description:[[:space:]]*[\'\"]*(.+)[\'\"]*$ ]]; then
        LABEL_DESC="${BASH_REMATCH[1]}"
        # Remove leading/trailing quotes
        LABEL_DESC="${LABEL_DESC#[\'\"]}"
        LABEL_DESC="${LABEL_DESC%[\'\"]}"
    fi
done < "$LABELS_FILE"

# Process the last label
if [[ -n "$LABEL_NAME" ]]; then
    echo -e "${YELLOW}Processing: $LABEL_NAME${NC}"

    if gh api "repos/:owner/:repo/labels/$LABEL_NAME" &> /dev/null; then
        gh api --method PATCH "repos/:owner/:repo/labels/$LABEL_NAME" \
            -f color="$LABEL_COLOR" \
            -f description="$LABEL_DESC" \
            > /dev/null && \
        echo -e "${GREEN}  ✓ Updated${NC}" || \
        echo -e "${RED}  ✗ Failed to update${NC}"
    else
        gh api --method POST "repos/:owner/:repo/labels" \
            -f name="$LABEL_NAME" \
            -f color="$LABEL_COLOR" \
            -f description="$LABEL_DESC" \
            > /dev/null && \
        echo -e "${GREEN}  ✓ Created${NC}" || \
        echo -e "${RED}  ✗ Failed to create${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✓ Label sync complete!${NC}"
echo -e "${BLUE}View labels at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/labels${NC}"
