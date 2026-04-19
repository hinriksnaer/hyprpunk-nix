echo "== settings.nix =="

assert_file_exists "settings.nix exists" "$REPO_DIR/settings.nix"
assert_file_contains "has username field" "$REPO_DIR/settings.nix" "username"
