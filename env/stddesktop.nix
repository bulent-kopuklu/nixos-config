{ config, pkgs,... }:

{

    powerManagement.enable = true;

    hardware = {
        pulseaudio.enable = true;
#        opengl.driSupport32Bit = true;
#        pulseaudio.support32Bit = true;
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
        sublime
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

        slack
        discord
        zoom-us
        tdesktop
        skype
    ];
}