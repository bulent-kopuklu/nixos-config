{ config, pkgs, ... }:

{
  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = "
        load-module module-switch-on-connect
      ";
    }  
  };

  services = {
    blueman.enable = true;
  };
}
