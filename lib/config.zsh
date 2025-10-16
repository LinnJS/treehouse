# ============================================================================
# Configuration Variables
# ============================================================================
# Override these in your ~/.zshrc before loading the plugin to customize behavior.
#
# Example:
#   export GWT_ROOT="$HOME/projects/worktrees"
#   export GWT_OPEN_CMD="nvim"
#   export GWT_USE_TMUX="0"
#   export GWT_AUTO_TRACK="1"
#   export GWT_ON_SWITCH_CMD="echo 'Switched to:'"
#   export GWT_TEMPLATE_DIR="$HOME/.config/worktree-templates"

# GWT_ROOT: Base directory where all worktrees will be organized.
# Structure: $GWT_ROOT/<repo-name>/<branch-name>
: ${GWT_ROOT:="$HOME/.worktrees"}

# GWT_OPEN_CMD: Command used to open worktrees in your editor/IDE.
# Common values: "code", "nvim", "idea", "subl", "emacs"
: ${GWT_OPEN_CMD:="code"}

# GWT_USE_TMUX: Enable automatic tmux session creation/attachment.
# Set to "1" to enable, "0" to disable.
: ${GWT_USE_TMUX:="0"}

# GWT_DIR_ENVRC: Automatically create a template .envrc file in new worktrees.
# Set to "1" to enable, "0" to disable. Requires direnv to be installed.
: ${GWT_DIR_ENVRC:="0"}

# GWT_PRUNE_ON_RM: Automatically prune worktree references after removal.
# Set to "1" to enable, "0" to disable.
: ${GWT_PRUNE_ON_RM:="1"}

# GWT_AUTO_TRACK: Automatically set up branch tracking to origin when creating worktrees.
# Set to "1" to enable, "0" to disable.
: ${GWT_AUTO_TRACK:="1"}

# GWT_ON_SWITCH_CMD: Command to run after switching worktrees.
# Useful for running setup scripts, installing dependencies, etc.
# The command receives the worktree path as the first argument.
: ${GWT_ON_SWITCH_CMD:=""}

# GWT_TEMPLATE_DIR: Directory containing template files to copy to new worktrees.
# Files from this directory will be copied to each new worktree.
: ${GWT_TEMPLATE_DIR:=""}
