{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../env/development.nix
    ];


  services.xserver.libinput.enable = true;

  services = {
    printing = {
      drivers = [ pkgs.hplip ]; # todo add ofice printer samsung
    };
  };


  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "bulentk-g14";

  hardware = {
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    zeroad
    zeroadPackages.zeroad-data
  ];
}