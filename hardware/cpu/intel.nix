{ config, pkgs, ... }:

{
  hardware.cpu.intel.updateMicrocode = true;
  boot.initrd.kernelModules = [ "i915" ];

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
