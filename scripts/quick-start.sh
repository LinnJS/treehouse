#!/usr/bin/env bash
# Quick start script for treehouse plugin
# This helps new users get started quickly

set -e

echo "🏡 Treehouse Quick Start"
echo "========================"
echo ""

# Check Zsh version
if command -v zsh >/dev/null 2>&1; then
  ZSH_VERSION=$(zsh -c 'echo $ZSH_VERSION')
  echo "✓ Zsh found: version $ZSH_VERSION"
else
  echo "✗ Zsh not found. Please install Zsh first."
  exit 1
fi

# Check Git version
if command -v git >/dev/null 2>&1; then
  GIT_VERSION=$(git --version | cut -d' ' -f3)
  echo "✓ Git found: version $GIT_VERSION"
else
  echo "✗ Git not found. Please install Git first."
  exit 1
fi

echo ""
echo "Testing plugin load..."
echo "----------------------"

# Test plugin loads
if zsh -c "source $(pwd)/treehouse.plugin.zsh && gwt help" >/dev/null 2>&1; then
  echo "✓ Plugin loads successfully!"
else
  echo "✗ Plugin failed to load"
  exit 1
fi

echo ""
echo "Installation Options"
echo "-------------------"
echo ""
echo "1. Oh My Zsh (Recommended):"
echo "   ln -sf $(pwd) ~/.oh-my-zsh/custom/plugins/treehouse"
echo "   Then add 'treehouse' to plugins in ~/.zshrc"
echo ""
echo "2. Manual:"
echo "   Add this to ~/.zshrc:"
echo "   source $(pwd)/treehouse.plugin.zsh"
echo ""
echo "3. Test now without installing:"
echo "   zsh -c 'source $(pwd)/treehouse.plugin.zsh && exec zsh'"
echo ""
echo "What would you like to do?"
echo "1) Install for Oh My Zsh"
echo "2) Show manual install instructions"
echo "3) Test in new shell"
echo "4) Exit"
echo ""
read -p "Choose [1-4]: " choice

case $choice in
  1)
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
      ln -sf "$(pwd)" "$HOME/.oh-my-zsh/custom/plugins/treehouse"
      echo ""
      echo "✓ Linked to Oh My Zsh custom plugins"
      echo ""
      echo "Now add 'treehouse' to your plugins in ~/.zshrc:"
      echo "  plugins=(git ... treehouse)"
      echo ""
      echo "Then reload with: source ~/.zshrc"
    else
      echo "Oh My Zsh not found. Please install Oh My Zsh first."
    fi
    ;;
  2)
    echo ""
    echo "Add this line to your ~/.zshrc file:"
    echo ""
    echo "  source $(pwd)/treehouse.plugin.zsh"
    echo ""
    echo "Then reload with: source ~/.zshrc"
    ;;
  3)
    echo ""
    echo "Starting test shell with treehouse loaded..."
    echo "Type 'exit' to return to this script"
    echo ""
    zsh -c "source $(pwd)/treehouse.plugin.zsh && echo '✓ Treehouse loaded! Try: gwt help' && exec zsh"
    ;;
  4)
    echo "Goodbye!"
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "For more information:"
echo "  - Run 'make help' to see development commands"
echo "  - Read docs/DEVELOPMENT.md for development guide"
echo "  - See README.md for full documentation"
