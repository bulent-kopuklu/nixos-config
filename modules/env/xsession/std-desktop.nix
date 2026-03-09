{ config, pkgs, lib, ... }:

let
  cfg = config.env.xsession;
  devRole = config.env.role.development;
  defaultApps = [
    "org.mozilla.firefox"
    "com.google.Chrome"
    "org.mozilla.Thunderbird"
    "org.gnome.Evince"
    "org.libreoffice.LibreOffice"
    "org.videolan.VLC"
    "com.spotify.Client"
    "us.zoom.Zoom"
    "org.telegram.desktop"
    "org.gimp.GIMP"
  ];
  devApps = [
    "com.getpostman.Postman"
    "org.gnome.meld"
    "io.dbeaver.DBeaverCommunity"
    "org.wireshark.Wireshark"
  ];

  allApps = defaultApps ++ (lib.optionals devRole devApps);

  theme-name = "NumixSolarizedDarkYellow";
  font-name = "DejaVu Sans 11";
  icon-theme-name = "Nordic-green";

in {
  options.env.xsession.enable = lib.mkEnableOption {
    default = false;
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        options = "eurosign:e";
        layout = "us,tr";
      };

      dpi = 96;

      synaptics.enable = false;
      exportConfiguration = true;
    };

    services.libinput.enable = true;


    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      packages = with pkgs; [
#        (nerdfonts.override { fonts = [ "MPlus" ]; })
        nerd-fonts."m+"
        nerd-fonts.iosevka
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "DejaVuSansMono" ];
        };
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
#      driSupport32Bit = true;
    };

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
    
    services.dbus.enable = true;

    programs.gnupg.agent = {
      enableExtraSocket = true;
      enableBrowserSocket = true;
#      pinentryFlavor = if cfg.i3wm.enable == true then "gtk2" else null;
    };

    programs.browserpass.enable = true;

    services.flatpak = {
      enable = true;

      update.auto.enable = false;
      uninstallUnmanaged = false;
      packages = allApps;
      overrides = {
        global = {
          Environment = {
            GTK_THEME = "NumixSolarizedDarkYellow";
            GTK_ICON_THEME = "Papirus-Dark";
            GTK_CURSOR_THEME = "elementary";
            GTK_CURSOR_SIZE = "24";
          };
          Context = {
            filesystems = [
              "~/.themes:ro"
              "~/.icons:ro"
              "xdg-config/fontconfig:ro"
              "xdg-config/gtk-2.0:ro"
              "xdg-config/gtk-3.0:ro"
              "xdg-config/gtk-4.0:ro"
              "xdg-config/dconf:ro" # Portal dconf'u buradan okur                            
            ];
          };
        };
      };
    };

    system.activationScripts.flatpak-themes = {
      text = ''
        # Tema linkleri
        mkdir -p /home/bulentk/.themes
        ln -sfn ${pkgs.numix-solarized-gtk-theme}/share/themes/${theme-name} /home/bulentk/.themes/${theme-name}
        
        mkdir -p /home/bulentk/.icons
        ln -sfn ${pkgs.nordic}/share/icons/${icon-theme-name} /home/bulentk/.icons/${icon-theme-name}

        # Dconf veritabanını güncelle (Portal'ın görmesi için)
        ${pkgs.dconf}/bin/dconf update
      '';
    };    



    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];

      config.common.default = "*";
    };
    
    programs.zsh = {
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

      syntaxHighlighting.enable = true;

      ohMyZsh = {
        enable = true;
        plugins = [ "git" "web-search" "copyfile" ];
  #      theme = "fishy";
      };
    };

    #fthis is required for mounting android phones
    # over mtp://
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-keyring
      pinentry-gtk2
      squeezelite

      qimgv
      gimp
      arandr
#      teamviewer

#      tor-browser-bundle-bin
      system-config-printer
    ];
  };
}
