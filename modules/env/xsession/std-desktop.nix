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
      libinput.enable = true;

      xkbOptions = "eurosign:e,grb:alt_space_toggle";
      xkbVariant = "alt";
      layout = "us,tr";
      dpi = 96;
      useGlamor = true;

      synaptics.enable = false;
      exportConfiguration = true;
    };

    fonts = {
      enableDefaultFonts = true;
      fontDir.enable = true;

      fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "MPlus" ]; })
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "DejaVuSansMono" ];
        };
      };
    };

    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    services.printing.enable = true;
    services.dbus.enable = true;

    programs.gnupg.agent = {
      enableExtraSocket = true;
      enableBrowserSocket = true;
      pinentryFlavor = if cfg.i3wm.enable == true then "gtk2" else null;
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
      pinentry-gtk2
      firefox
      chromium
      thunderbird
      evince
      libreoffice

      vlc
      spotify

      discord
      zoom-us
      tdesktop
      skype

      qimgv
      gimp
      teamviewer

      tor-browser-bundle-bin
      system-config-printer
    ];
  };
}
