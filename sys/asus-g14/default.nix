{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../pkgs/asusctl.nix
      ../../env/i3wm-none.nix
      ../../env/development.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services = {
    printing = {
      drivers = [ pkgs.hplip ]; # todo add ofice printer samsung
    };
  };

  services.xserver.libinput.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "bulentk-g14";

  hardware = {
    opengl.driSupport32Bit = true;
  };
}