{ config, pkgs, lib, ... }:

let
  cfg = config.env.programs.gradle;
in {
  options.env.programs.gradle = {
    enable = lib.mkEnableOption "gradle";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      gradle
    ];

    env.user.files = {
      gradle = import ../../../config/gradle.nix;
    };
  };
}