{ config, pkgs, expr, buildVM, ... }:

{

    imports = [];

    nixpkgs.config = {
        packageOverrides = pkgs: rec {
            polybar = pkgs.polybar.override {
            i3Support = true;
            };
        };
    };

    services.xserver = {
        enable = true;
        useGlamor = true;

        layout = "us, tr";
        xkbOptions = "eurosign:e, grb: alt_space_toggle";
        xkbVariant = "alt";
        autorun = true;
        exportConfiguration = true;

        libinput = {
            enable = true;
            disableWhileTyping = true;
            naturalScrolling = false; # reverse scrolling
            scrollMethod = "twofinger";
            tapping = false;
            tappingDragLock = false;
        };

        # consensus is that libinput gives better results
        synaptics.enable = false;

        displayManager = {        
            defaultSession = "none+i3";
            lightdm = {
                enable = true;
            };

            sessionCommands = ''
                ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr

                ${pkgs.xlibs.xrdb}/bin/xrdb -merge ~/.Xresources
                # ${pkgs.xlibs.xrdb}/bin/xrdb -merge /etc/X11/Xresources

                [ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

                # Restore color profile.
                # NOTE: xiccd is too buggy and sometimes eats 100% cpu... and seems unmaintained
                # pgrep xiccd>/dev/null || ${pkgs.xiccd}/bin/xiccd &
                {pkgs.argyllcms}/bin/dispwin -I "/home/bulentk/.local/share/icc/B140HAN01.7 #1 2018-03-09 13-53 2.2 F-S XYZLUT+MTX.icc"

                # background image - nitrogen has better multihead support than feh
                ${pkgs.nitrogen}/bin/nitrogen --restore

                # Subscribes to the systemd events and invokes i3lock.
                # Send notification after 10 mins of inactivity,
                # lock the screen 10 seconds later.
                # TODO nixify xss-lock scripts
                ${pkgs.xlibs.xset}/bin/xset s 600 10
                ${pkgs.xss-lock}/bin/xss-lock -n /home/bulentk/.local/bin/lock-notify.sh -- /home/bulentk/.local/bin/lock.sh &

                # disable PC speaker beep
                # ${pkgs.xlibs.xset}/bin/xset -b

                # gpg-agent for X session
                gpg-connect-agent /bye
                GPG_TTY=$(tty)
                export GPG_TTY

                # use gpg-agent for SSH
                # NOTE: make sure enable-ssh-support is included in ~/.gnupg/gpg-agent.conf
                unset SSH_AGENT_PID
                export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"
            '';
        };


        windowManager.i3.enable = true;

    };

    environment.extraInit = ''
        # these are the defaults, but some applications are buggy so we set them
        # here anyway
    '';


    # GTK3 global theme (widget and icon theme)
#    environment.etc."xdg/gtk-3.0/settings.ini" = {
#        text = ''
#            [Settings]
#            gtk-icon-theme-name=breeze
#            gtk-theme-name=Breeze-gtk
#        '';
#        mode = "444";
#    };

    environment.systemPackages = with pkgs; [
        # i3 desktop support
        sxhkd
        dmenu
        networkmanager_dmenu
        dunst
        scrot
        fontconfig
        i3lock
        polybar
        libnotify
        xfontsel
        clipmenu
        pywal
        mpd
#        xsel

#        argyllcms # create color profiles
        # xiccd   # buggy 100% CPU color management
#        compton
        nitrogen  # better multihead support than feh
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
#        gnome3.gnome_themes_standard

        # Icons (Fallback)
#        oxygen-icons5
#        gnome3.adwaita-icon-theme
#        hicolor_icon_theme

        # These packages are used in autostart, they need to in systemPackages
        # or icons won't work correctly
#        udiskie 
    ];

    services.accounts-daemon.enable = true; # needed by lightdm

    # Required for our screen-lock-on-suspend functionality
    services.logind.extraConfig = ''
        LidSwitchIgnoreInhibited=False
        HandleLidSwitch=suspend
        HoldoffTimeoutSec=10
    '';

    # needed by gtk apps
    services.gnome3.at-spi2-core.enable = true;

    # Make applications find files in <prefix>/share
    environment.pathsToLink = [ "/share" "/etc/gconf" ];
}
