{ config, pkgs,... }:

{
  imports = [
    ./common.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/network.nix
    ./modules/keyboard.nix
    ./modules/font.nix
    ./modules/i3wm-none.nix
    ../pkgs/discord.nix    
  ];

  powerManagement.enable = true;

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
    dconf.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      dpi = 96;
      useGlamor = true;

      libinput = {
        enable = true;
      };

      synaptics.enable = false;
    };

    dbus = {
      enable = true;
      packages = [ 
        pkgs.gnome3.dconf
      ];
    };

    printing.enable = true;
    autorandr.enable = true;
    # needed by gtk apps
    gnome.at-spi2-core.enable = true;
    teamviewer.enable = true;
  };

    # Make applications find files in <prefix>/share
  environment.pathsToLink = [ "/share" "/etc/gconf" ];

  environment.systemPackages = with pkgs; [
    pinentry-gtk2
    # GTK theme
    numix-solarized-gtk-theme
    gnome3.adwaita-icon-theme
    gnome3.nautilus

    feh
    rofi
    gnupg

    firefox
    chromium
    thunderbird
    evince
    libreoffice

    vlc
    rhythmbox
    spotify
#    pulsemixer

    discord
    zoom-us
    tdesktop
    skype

    gimp
    teamviewer
  ];
}
