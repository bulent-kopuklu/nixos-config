{ config, pkgs, lib, ... }:

let
  cfg = config.env.programs.gtk;
in {
  options.env.programs.gtk = {
    enable = lib.mkEnableOption "i3wm";
  };

  config = lib.mkIf cfg.enable {

#    services.dbus.packages = [ pkgs.gnome3.dconf ];

    environment.systemPackages = with pkgs; [
      gtk2
      gtk3
#        gtk4
      numix-solarized-gtk-theme
      papirus-icon-theme

    ];

      # needed by gtk apps
    services.gnome.at-spi2-core.enable = true;

#    dconf.settings."org/gnome/desktop/interface" = dconfIni;

    # environment.etc."gtk-2.0/gtkrc" = import ../../../config/gtk/gtk2-rc.nix;
    # environment.etc."gtk-3.0/settings.ini" = import ../../../config/gtk/gtk3-rc.nix;
    # environment.etc."gtk-3.0/gtk.css" = import ../../../config/gtk/gtk3-css.nix;
    env.user.files = {
      gtk2rc = import ../../../config/gtk/gtk2-rc.nix;
      gtk3-settings = import ../../../config/gtk/gtk3-rc.nix;
      gtk3-css = import ../../../config/gtk/gtk3-css.nix;
# #      gtk4 = import ../../../config/gtk4.nix;
    };
  };
}