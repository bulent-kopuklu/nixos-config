
{ config, pkgs, ...}:

{
  imports = [
    ./stddesktop.nix
  ];

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/42053
      # autoSuspend = false;
    };
    desktopManager.gnome = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Apps
    gnome3.gnome-tweaks
    gnome3.gnome-sound-recorder
    # Extensions
    gnomeExtensions.paperwm
    gnomeExtensions.appindicator

    # For scripting
    xdotool
  ];
}