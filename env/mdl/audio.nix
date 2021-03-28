{ config, pkgs, ... }:

{
  sound = {
    enable = true;
     mediaKeys.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    paprefs
  ];
}
