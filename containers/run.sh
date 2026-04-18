#!/usr/bin/env bash
# Launch hyprpunk-dev container with host dotfiles and SSH agent
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="hyprpunk-dev"
CONTAINER_NAME="hyprpunk-dev"

# Build image if it doesn't exist
if ! podman image exists "$IMAGE_NAME" 2>/dev/null; then
    echo "Building container image..."
    nix build "$REPO_DIR#container" --no-link --print-out-paths | xargs -I{} podman load -i {}
fi

# Remove stale container
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Mount volumes:
#   - Dotfiles configs (read-only)
#   - SSH agent socket (for Proton Pass)
#   - SSH config + known_hosts
#   - Git config
#   - Work directory (read-write)
MOUNTS=(
    -v "$HOME/.config/fish:/home/softmax/.config/fish:ro"
    -v "$HOME/.config/nvim:/home/softmax/.config/nvim:ro"
    -v "$HOME/.config/lazygit:/home/softmax/.config/lazygit:ro"
    -v "$HOME/.config/btop:/home/softmax/.config/btop:ro"
    -v "$HOME/.config/yazi:/home/softmax/.config/yazi:ro"
    -v "$HOME/.ssh/config:/home/softmax/.ssh/config:ro"
    -v "$HOME/.ssh/known_hosts:/home/softmax/.ssh/known_hosts:rw"
    -v "$HOME/.gitconfig:/home/softmax/.gitconfig:ro"
)

# Mount tmux config if it exists
if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
    MOUNTS+=(-v "$HOME/.config/tmux:/home/softmax/.config/tmux:ro")
elif [ -f "$HOME/.tmux.conf" ]; then
    MOUNTS+=(-v "$HOME/.tmux.conf:/home/softmax/.tmux.conf:ro")
fi

# Mount SSH agent socket if running
if [ -S "$HOME/.ssh/proton-pass-agent.sock" ]; then
    MOUNTS+=(-v "$HOME/.ssh/proton-pass-agent.sock:/home/softmax/.ssh/proton-pass-agent.sock")
fi

# Mount work directory if it exists
if [ -d "$HOME/work" ]; then
    MOUNTS+=(-v "$HOME/work:/home/softmax/work")
fi

exec podman run -it \
    --name "$CONTAINER_NAME" \
    --hostname "$CONTAINER_NAME" \
    --userns=keep-id \
    "${MOUNTS[@]}" \
    -e "SSH_AUTH_SOCK=/home/softmax/.ssh/proton-pass-agent.sock" \
    -e "TERM=xterm-256color" \
    "$IMAGE_NAME" "$@"
