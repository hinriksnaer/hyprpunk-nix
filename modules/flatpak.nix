{ pkgs, ... }:

{
  services.flatpak.enable = true;

  # Flatpak needs xdg-portal to function
  xdg.portal.enable = true;
}
