{ config, pkgs,... }:

{

    powerManagement.enable = true;

    hardware.pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
        extraModules = [ pkgs.pulseaudio-modules-bt ];
        extraConfig = "
            load-module module-switch-on-connect
            ";
    };

    sound = {
        enable = true;
        mediaKeys.enable = true;
    };

    programs = {
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        dconf.enable = true;
    };

    services = {
        printing.enable = true;

        dbus = {
            enable = true;
            packages = [ 
                pkgs.gnome3.dconf
            ];
        };

        autorandr = {
            enable = true;
        };

        xserver.dpi = 96;
    };


    environment.systemPackages = with pkgs; [
        feh
        rofi
        gnupg

        firefox
        thunderbird
        evince
        libreoffice

        vlc
        rhythmbox
        spotify

        pulsemixer

        ranger

        discord
        zoom-us
        tdesktop
        skype

        gimp
    ];
}