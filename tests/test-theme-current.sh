echo "== hyprpunk-theme-current =="

# ── Marker detection ──
cat > "$HOME/.config/hypr/active-theme.conf" <<'EOF'
# Active Hyprland Theme (runtime-generated)
# Managed by hyprpunk-theme-set-desktop
# theme: beta

general {
    col.active_border = rgba(ff0000ee)
}
EOF

output=$(fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-current" 2>/dev/null)
assert_eq "detects beta from marker" "Beta" "$output"

# ── Symlink fallback ──
echo "" > "$HOME/.config/hypr/active-theme.conf"
ln -sf "$HYPRPUNK_PATH/themes/gamma" "$HOME/.config/hyprpunk/current/theme"

output=$(fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-current" 2>/dev/null)
assert_eq "detects gamma from symlink" "Gamma" "$output"

# ── No theme set ──
echo "" > "$HOME/.config/hypr/active-theme.conf"
rm -f "$HOME/.config/hyprpunk/current/theme"

rc=0
fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-current" 2>/dev/null || rc=$?
assert_exit_code "exits non-zero when no theme" "1" "$rc"
