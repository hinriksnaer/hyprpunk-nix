{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustup
    mold
    clang
  ];
}
