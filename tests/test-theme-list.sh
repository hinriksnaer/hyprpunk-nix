echo "== hyprpunk-theme-list =="

output=$(fish "$REPO_DIR/dotfiles/scripts/.local/bin/hyprpunk-theme-list" 2>/dev/null)

assert_contains "lists alpha" "alpha" "$output"
assert_contains "lists beta" "beta" "$output"
assert_contains "lists gamma" "gamma" "$output"

count=$(echo "$output" | wc -l)
assert_eq "exactly 3 themes" "3" "$count"
