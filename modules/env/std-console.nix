{ pkgs, ... }:

{

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestions = {
      enable = true;
    };

    syntaxHighlighting = {
      enable = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    bash
    git
    vim
    wget
    coreutils-full
    any-nix-shell
    ranger
    pass
    curl
    neovim
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
    zlib
    bmon
    htop
    iotop
    iftop
    nettools
    netcat
    iptables
    conntrack-tools
    httping
    ipvsadm
    bind
    psmisc
    lsof
    lshw
    usbutils
    pciutils
    nix-du
    sqlite
    jq
    bc
    inetutils
    envsubst
    xsel
  ];
}