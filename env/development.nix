{ config, pkgs,... }:

{
  imports = [
    ./stddesktop.nix
    ../pkgs/smartgithg.nix
  ];
  
  environment.systemPackages = with pkgs; [
    jdk11
    scala
    python3
    python3Packages.pip

    rnix-lsp
    gcc
    glibc.static
    gnumake
    cmake
    binutils-unwrapped

    gradle_5
    maven
    jq
    smartgithg

    vscode
    jetbrains.idea-community
    docker-compose
    dive            # explorering a docker image 
    ripgrep
    fd
    meld
    postman
    wireshark
  ];

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  virtualisation = {
    docker = {
      enable = true;
    };
    virtualbox.host = {
      enable = true;
    };
  };

  users.users.bulentk = {
    extraGroups = [ "docker" "vboxusers" ];
  };
}