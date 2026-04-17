#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
HYPRPUNK_DATA="$HOME/.local/share/hyprpunk"

echo "==> Deploying dotfiles via stow..."

# Stow each module's dotfiles into $HOME
for dir in "$DOTFILES_DIR"/*/; do
    module=$(basename "$dir")

    # themes are not stowed into $HOME -- they go to ~/.local/share/hyprpunk/themes/
    if [ "$module" = "themes" ]; then
        continue
    fi

    echo "  stow: $module"
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$module" 2>&1 | grep -v "BUG" || true
done

# Deploy themes to ~/.local/share/hyprpunk/themes/
echo "==> Deploying themes to $HYPRPUNK_DATA/themes/..."
mkdir -p "$HYPRPUNK_DATA"
if [ -L "$HYPRPUNK_DATA/themes" ]; then
    rm "$HYPRPUNK_DATA/themes"
fi
ln -snf "$DOTFILES_DIR/themes" "$HYPRPUNK_DATA/themes"

# Create current-theme tracking dir
mkdir -p "$HOME/.config/hyprpunk/current"

# ── One-time plugin installs ──

# Fisher (fish plugin manager)
if command -v fish &>/dev/null; then
    echo "==> Installing Fisher and fish plugins..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true
    if [ -f "$DOTFILES_DIR/fish/.config/fish/fish_plugins" ]; then
        fish -c "fisher update" 2>/dev/null || true
    fi
fi

# TPM (tmux plugin manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "==> Installing TPM (tmux plugin manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" 2>/dev/null || true
fi
if [ -d "$TPM_DIR" ]; then
    "$TPM_DIR/bin/install_plugins" 2>/dev/null || true
fi

# Yazi plugins
if command -v yazi &>/dev/null; then
    echo "==> Installing yazi plugins..."
    # yazi plugin manager installs from yazi.toml [plugin] section
    ya pack -i 2>/dev/null || true
fi

# Set default theme
if [ -f "$HOME/.local/bin/hyprpunk-theme-set" ] && [ ! -L "$HOME/.config/hyprpunk/current/theme" ]; then
    echo "==> Setting default theme (ayu-mirage)..."
    fish -c "hyprpunk-theme-set ayu-mirage" 2>/dev/null || true
fi

echo "==> Bootstrap complete!"
echo ""
echo "Post-install steps:"
echo "  1. Run 'gcloud auth login' for GCP authentication"
echo "  2. Run 'gcloud auth application-default login' for ADC"
echo "  3. Log out and back in for environment variables to take effect"
