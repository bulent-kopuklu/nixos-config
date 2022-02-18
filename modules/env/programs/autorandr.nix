{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.env.programs.autorandr;

in {
  options.env.programs.autorandr = {
    enable = mkEnableOption "autorandr";

    profiles = mkOption {
      default = {};
      type = types.attrsOf (lib.types.submodule {
        options = {
          config = mkOption {
            type = types.path;
            description = "config file of profile";
          };

          setup = mkOption {
            type = types.path;
            description = "setup file of profile";
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.autorandr ];

    env.user.files = mkMerge [
      (mapAttrs' (name: profile: nameValuePair ("${name}-config") (import profile.config)) cfg.profiles)
      (mapAttrs' (name: profile: nameValuePair ("${name}-setup") (import profile.setup)) cfg.profiles)
    ];
  };
}