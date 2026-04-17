{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xfce.thunar
  ];

  # Enable gvfs for trash, MTP, and remote filesystem support
  services.gvfs.enable = true;
}
