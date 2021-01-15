
{ config, pkgs,... }:

{
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
