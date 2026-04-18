{ pkgs }:

let
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

  repoSrc = builtins.path {
    path = ../.;
    name = "hyprpunk-nix";
  };

  # Pre-bake home directory with repo + stowed dotfiles
  homeDir = pkgs.runCommand "hyprpunk-home" {} ''
    mkdir -p $out/tmp
    chmod 1777 $out/tmp
    mkdir -p $out/home/softmax
    HOME=$out/home/softmax

    # Include the repo
    cp -r ${repoSrc} $HOME/hyprpunk-nix
    chmod -R u+w $HOME/hyprpunk-nix

    # Stow terminal dotfiles
    cd $HOME/hyprpunk-nix/dotfiles
    for pkg in fish tmux lazygit yazi neovim git scripts; do
      ${pkgs.stow}/bin/stow -d . -t $HOME --no-folding $pkg 2>/dev/null || true
    done

    # Copy btop config (it rewrites on exit)
    mkdir -p $HOME/.config/btop/themes
    cp $HOME/hyprpunk-nix/dotfiles/btop/.config/btop/btop.conf $HOME/.config/btop/btop.conf

    # Deploy themes
    mkdir -p $HOME/.local/share/hyprpunk
    ln -sf $HOME/hyprpunk-nix/dotfiles/themes $HOME/.local/share/hyprpunk/themes

    # Opencode themes
    mkdir -p $HOME/.config/opencode/themes
    for d in $HOME/hyprpunk-nix/dotfiles/themes/*/; do
      t=$(basename $d)
      [ -f "$d/opencode.json" ] && ln -sf "$d/opencode.json" "$HOME/.config/opencode/themes/$t.json"
    done
    echo '{"$$schema":"https://opencode.ai/tui.json","theme":"torrentz-hydra"}' > $HOME/.config/opencode/tui.json

    # SSH + git dirs
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
  '';

  etcDir = pkgs.runCommand "hyprpunk-etc" {} ''
    mkdir -p $out/etc
    echo "root:x:0:0:root:/root:/bin/bash" > $out/etc/passwd
    echo "softmax:x:1000:1000::/home/softmax:${pkgs.fish}/bin/fish" >> $out/etc/passwd
    echo "root:x:0:" > $out/etc/group
    echo "users:x:1000:softmax" >> $out/etc/group
    echo "hosts: files dns" > $out/etc/nsswitch.conf
  '';

in
pkgs.dockerTools.buildLayeredImage {
  name = "hyprpunk-dev";
  tag = "latest";

  contents = packages ++ [ homeDir etcDir ];

  config = {
    Env = [
      "LANG=en_US.UTF-8"
      "TERM=xterm-256color"
      "EDITOR=nvim"
      "VISUAL=nvim"
      "SHELL=${pkgs.fish}/bin/fish"
      "HOME=/home/softmax"
      "USER=softmax"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "HYPRPUNK_PATH=/home/softmax/.local/share/hyprpunk"
    ];
    Cmd = [ "${pkgs.fish}/bin/fish" ];
    WorkingDir = "/home/softmax";
  };
}
