#!/usr/bin/env bash
# Load and enter the hyprpunk-dev container
# Run this on the remote host after push.sh has delivered the image
#
# Usage:
#   ./deploy.sh                     # load ~/hyprpunk-dev.tar.gz and enter
#   ./deploy.sh /path/to/image.tar.gz  # load specific image and enter
#   ./deploy.sh --enter             # enter already-loaded image

set -euo pipefail

IMAGE_NAME="hyprpunk-dev"

# Detect container runtime
if command -v podman &>/dev/null; then
    RUNTIME=podman
elif command -v docker &>/dev/null; then
    RUNTIME=docker
else
    echo "Error: podman or docker required"
    exit 1
fi

# Load image if not --enter
if [ "${1:-}" != "--enter" ]; then
    IMAGE_FILE="${1:-$HOME/hyprpunk-dev.tar.gz}"
    if [ -f "$IMAGE_FILE" ]; then
        echo "Loading image from $IMAGE_FILE..."
        $RUNTIME load -i "$IMAGE_FILE"
    else
        echo "Error: $IMAGE_FILE not found"
        echo "Usage: $0 [image.tar.gz | --enter]"
        exit 1
    fi
fi

# Enter container
echo "Starting $IMAGE_NAME..."
exec $RUNTIME run -it --rm \
    --name "$IMAGE_NAME" \
    --hostname "$IMAGE_NAME" \
    -v "$HOME/.ssh:/root/.ssh:ro" \
    -e "TERM=xterm-256color" \
    -e "SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-}" \
    "$IMAGE_NAME"
