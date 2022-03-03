{ config, pkgs, lib, ... }:

let
  cfg = config.env.programs.gtk;

  theme-name = "NumixSolarizedDarkGreen";
  font-name = "DejaVu Sans 11";
  icon-theme-name = "Numix";
  
in {
  options.env.programs.gtk = {
    enable = lib.mkEnableOption "gtk";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gtk2
      gtk3
      gtk4
      gtk-engine-murrine
      gtk_engines
      numix-solarized-gtk-theme
      papirus-icon-theme
    ];

    services.gnome.at-spi2-core.enable = true;

    # environment.variables = {
    #   GTK_THEME = "${theme-name}";
    #   GTK_ICON_THEME = "${icon-theme-name}";
    # };

    environment.etc = {
      "xdg/gtk-2.0/gtkrc" = {
        mode = "444";
        text = ''
          gtk-theme-name = "${theme-name}"
          gtk-icon-theme-name = "${icon-theme-name}"
          gtk-font-name = "${font-name}"
        '';
      };
      "xdg/gtk-3.0/settings.ini" = {
        mode = "444";
        text = ''
          [Settings]
          gtk-theme-name = ${theme-name}
          gtk-icon-theme-name = ${icon-theme-name}
          gtk-font-name = ${font-name}
          gtk-application-prefer-dark-theme = 1
        '';
      };

      "xdg/gtk-3.0/gtk.css" = {
        mode = "444";
        text = ''
          window decoration {
            border: double;
          }
          /* regular thunar toolbar icons */
          .thunar {
            -gtk-icon-style: regular;
          }
        '';
      };

      # "xdg/gtk-3.0/bookmarks" = {
      #   mode = "444";
      #   text = ''
      #   '';
      # };

    };
  };
}