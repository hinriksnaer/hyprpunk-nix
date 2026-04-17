# Hyprpunk environment setup
# Sets HYPRPUNK_PATH for theme-manager and scripts to find themes and resources

if test -z "$HYPRPUNK_PATH"
    set -gx HYPRPUNK_PATH "$HOME/.local/share/hyprpunk"
end
