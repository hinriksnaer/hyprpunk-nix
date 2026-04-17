{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lsd
    ripgrep
    bat
    fd
  ];
}
