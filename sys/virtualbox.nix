
{ config, pkgs,... }:

{
    imports = [
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

    hardware = {
        bluetooth.enable = true;
        pulseaudio.enable = true;
        opengl.driSupport32Bit = true;
        pulseaudio.support32Bit = true;
    };

    powerManagement.enable = true;

    programs = {
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };
    };

    services = {
        printing.enable = true;
        blueman.enable = true;

        dbus = {
            enable = true;
        };
    };

    sound = {
        enable = true;
        mediaKeys.enable = true;
    };


    virtualisation.virtualbox.guest.enable = true;
}