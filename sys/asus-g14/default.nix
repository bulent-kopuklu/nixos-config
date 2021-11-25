{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../env/common.nix
      ../../env/modules/audio.nix
      ../../env/modules/bluetooth.nix
      ../../env/modules/network.nix
      ../../env/modules/keyboard.nix
      ../../env/modules/font.nix

#      ../../env/development.nix
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

  networking.hostName = "bulentk-g14";

  hardware = {
    opengl.driSupport32Bit = true;
  };

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  environment.systemPackages = with pkgs; [
    firefox

#    zeroad
#    zeroadPackages.zeroad-data
  ];
}