{ config, pkgs,... }:

{
  imports = [
    ./stddesktop.nix
    ../pkgs/smartgithg.nix
    ../pkgs/discord.nix
  ];

 
  environment.systemPackages = with pkgs; [
    jdk11
    openjfx11
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
    twinkle
  ];

  programs.fuse = {
    userAllowOther = true;
  };

  programs.npm = {
    enable = true;
    npmrc = ''
          prefix = ''${XDG_DATA_HOME}/npm
          cache = ''${XDG_CACHE_HOME}/npm
          tmp = ''${XDG_RUNTIME_DIR}/npm
        '';
  };

  virtualisation = {
    docker = {
      enable = true;
    };
    virtualbox.host = {
      enable = true;
    };
  };


  users.users.bulentk = {
    extraGroups = [ "wheel" "docker" "vboxusers" ];
  };

  environment.variables = {
    DOCKER_CONFIG = "$HOME/.config/docker";
    GRADLE_USER_HOME = "$HOME/.local/share/gradle";
#    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java";
    JAVA_HOME = "${pkgs.jdk11}";
  };

}
