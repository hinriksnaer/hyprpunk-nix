{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    proton-pass-cli
    gnome-keyring
    libsecret  # secret-tool for D-Bus secret service
    keyutils   # keyctl for Linux kernel keyring (used by pass-cli)
  ];

  # Keyring for secret storage (used by pass-cli for session credentials)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
