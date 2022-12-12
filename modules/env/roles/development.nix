{ config, lib, pkgs, ... }:

let
  cfg =  config.env;
  
in {

  options = {
    env.role.development = lib.mkEnableOption "development role";
  };

  config = lib.mkIf cfg.role.development {

    # nixpkgs.config = {
    #   packageOverrides = pkgs: rec {
    #     jetbrains = pkgs.jetbrains.override {
    #       jdk = pkgs.jdk11;  
    #     };
    #   };
    # };

    env.role.virtualisation = lib.mkForce true;

    programs.adb.enable = true;
    
    users.users.${cfg.user.name}.extraGroups = ["adbusers"];

    services.udev.packages = [
      pkgs.android-udev-rules
    ];

    env.programs.vscode.enable = true;
    env.programs.gradle.enable = true;

    env.programs.docker.enable = true;


    environment.systemPackages = with pkgs; [
      gcc
      glibc.static
      gnumake
      cmake
      ninja
      gdb

      binutils-unwrapped

      jdk11
      maven

      python3

      scala
      sbt

#      go
#      gopls
#      gopkgs
#      go-outline
#      delve
#      go-tools

      # rustup toolchain install stable-x86_64-unknown-linux-gnu      
#      rustup

      rnix-lsp

      

      meld
      smartgithg
#      jetbrains.idea-ultimate

      wireshark
      twinkle

      # intellij idea plugin development
      jetbrains.idea-community

      xorg.libXrender
      xorg.libX11
      xorg.libXext
      xorg.libXtst
      xorg.libXi

 
      android-studio
      android-tools
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
      JAVA_HOME = "${pkgs.jdk11.home}";
      JDK_HOME = "${pkgs.jdk11.home}";
    };
  };
}
