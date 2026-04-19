# Headless terminal tools -- safe for containers and remote hosts.
# Does not include display-dependent packages (kitty, wl-clipboard).
{ ... }:

{
  imports = [
    ../modules/fish.nix
    ../modules/tmux.nix
    ../modules/btop.nix
    ../modules/lazygit.nix
    ../modules/yazi.nix
    ../modules/cli-tools.nix
    ../modules/neovim.nix
    ../modules/gh.nix
    ../modules/opencode.nix
  ];
}
