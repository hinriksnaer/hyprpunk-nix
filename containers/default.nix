{ pkgs }:

let
  # Container-safe packages (no GUI, no hardware)
  containerPackages = with pkgs; [
    # Shell
    fish
    starship

    # Editor
    neovim
    tree-sitter
    ripgrep
    fzf

    # Terminal tools
    tmux
    btop
    lazygit
    yazi
    gh

    # CLI tools
    lsd
    bat
    fd

    # Dev toolchains
    rustup
    mold
    clang
    python3
    nodejs
    go
    git
    gcc
    gnumake
    cmake
    pkg-config
    openssl

    # Core tools
    opencode
    google-cloud-sdk

    # Utilities
    stow
    curl
    wget
    which
    coreutils
    findutils
    gnused
    gnugrep
    gawk
    util-linux
    procps
    file
    unzip
    gnutar
    zoxide
  ];
in
pkgs.dockerTools.buildLayeredImage {
  name = "hyprpunk-dev";
  tag = "latest";

  contents = containerPackages ++ [
    # Provide a basic environment
    pkgs.bashInteractive
    pkgs.coreutils
    pkgs.cacert
  ];

  config = {
    Env = [
      "LANG=en_US.UTF-8"
      "TERM=xterm-256color"
      "EDITOR=nvim"
      "VISUAL=nvim"
      "SHELL=${pkgs.fish}/bin/fish"
      "CLAUDE_CODE_USE_VERTEX=1"
      "CLOUD_ML_REGION=us-east5"
      "ANTHROPIC_VERTEX_PROJECT_ID=itpc-gcp-ai-eng-claude"
      "GOOGLE_CLOUD_PROJECT=itpc-gcp-ai-eng-claude"
      "VERTEX_LOCATION=global"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Cmd = [ "${pkgs.fish}/bin/fish" ];
    WorkingDir = "/root";
  };
}
