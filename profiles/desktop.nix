{ ... }:

{
  imports = [
    # All terminal/dev tooling
    ./tooling.nix

    # Core tools
    ../modules/opencode.nix

    # Desktop environment
    ../modules/hyprland.nix
    ../modules/kitty.nix
    ../modules/rofi.nix
    ../modules/hyprlock.nix
    ../modules/waybar.nix
    ../modules/mako.nix
    ../modules/thunar.nix

    # Fonts
    ../modules/fonts.nix

    # Audio & multimedia
    ../modules/audio.nix
    ../modules/multimedia.nix

    # Applications
    ../modules/flatpak.nix
    ../modules/zen-browser.nix
    ../modules/discord.nix
    ../modules/obsidian.nix
  ];
}
