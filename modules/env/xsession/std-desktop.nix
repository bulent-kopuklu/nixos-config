{ config, pkgs, lib, ... }:


let
  cfg = config.env.xsession;
in {
  options.env.xsession.enable = lib.mkEnableOption {
    default = false;
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        options = "eurosign:e,grb:alt_space_toggle";
        variant = "alt";
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
        nerdfonts
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
      gnome.gnome-keyring
      pinentry-gtk2
      firefox
      chromium
      thunderbird
      evince
      libreoffice

      vlc
      spotify

#      discord
      zoom-us
      tdesktop
      skypeforlinux

      qimgv
      gimp
#      teamviewer

#      tor-browser-bundle-bin
      system-config-printer
    ];
  };
}
