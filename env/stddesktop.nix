{ config, pkgs,... }:

{
  imports = [
    ./common.nix
    ./modules/audio.nix
    ./modules/network.nix
    ./modules/keyboard.nix
    ./modules/font.nix
    ../pkgs/discord.nix    
  ];

  powerManagement.enable = true;

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      enableBrowserSocket = true;
      pinentryFlavor = "gtk2";
    };
  };

  programs.browserpass.enable = true;

  services.xserver = {
    enable = true;
    dpi = 96;
    useGlamor = true;

    synaptics.enable = false;
  };

  services.dbus = {
    enable = true;
    packages = [ 
      pkgs.gnome3.dconf
    ];
  };

  services.printing.enable = true;
  services.autorandr.enable = true;
    # needed by gtk apps
  services.gnome.at-spi2-core.enable = true;
  services.teamviewer.enable = true;

    # Make applications find files in <prefix>/share
  environment.pathsToLink = [ "/share" "/etc/gconf" ];

  environment.variables = {
#    GNUPGHOME = "$HOME/.local/share/gnupg";
  };


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
