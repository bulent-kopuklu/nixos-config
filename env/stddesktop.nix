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

    printing = {
      enable = true;
    };

    dbus = {
      enable = true;
      packages = [ 
        pkgs.gnome3.dconf
      ];
    };

    autorandr = {
      enable = true;
    };

    # needed by gtk apps
    gnome3.at-spi2-core.enable = true;
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
  ];
}
