{ pkgs, settings, ... }:

{
  networking.networkmanager.enable = true;
  users.users.${settings.username}.extraGroups = [ "networkmanager" ];
}
