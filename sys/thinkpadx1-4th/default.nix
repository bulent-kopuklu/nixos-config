{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../env/development.nix
    ];

  services = {
    printing = {
      drivers = [ pkgs.hplip ]; # todo add ofice printer samsung
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  swapDevices = [{
    device = "/var/.swapfile";
    size = 18432;
  }];

  hardware = {
    opengl.driSupport32Bit = true;
  };

  system.stateVersion = "20.09";
}