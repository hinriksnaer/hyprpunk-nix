#!/usr/bin/env bash
# Test environment setup.
# Creates an isolated $HOME with mock themes and config directories.
# Source this file after lib.sh.

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

setup_test_env() {
  export TEST_HOME=$(mktemp -d)
  export HOME="$TEST_HOME"
  export HYPRPUNK_PATH="$TEST_HOME/.local/share/hyprpunk"

  # Mock themes
  for theme in alpha beta gamma; do
    mkdir -p "$HYPRPUNK_PATH/themes/$theme/backgrounds"
    echo "# $theme hyprland" > "$HYPRPUNK_PATH/themes/$theme/hyprland.conf"
    echo "# $theme btop" > "$HYPRPUNK_PATH/themes/$theme/btop.theme"
    touch "$HYPRPUNK_PATH/themes/$theme/backgrounds/wall1.png"
  done
  echo '# alpha waybar' > "$HYPRPUNK_PATH/themes/alpha/waybar.css"
  echo '# beta waybar' > "$HYPRPUNK_PATH/themes/beta/waybar.css"

  # Config directories
  mkdir -p "$HOME/.config/hypr"
  mkdir -p "$HOME/.config/hyprpunk/current"
  mkdir -p "$HOME/.config/btop/themes"
  mkdir -p "$HOME/.config/waybar"
  touch "$HOME/.config/hypr/active-theme.conf"

  # Scripts in PATH
  export PATH="$REPO_DIR/dotfiles/scripts/.local/bin:$PATH"
}

teardown_test_env() {
  rm -rf "$TEST_HOME"
}
