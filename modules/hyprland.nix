{ pkgs, ... }:

{
  # Enable Hyprland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal for screen sharing, file dialogs, etc.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    # Wayland utilities
    hyprpaper
    swaybg
    grim
    slurp
    wl-clipboard
    wlr-randr
    wlogout

    # Wayland compatibility
    xwayland
    qt5.qtwayland
    qt6.qtwayland

    # Desktop utilities
    pavucontrol
    playerctl
    networkmanagerapplet
    polkit_gnome

    # XDG utilities
    xdg-user-dirs
    xdg-utils
  ];

  # Wayland environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Polkit agent for privilege escalation dialogs
  security.polkit.enable = true;
}
