{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Base system
    ../../modules/base.nix

    # Desktop profile (tooling + GUI + opencode)
    ../../profiles/desktop.nix

    # Hardware (opt-in per machine)
    ../../modules/nvidia.nix
    ../../modules/bluetooth.nix
    ../../modules/networking.nix
    ../../modules/fancontrol.nix
  ];

  networking.hostName = "hyprpunk";
}
