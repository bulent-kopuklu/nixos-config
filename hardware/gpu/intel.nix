{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Sometimes needed on new hardware for backlight control.
    xorg.xbacklight
    xorg.xf86videointel
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
