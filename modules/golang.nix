{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
  ];

  environment.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };
}
