# ============================================================================
# Color Support
# ============================================================================
# ANSI color codes for terminal output

# Check if colors are supported
_gwt_has_colors() {
  if [[ -t 1 ]] && [[ -n "${TERM}" ]] && [[ "${TERM}" != "dumb" ]]; then
    return 0
  else
    return 1
  fi
}

# Set up color variables (only if not already set)
if [[ -z "${GWT_COLOR_RESET+x}" ]]; then
  if _gwt_has_colors; then
    # Regular colors
    readonly GWT_COLOR_RESET=$'\033[0m'
    readonly GWT_COLOR_BOLD=$'\033[1m'
    readonly GWT_COLOR_DIM=$'\033[2m'

    # Foreground colors
    readonly GWT_COLOR_BLACK=$'\033[0;30m'
    readonly GWT_COLOR_RED=$'\033[0;31m'
    readonly GWT_COLOR_GREEN=$'\033[0;32m'
    readonly GWT_COLOR_YELLOW=$'\033[0;33m'
    readonly GWT_COLOR_BLUE=$'\033[0;34m'
    readonly GWT_COLOR_MAGENTA=$'\033[0;35m'
    readonly GWT_COLOR_CYAN=$'\033[0;36m'
    readonly GWT_COLOR_WHITE=$'\033[0;37m'

    # Bold colors
    readonly GWT_COLOR_BOLD_RED=$'\033[1;31m'
    readonly GWT_COLOR_BOLD_GREEN=$'\033[1;32m'
    readonly GWT_COLOR_BOLD_YELLOW=$'\033[1;33m'
    readonly GWT_COLOR_BOLD_BLUE=$'\033[1;34m'
    readonly GWT_COLOR_BOLD_CYAN=$'\033[1;36m'
    readonly GWT_COLOR_BOLD_WHITE=$'\033[1;37m'
  else
    # No colors
    readonly GWT_COLOR_RESET=""
    readonly GWT_COLOR_BOLD=""
    readonly GWT_COLOR_DIM=""
    readonly GWT_COLOR_BLACK=""
    readonly GWT_COLOR_RED=""
    readonly GWT_COLOR_GREEN=""
    readonly GWT_COLOR_YELLOW=""
    readonly GWT_COLOR_BLUE=""
    readonly GWT_COLOR_MAGENTA=""
    readonly GWT_COLOR_CYAN=""
    readonly GWT_COLOR_WHITE=""
    readonly GWT_COLOR_BOLD_RED=""
    readonly GWT_COLOR_BOLD_GREEN=""
    readonly GWT_COLOR_BOLD_YELLOW=""
    readonly GWT_COLOR_BOLD_BLUE=""
    readonly GWT_COLOR_BOLD_CYAN=""
    readonly GWT_COLOR_BOLD_WHITE=""
  fi
fi
