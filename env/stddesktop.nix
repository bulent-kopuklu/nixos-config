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
    gnupg.agent = {
      enable = true;
        enableSSHSupport = true;
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
        disableWhileTyping = true;
        naturalScrolling = false; # reverse scrolling
        scrollMethod = "twofinger";
        tapping = false;
        tappingDragLock = false;
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
    gnome3.at-spi2-core.enable = true;
    teamviewer.enable = true;
  };

    # Make applications find files in <prefix>/share
  environment.pathsToLink = [ "/share" "/etc/gconf" ];

  environment.systemPackages = with pkgs; [
    pinentry-gtk2
    # GTK theme
    numix-solarized-gtk-theme
    gnome3.adwaita-icon-theme

    feh
    rofi
#    gnupg

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
