{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disklayout.nix
  ];

  hardware = {
    firmware = [ pkgs.firmwareLinuxNonfree ];
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  services.fwupd.enable = true;

  networking = {
    useDHCP = false;
    firewall.enable = false;

    networkmanager.enable = true;
  };
}
