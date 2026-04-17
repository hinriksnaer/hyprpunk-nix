{ config, lib, pkgs, modulesPath, ... }:

{
  # TODO: Replace with output of `nixos-generate-config --show-hardware-config`
  # on the target machine after NixOS installation.

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Filesystems -- replace UUIDs after install
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXXXXXX";
  #   fsType = "ext4";
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXXXXXX";
  #   fsType = "vfat";
  # };
}
