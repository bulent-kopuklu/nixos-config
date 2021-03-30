{ config, pkgs, ... }:

{
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    paprefs
  ];
}
