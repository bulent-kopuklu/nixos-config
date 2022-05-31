{config, lib, pkgs, ...}:

let
  cfg =  config.env.role;
  

in {

  options = {
    env.role.development = lib.mkEnableOption "development role";
  };

  config = lib.mkIf cfg.development {
    env.role.virtualisation = lib.mkForce true;

    env.programs.vscode.enable = true;
    env.programs.gradle.enable = true;

    env.programs.docker.enable = true;

    environment.systemPackages = with pkgs; [
      gcc
      glibc.static
      gnumake
      cmake
      binutils-unwrapped

      jdk11
      maven

      python3

      scala
      sbt

      go
      gopls
      gopkgs
      go-outline
      delve
      go-tools

      # rustup toolchain install stable-x86_64-unknown-linux-gnu      
      rustup

      rnix-lsp

      

      meld
      smartgithg
      jetbrains.idea-ultimate

      docker-machine
      dive            # exploring a docker image 

      wireshark
      twinkle

      # intellij idea plugin development
      jetbrains.idea-community
      xorg.libXrender
      xorg.libX11
      xorg.libXext
      xorg.libXtst
      xorg.libXi

    ];

    programs.npm = {
      enable = true;
      npmrc = ''
        prefix = ''${XDG_DATA_HOME}/npm
        cache = ''${XDG_CACHE_HOME}/npm
        tmp = ''${XDG_RUNTIME_DIR}/npm
      '';
    };

    environment.variables = {
      GRADLE_USER_HOME = "$HOME/.local/share/gradle";
      JAVA_HOME = "${pkgs.jdk11}";
    };
  };
}
