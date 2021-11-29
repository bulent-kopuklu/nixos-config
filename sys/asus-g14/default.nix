{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../env/gnome.nix
      ../../env/development.nix

    ];

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