{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yazi
    file
    ffmpegthumbnailer
    poppler_utils
    fd
    ripgrep
    fzf
    zoxide
    imagemagick
  ];
}
