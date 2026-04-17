#!/usr/bin/env fish
# Wrapper for hyprpunk-theme-refresh that preserves layout preference

# Update general.conf to match current layout BEFORE theme reload
fish $HOME/.config/hypr/scripts/restore-layout.fish

# Refresh current theme (will reload with correct layout)
hyprpunk-theme-refresh
