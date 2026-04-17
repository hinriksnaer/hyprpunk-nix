{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Base system
    ../../modules/base.nix

    # Desktop profile (tooling + GUI + opencode)
    ../../profiles/desktop.nix

    # Hardware (opt-in per machine)
    # TODO: uncomment these one at a time after verifying base system works
    ../../modules/nvidia.nix
    ../../modules/steam.nix
    # ../../modules/bluetooth.nix
    ../../modules/networking.nix
    #../../modules/fancontrol.nix
  ];

  networking.hostName = "hyprpunk";
}
