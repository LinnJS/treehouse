# ============================================================================
# treehouse.plugin.zsh - Modular Autoload Loader
# ============================================================================
# Git worktrees management for Zsh
#
# This is the minimal loader that autoloads all commands on-demand for
# fast startup and clean organization.
#
# Installation:
#   1. Clone into Oh My Zsh custom plugins:
#      git clone https://github.com/linnjs/treehouse ~/.oh-my-zsh/custom/plugins/treehouse
#   2. Add 'treehouse' to plugins array in ~/.zshrc:
#      plugins=(... treehouse)
#   3. Reload shell: source ~/.zshrc
#   4. Run 'gwt help' for usage
#
# ============================================================================

# Double-load prevention
if [[ -n "$TREEHOUSE_PLUGIN_LOADED" ]]; then
  return 0
fi
readonly TREEHOUSE_PLUGIN_LOADED=1

# Get absolute path to plugin directory
# Use ${0:A:h} for compatibility with all plugin managers
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
TREEHOUSE_PLUGIN_DIR="${0:A:h}"

# Source configuration and color support
source "$TREEHOUSE_PLUGIN_DIR/lib/config.zsh"
source "$TREEHOUSE_PLUGIN_DIR/lib/colors.zsh"

# Add functions directories to fpath for autoloading
fpath=("$TREEHOUSE_PLUGIN_DIR/functions" "$TREEHOUSE_PLUGIN_DIR/functions/internal" "$TREEHOUSE_PLUGIN_DIR/completions" $fpath)

# Autoload all internal helper functions
autoload -Uz _gwt_repo _gwt_name _gwt_branch _gwt_path_for _gwt_current_path \
  _gwt_has_fzf _gwt_has_tmux _gwt_has_direnv

# Autoload all user-facing commands
autoload -Uz gwt gwt-help gwt-list gwt-add gwt-switch gwt-open gwt-rm gwt-prune \
  gwt-status gwt-main gwt-migrate gwt-clean gwt-mv gwt-pr gwt-diff gwt-stash-list \
  gwt-archive gwt-unarchive gwt-archives gwt-lock gwt-unlock gwt-locks \
  gwt-ignore gwt-unignore gwt-ignored gwt-excludes gwt-excludes-list gwt-excludes-edit

# Autoload completion functions
autoload -Uz _gwt _gwt_branches _gwt_clean_options

# Initialize completion system if not already done
if [[ -n "$ZSH_VERSION" ]]; then
  if ! command -v compdef >/dev/null 2>&1; then
    autoload -U compinit && compinit -q 2>/dev/null
  fi

  # Register completions
  compdef _gwt gwt
  compdef _gwt gwt-add
  compdef _gwt gwt-switch
  compdef _gwt gwt-rm
  compdef _gwt gwt-open
  compdef _gwt gwt-lock
  compdef _gwt gwt-unlock
  compdef _gwt gwt-archive
  compdef _gwt gwt-unarchive
  compdef _gwt gwt-mv
  compdef _gwt gwt-diff
  compdef _gwt gwt-clean
  compdef _gwt gwt-pr
fi

# Cleanup
unset TREEHOUSE_PLUGIN_DIR
