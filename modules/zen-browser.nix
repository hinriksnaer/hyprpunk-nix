{ pkgs, ... }:

{
  # Zen Browser is not in nixpkgs yet.
  # Options:
  # 1. Add zen-browser flake input when available:
  #    inputs.zen-browser.url = "github:zen-browser/desktop";
  # 2. Use Firefox as fallback:
  environment.systemPackages = with pkgs; [
    firefox
  ];
}
