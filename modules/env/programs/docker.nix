{ config, pkgs, lib, ... }:

let
  cfg = config.env.programs.docker;
in {
  options.env.programs.docker = {
    enable = lib.mkEnableOption "docker";
  };

  config = lib.mkIf cfg.enable {

    virtualisation.docker = {
      enable = true;
      liveRestore = false;
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      docker-machine
      dive
    ];

    environment.variables = {
      DOCKER_CONFIG = "$HOME/.config/docker";
    };

/*     env.user.files = {
      gradle = import ../../../config/gradle.nix;
    };
 */  
  };
}