{ pkgs }:

let
  # Mirror the terminal component packages -- no GUI, no hardware
  packages = with pkgs; [
    # Shell
    fish
    starship

    # Editor
    neovim
    tree-sitter

    # Terminal tools
    tmux
    btop
    lazygit
    yazi
    gh
    opencode

    # CLI tools
    ripgrep
    fd
    fzf
    zoxide
    lsd
    bat

    # Build essentials
    git
    gcc
    gnumake
    cmake
    pkg-config
    openssl
    openssl.dev
    unzip
    gnutar

    # SSH
    openssh

    # Core
    bashInteractive
    coreutils
    findutils
    gnused
    gnugrep
    gawk
    util-linux
    procps
    curl
    wget
    which
    file
    stow
    cacert
  ];
in
pkgs.dockerTools.buildLayeredImage {
  name = "hyprpunk-dev";
  tag = "latest";

  contents = packages;

  config = {
    Env = [
      "LANG=en_US.UTF-8"
      "TERM=xterm-256color"
      "EDITOR=nvim"
      "VISUAL=nvim"
      "SHELL=${pkgs.fish}/bin/fish"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [ "${pkgs.fish}/bin/fish" ];
    WorkingDir = "/home/softmax";
  };
}
