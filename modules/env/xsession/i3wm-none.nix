{ config, pkgs, lib, ... }:

let
  cfg = config.env.xsession.i3wm;
in {
  options.env.xsession.i3wm = {
    enable = lib.mkEnableOption "i3wm";
  };

  config = lib.mkIf cfg.enable {

    services.xserver.displayManager = {
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        background = ../../../config/wallpapers/doom-src.png;
        greeters.gtk = {
          enable = true;
          theme = {
            package = pkgs.nordic;
            name = "Nordic";
          };
          iconTheme = {
            package = pkgs.numix-icon-theme;
            name = "Numix";
          };
        };
      };

#      sessionCommands = ''
#        ${pkgs.autorandr}/bin/autorandr --change --force
#        ${pkgs.x11apps}/bin/set-wallpaper
#      '';
    };

    services.xserver.desktopManager = {
      xterm.enable = false;
    };

    services.xserver.windowManager.i3 = let
      confFile = import ../../../config/i3wm.nix { inherit pkgs; };
    in {
      enable = true;
      package = pkgs.i3-wrapped;

#      configFile = confFile;
      
      extraPackages = with pkgs; [ 
        x11apps

        xss-lock
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
        scrot
        fontconfig
        udiskie 
        i3lock
        rofi
        gnome.gnome-calculator
        gnome.nautilus
        gnome.gnome-disk-utility
#        feh
#        sxhkd-wrapped
#        dunst-wrapped
        
      ];
    };

    programs.dconf.enable = true;
    env.services.x11-services.enable = true;

    env.programs.gtk.enable = true;

    services.accounts-daemon.enable = true;
    services.gnome.gnome-keyring.enable = true;
  };
}