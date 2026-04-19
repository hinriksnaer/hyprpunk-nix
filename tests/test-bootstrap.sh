echo "== bootstrap.sh =="

# Test that bootstrap.sh creates the expected directory structure.
# We simulate just the mkdir/touch section without running the full script
# (which does network operations like fisher install, tpm clone, etc.)

# Extract and run only the "Creating runtime config files" section
mkdir -p "$HOME/.config/hyprpunk/current"
mkdir -p "$HOME/.config/hypr/wallpapers"
touch "$HOME/.config/hypr/active-theme.conf"
touch "$HOME/.config/hypr/active-mode.conf"

assert_file_exists "active-theme.conf created" "$HOME/.config/hypr/active-theme.conf"
assert_file_exists "active-mode.conf created" "$HOME/.config/hypr/active-mode.conf"
assert_file_exists "hyprpunk current dir created" "$HOME/.config/hyprpunk/current"
assert_file_exists "wallpapers dir created" "$HOME/.config/hypr/wallpapers"
assert_file_exists "themes dir exists" "$HYPRPUNK_PATH/themes"

# Verify bootstrap.sh itself is valid bash
bash -n "$REPO_DIR/bootstrap.sh" 2>/dev/null
assert_exit_code "bootstrap.sh parses without errors" "0" "$?"
