{ config, pkgs, expr, buildVM, ... }:

#let 
#    myscripts = pkgs.callPackage scripts/default.nix { inherit pkgs };
#in
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
        dpi = 96;

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

#        xautolock = {
#            enable = true;
#            time = 10;
#            locker 
#        };

        # consensus is that libinput gives better results
        synaptics.enable = false;

        displayManager = {        
            defaultSession = "none+i3";
            lightdm = {
                enable = true;
                greeters.enso.enable = true;
                background = /home/bulentk/.local/share/wallpapers/cls.png;
            };

            sessionCommands = ''
               # ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr



               ${pkgs.feh}/bin/feh --bg-scale $XDG_DATA_HOME/wallpapers/cwp

               # Send notification after 10 mins of inactivity,
               # lock the screen 10 seconds later.
               ${pkgs.xlibs.xset}/bin/xset s 600 10
               # ${pkgs.xss-lock}/bin/xss-lock -n $XDG_BIN_HOME/lock-notify.sh -- $XDG_BIN_HOME/lock.sh &

               # disable PC speaker beep
               # ${pkgs.xlibs.xset}/bin/xset -b

               # gpg-agent for X session
               # gpg-connect-agent /bye
               # GPG_TTY=$(tty)
               # export GPG_TTY

               # use gpg-agent for SSH
               # NOTE: make sure enable-ssh-support is included in ~/.gnupg/gpg-agent.conf
               # unset SSH_AGENT_PID
               # export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"
           '';
        };


        windowManager.i3.enable = true;

    };

    environment.systemPackages = with pkgs; [
        # i3 desktop support
        lxappearance
        xss-lock

        sxhkd
        dmenu
        networkmanager_dmenu
        scrot
        fontconfig
        udiskie 
 
        dunst
        libnotify

        i3lock
        polybar
#        clipmenu
#        mpd

    ];

    services.accounts-daemon.enable = true; # needed by lightdm

    # Required for our screen-lock-on-suspend functionality
    services.logind.extraConfig = ''
        LidSwitchIgnoreInhibited=False
        HandleLidSwitch=suspend
        HoldoffTimeoutSec=10
    '';
}
