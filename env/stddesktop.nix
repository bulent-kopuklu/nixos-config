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
        printing = {
            enable = true;
            drivers = [ pkgs.hplip ];
        };

        dbus = {
            enable = true;
            packages = [ 
                pkgs.gnome3.dconf
            ];
        };

        autorandr = {
            enable = true;
        };

        # needed by gtk apps
        gnome3.at-spi2-core.enable = true;
    };

    # Make applications find files in <prefix>/share
    environment.pathsToLink = [ "/share" "/etc/gconf" ];

    environment.systemPackages = with pkgs; [
        pinentry-gtk2
        xlibs.xbacklight
        xlibs.xmodmap
        xlibs.xev
        xlibs.xinput
        xlibs.xmessage
        xlibs.xkill
        xlibs.xgamma
        xlibs.xset
        xlibs.xrandr
        xlibs.xrdb
        xlibs.xprop
       # GTK theme
        numix-solarized-gtk-theme
        gnome3.adwaita-icon-theme

        alacritty
        arandr

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