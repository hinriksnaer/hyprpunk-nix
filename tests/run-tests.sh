#!/usr/bin/env bash
# Hawker test runner
# Discovers and runs all test-*.sh files in the tests/ directory.
# Usage: bash tests/run-tests.sh [path-to-repo]
set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0
TOTAL=0

# ── Assertions ──

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$haystack" | grep -qF "$needle"; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    echo "    expected to contain: $needle"
    echo "    actual: $haystack"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_exists() {
  local desc="$1" path="$2"
  TOTAL=$((TOTAL + 1))
  if [[ -e "$path" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc (not found: $path)"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_contains() {
  local desc="$1" path="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  if [[ -f "$path" ]] && grep -q "$pattern" "$path"; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc (pattern '$pattern' not in $path)"
    FAIL=$((FAIL + 1))
  fi
}

assert_symlink() {
  local desc="$1" path="$2"
  TOTAL=$((TOTAL + 1))
  if [[ -L "$path" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc (not a symlink: $path)"
    FAIL=$((FAIL + 1))
  fi
}

assert_exit_code() {
  local desc="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc (expected exit $expected, got $actual)"
    FAIL=$((FAIL + 1))
  fi
}

# ── Test environment ──

setup_test_env() {
  export TEST_HOME=$(mktemp -d)
  export HOME="$TEST_HOME"
  export HYPRPUNK_PATH="$TEST_HOME/.local/share/hyprpunk"

  # Create mock themes with minimal files
  for theme in alpha beta gamma; do
    mkdir -p "$HYPRPUNK_PATH/themes/$theme/backgrounds"
    echo "# $theme hyprland" > "$HYPRPUNK_PATH/themes/$theme/hyprland.conf"
    echo "# $theme btop" > "$HYPRPUNK_PATH/themes/$theme/btop.theme"
    touch "$HYPRPUNK_PATH/themes/$theme/backgrounds/wall1.png"
  done
  echo '# alpha waybar' > "$HYPRPUNK_PATH/themes/alpha/waybar.css"
  echo '# beta waybar' > "$HYPRPUNK_PATH/themes/beta/waybar.css"

  # Create required config directories
  mkdir -p "$HOME/.config/hypr"
  mkdir -p "$HOME/.config/hyprpunk/current"
  mkdir -p "$HOME/.config/btop/themes"
  mkdir -p "$HOME/.config/waybar"
  touch "$HOME/.config/hypr/active-theme.conf"

  # Put scripts in PATH
  export PATH="$REPO_DIR/dotfiles/scripts/.local/bin:$PATH"
}

teardown_test_env() {
  rm -rf "$TEST_HOME"
}

# ── Run all test files ──

main() {
  echo ""
  echo "=== Hawker Test Suite ==="
  echo ""

  setup_test_env

  for test_file in "$TESTS_DIR"/test-*.sh; do
    [[ -f "$test_file" ]] || continue
    source "$test_file"
  done

  teardown_test_env

  echo ""
  echo "=== Results: $PASS passed, $FAIL failed, $TOTAL total ==="
  echo ""

  if [[ $FAIL -gt 0 ]]; then
    exit 1
  fi
}

main
