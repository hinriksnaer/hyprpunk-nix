{ ... }:

{
  imports = [
    # All terminal/dev tooling (no desktop)
    ./tooling.nix

    # OpenCode + gcloud for dev work
    ../modules/opencode.nix
  ];
}
