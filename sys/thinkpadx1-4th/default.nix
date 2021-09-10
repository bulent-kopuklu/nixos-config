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
    
    xserver = {
      libinput = {
        touchpad = {
          disableWhileTyping = true;
          tappingDragLock = false;
          tapping = false;
          scrollMethod = "twofinger";
          naturalScrolling = false; # reverse scrolling
        };
      };
    };
  };


  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "bulentk-x1";

  hardware = {
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    zeroad
    zeroadPackages.zeroad-data
  ];
}