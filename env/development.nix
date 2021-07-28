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
    nodejs
    nodePackages.npm
    nodePackages.webpack
#    nodePackages.webpack-cli

    bloop
    rnix-lsp
    gcc
    glibc.static
    gnumake
    cmake
    binutils-unwrapped

    gradle
    maven
    sbt

    smartgithg

    vscode-with-extensions
    jetbrains.idea-community
    jetbrains.pycharm-community
    
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

  environment.variables = {
    JAVA_HOME = "${pkgs.jdk11}";
  };

}
