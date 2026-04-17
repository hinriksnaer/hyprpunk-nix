{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gcc
    gnumake
    cmake
    pkg-config
    openssl
    openssl.dev
    unzip
    gnutar
  ];
}
