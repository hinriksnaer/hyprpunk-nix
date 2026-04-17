{ ... }:

{
  imports = [
    # Shell
    ../modules/fish.nix
    ../modules/cli-tools.nix

    # Editor
    ../modules/neovim.nix

    # Terminal tools
    ../modules/tmux.nix
    ../modules/btop.nix
    ../modules/lazygit.nix
    ../modules/yazi.nix
    ../modules/gh.nix

    # Dev toolchains
    ../modules/rust.nix
    ../modules/python.nix
    ../modules/nodejs.nix
    ../modules/golang.nix
    ../modules/dev-tools.nix
  ];
}
