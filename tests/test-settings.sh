#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$(dirname "$0")/lib.sh"

echo "== settings.nix =="

assert_file_exists "settings.nix exists" "$REPO_DIR/settings.nix"
assert_file_contains "has username field" "$REPO_DIR/settings.nix" "username"

test_report
