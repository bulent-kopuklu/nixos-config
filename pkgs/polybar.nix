{ config, pkgs, ... }:

{
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
        alsaSupport = false;
        pulseSupport = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libpulseaudio
    pamixer
  ];
}