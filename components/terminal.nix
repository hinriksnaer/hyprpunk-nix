# Full terminal stack for desktop (extends headless + adds kitty).
{ ... }:

{
  imports = [
    ./terminal-headless.nix
    ../modules/kitty.nix
  ];
}
