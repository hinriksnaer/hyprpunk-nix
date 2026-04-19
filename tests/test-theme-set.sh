#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/setup.sh"

echo "== hyprpunk-theme-set-terminal =="

setup_test_env

fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-set-terminal" beta 2>/dev/null || true

assert_symlink "creates current theme symlink" "$HOME/.config/hyprpunk/current/theme"

target=$(readlink "$HOME/.config/hyprpunk/current/theme")
assert_contains "symlink points to beta" "beta" "$target"

assert_file_exists "btop theme symlinked" "$HOME/.config/btop/themes/active.theme"

teardown_test_env
test_report
