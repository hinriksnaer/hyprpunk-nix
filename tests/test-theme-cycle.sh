echo "== hyprpunk-theme-next/prev =="

# Helper: get current theme from symlink or marker
get_theme() {
  if [[ -L "$HOME/.config/hyprpunk/current/theme" ]]; then
    basename "$(readlink "$HOME/.config/hyprpunk/current/theme")"
  else
    grep '^# theme:' "$HOME/.config/hypr/active-theme.conf" 2>/dev/null | sed 's/^# theme: *//'
  fi
}

# ── Next: alpha -> beta ──
echo "# theme: alpha" > "$HOME/.config/hypr/active-theme.conf"
rm -f "$HOME/.config/hyprpunk/current/theme"
fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-next" 2>/dev/null || true
assert_eq "next after alpha is beta" "beta" "$(get_theme)"

# ── Next wraparound: gamma -> alpha ──
echo "# theme: gamma" > "$HOME/.config/hypr/active-theme.conf"
rm -f "$HOME/.config/hyprpunk/current/theme"
fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-next" 2>/dev/null || true
assert_eq "next after gamma wraps to alpha" "alpha" "$(get_theme)"

# ── Prev: beta -> alpha ──
echo "# theme: beta" > "$HOME/.config/hypr/active-theme.conf"
rm -f "$HOME/.config/hyprpunk/current/theme"
fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-prev" 2>/dev/null || true
assert_eq "prev before beta is alpha" "alpha" "$(get_theme)"

# ── Refresh detection ──
cat > "$HOME/.config/hypr/active-theme.conf" <<'EOF'
# Active Hyprland Theme (runtime-generated)
# Managed by hyprpunk-theme-set-desktop
# theme: alpha
EOF

output=$(fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-refresh" 2>&1 || true)
assert_contains "refresh detects alpha" "alpha" "$output"
