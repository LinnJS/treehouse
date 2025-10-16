# Makefile for treehouse plugin
# Run 'make help' to see all available commands
#
# Quick reload during development:
#   source reload.sh
#
# Note: 'make reload' cannot automatically source the plugin due to
# subprocess limitations. Use 'source reload.sh' directly instead.

.PHONY: all test test-core test-commands lint lint-fix install clean help quick verbose reload

# Default target - show help
all: help

# Help target
help:
	@echo "treehouse - Git Worktrees Plugin"
	@echo ""
	@echo "Available targets:"
	@echo "  make test          Run all tests (core + commands)"
	@echo "  make test-core     Run core tests only (plugin loading)"
	@echo "  make test-commands Run command tests only"
	@echo "  make lint          Run markdown linting"
	@echo "  make lint-fix      Auto-fix markdown lint issues"
	@echo "  make quick         Quick load test (silent)"
	@echo "  make verbose       Load test with output (for debugging)"
	@echo "  make reload        Show reload instructions"
	@echo "  make install       Install for current user"
	@echo "  make clean         Clean up test artifacts"
	@echo "  make help          Show this help"

# Run all tests (default test target)
test:
	@command -v bats >/dev/null 2>&1 || { \
		echo "Error: bats is not installed"; \
		echo "Install with: brew install bats-core (macOS) or see https://github.com/bats-core/bats-core"; \
		exit 1; \
	}
	@echo "Running all tests..."
	@bats tests/*.bats tests/commands/*.bats

# Core tests only
test-core:
	@command -v bats >/dev/null 2>&1 || { \
		echo "Error: bats is not installed"; \
		echo "Install with: brew install bats-core (macOS) or see https://github.com/bats-core/bats-core"; \
		exit 1; \
	}
	@echo "Running core tests..."
	@bats tests/core.bats

# Command tests only
test-commands:
	@command -v bats >/dev/null 2>&1 || { \
		echo "Error: bats is not installed"; \
		echo "Install with: brew install bats-core (macOS) or see https://github.com/bats-core/bats-core"; \
		exit 1; \
	}
	@echo "Running command tests..."
	@bats tests/commands/*.bats

# Markdown linting
lint:
	@command -v npx >/dev/null 2>&1 || { \
		echo "Error: npx is not installed (comes with Node.js)"; \
		echo "Install with: brew install node (macOS) or see https://nodejs.org"; \
		exit 1; \
	}
	@echo "Running markdown lint..."
	@npx --yes markdownlint-cli '**/*.md' --ignore node_modules --ignore .claude

# Auto-fix markdown lint issues
lint-fix:
	@command -v npx >/dev/null 2>&1 || { \
		echo "Error: npx is not installed (comes with Node.js)"; \
		echo "Install with: brew install node (macOS) or see https://nodejs.org"; \
		exit 1; \
	}
	@echo "Auto-fixing markdown lint issues..."
	@npx --yes markdownlint-cli '**/*.md' --ignore node_modules --ignore .claude --fix

# Install to user's oh-my-zsh
install:
	@if [ -d "$$HOME/.oh-my-zsh/custom/plugins" ]; then \
		echo "Installing to Oh My Zsh..."; \
		ln -sf "$$(pwd)" "$$HOME/.oh-my-zsh/custom/plugins/treehouse"; \
		echo "Add 'treehouse' to your plugins in ~/.zshrc"; \
	else \
		echo "Oh My Zsh not found. Manual installation:"; \
		echo "  source $$(pwd)/treehouse.plugin.zsh"; \
	fi

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf /tmp/treehouse-test-* 2>/dev/null || true
	@rm -rf /tmp/test-worktrees* 2>/dev/null || true

# Quick test - just load the plugin
quick:
	@echo "Quick load test..."
	@zsh -c 'autoload -U compinit && compinit -q 2>/dev/null; source treehouse.plugin.zsh && gwt help' >/dev/null 2>&1 && echo "✓ Plugin loads successfully" || echo "✗ Plugin failed to load"

# Verbose test - show any errors
verbose:
	@echo "Verbose load test..."
	@zsh -c 'autoload -U compinit && compinit -q; source treehouse.plugin.zsh && echo "✓ Plugin loaded" && gwt help | head -5'

# Reload plugin - verifies and shows reload command
reload:
	@echo "Verifying plugin..."
	@zsh -c 'autoload -U compinit && compinit -q 2>/dev/null; source treehouse.plugin.zsh && gwt help' >/dev/null 2>&1 && echo "✓ Plugin syntax OK" || (echo "✗ Plugin has errors" >&2 && exit 1)
	@echo ""
	@echo "To reload in your current shell:"
	@echo "  source reload.sh"
