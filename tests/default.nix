# Nix derivation that runs the script test suite in a sandbox.
# Used by `nix flake check` via flake.nix checks output.
{ pkgs, src }:

pkgs.runCommand "hawker-script-tests" {
  nativeBuildInputs = with pkgs; [
    fish
    coreutils
    gnugrep
    gnused
    gawk
    findutils
    bash
    stow
    git
  ];
} ''
  # Copy source to writable directory, fix shebangs for sandbox
  cp -r ${src} ./repo
  chmod -R u+w ./repo
  chmod -R +x ./repo/dotfiles/scripts/.local/bin/
  patchShebangs ./repo/dotfiles/scripts/.local/bin/

  # Run the test suite
  bash ./repo/tests/run-tests.sh ./repo

  # Nix requires output
  touch $out
''
