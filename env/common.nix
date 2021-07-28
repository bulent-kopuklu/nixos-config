{ config, pkgs,... }:

{
  users.users.bulentk = {
    isNormalUser = true;
    shell = pkgs.fish;

    group = "users";
    extraGroups = [ "wheel" ];

    createHome = true;
    home = "/home/bulentk";
  };

  security.sudo.wheelNeedsPassword = false;

  nix = {
    trustedUsers = [ "root" "bulentk" ];
  };


  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
    
  time.timeZone = "Europe/Istanbul";

  services = {
    openssh = {
      enable = true;
      allowSFTP = true;
    };

    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    sshd.enable = true;
  };

  programs = {
    fish = {
      enable = true;
      promptInit = ''
        any-nix-shell fish --info-right | source
      '';
    };
  };

  environment.variables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_BIN_HOME = "$HOME/.local/bin";
  };

  environment.systemPackages = with pkgs; [
    fish
    bash
    any-nix-shell
    alacritty
    ranger
    curl
    wget
    neovim
    git
    tree
    file
    gnutar
    p7zip
    bzip2
    gzip
    zstd
    lzma
    zip
    unrar
    unzip
    bmon
    htop
    iotop
    iftop
    nettools
    netcat
    psmisc
    lsof
    lshw
    usbutils
    pciutils
    nix-du
    iptables
    sqlite
    jq
    bc
    telnet
    envsubst
  ];
}