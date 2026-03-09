{ config, pkgs, lib, ... }:

let
  cfg = config.env.xsession.i3wm;
  theme-name = "NumixSolarizedDarkYellow";
  font-name = "DejaVu Sans 11";
  icon-theme-name = "Nordic-green";

in {
  options.env.xsession.i3wm = {
    enable = lib.mkEnableOption "i3wm";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager = {
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
            name = icon-theme-name;
          };
        };
      };

      sessionCommands = ''
        ${pkgs.autorandr}/bin/autorandr --change --force
#        ${pkgs.x11apps}/bin/set-wallpaper
      '';
    };

    services.displayManager.defaultSession = "none+i3";


    services.xserver.desktopManager = {
      xterm.enable = false;
    };

    services.xserver.windowManager.i3 = let
      confFile = import ../../../config/i3wm.nix { inherit pkgs; };
    in {
      enable = true;
      package = pkgs.i3-wrapped;

      extraPackages = with pkgs; [ 
        x11apps

        xss-lock
        xorg.xbacklight
        xorg.xmodmap
        xorg.xev
        xorg.xinput
        xorg.xmessage
        xorg.xkill
        xorg.xgamma
        xorg.xset
        xorg.xrandr
        xorg.xrdb
        xorg.xprop
        scrot
        fontconfig
        udiskie 
        i3lock
        rofi

        (xfce.thunar.override { thunarPlugins = [ 
          xfce.thunar-archive-plugin 
          xfce.thunar-volman
          xfce.thunar-dropbox-plugin
          xfce.thunar-media-tags-plugin
          ]; 
        })

        #gnome.gnome-calculator
        qalculate-gtk
        gparted
      ];
    };

    programs.i3lock.enable = true;
    security.pam.services.i3lock = {};
    programs.dconf.enable = true;
    env.services.x11-services.enable = true;

    env.programs.gtk.enable = true;

    services.accounts-daemon.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;

    # Portal'ın ve GTK uygulamalarının okuyacağı dconf veritabanını 
    # sistem seviyesinde override edelim
    environment.etc."dconf/db/local.d/01-gtk-ui".text = ''
      [org/gnome/desktop/interface]
      gtk-theme='${theme-name}'
      icon-theme='${icon-theme-name}'
      font-name='${font-name}'
    '';

    environment.etc."dconf/profile/user".text = ''
      user-db:user
      system-db:local
    '';    
  };
}