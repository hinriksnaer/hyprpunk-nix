#!/usr/bin/env bash
# Build the container image and push it to a remote host
#
# Usage: ./push.sh <host>
#   e.g.: ./push.sh ibm-kaiba
#         ./push.sh hgudmund@163.75.92.3

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <ssh-host>"
    echo "  e.g.: $0 ibm-kaiba"
    exit 1
fi

HOST="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Building container image..."
IMAGE_PATH=$(nix build "$REPO_DIR#container" --no-link --print-out-paths)
echo "    Built: $IMAGE_PATH"

echo "==> Pushing to $HOST..."
scp "$IMAGE_PATH" "$HOST:~/hyprpunk-dev.tar.gz"

echo "==> Loading image on $HOST..."
ssh "$HOST" 'podman load -i ~/hyprpunk-dev.tar.gz 2>/dev/null || docker load -i ~/hyprpunk-dev.tar.gz'

echo ""
echo "Done. To enter the container on $HOST:"
echo "  ssh $HOST"
echo "  podman run -it --rm -v \$HOME/.ssh:/root/.ssh:ro hyprpunk-dev"
