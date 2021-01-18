
{ config, pkgs, gnome3, gconf, ... }:

{
    imports = [
        ../env/font.nix
        ../env/stddesktop.nix
        ../env/i3wm-none.nix
        ../env/development.nix
    ];

    boot.loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
    };

    swapDevices = [{
        device = "/var/.swapfile";
        size = 4096;
    }];

    virtualisation.virtualbox.guest.enable = true;
}