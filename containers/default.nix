{ pkgs, packages }:

let
  repoSrc = builtins.path {
    path = ../.;
    name = "hyprpunk-nix";
  };

  homeDir = pkgs.runCommand "hyprpunk-home" {
    nativeBuildInputs = [ pkgs.stow ];
  } ''
    mkdir -p $out/tmp
    chmod 1777 $out/tmp
    mkdir -p $out/home/softmax

    # Include the repo and run bootstrap
    cp -r ${repoSrc} $out/home/softmax/hyprpunk-nix
    chmod -R u+w $out/home/softmax/hyprpunk-nix

    HOME=$out/home/softmax \
      bash $out/home/softmax/hyprpunk-nix/bootstrap.sh

    # SSH directory
    mkdir -p $out/home/softmax/.ssh
    chmod 700 $out/home/softmax/.ssh
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
