{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    yazi
    file
    ffmpegthumbnailer
    poppler-utils
    fd
    ripgrep
    fzf
    zoxide
    imagemagick
  ];
}
