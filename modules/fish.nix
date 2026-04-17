{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
    starship
  ];

  programs.fish.enable = true;
}
