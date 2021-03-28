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

  programs = {
    fish = {
      enable = true;
      promptInit = ''
        any-nix-shell fish --info-right | source
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    fish
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
  ];

}