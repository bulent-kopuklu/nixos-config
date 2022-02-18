{ config, pkgs, lib, ... }:

let
  cfg = config.env.services.asus-linux.supergfxd;
in {
  options.env.services.asus-linux.supergfxd = {
    enable = lib.mkEnableOption "supergfxd";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.asus-linux.supergfxctl;
      defaultText = lib.literalExpression "pkgs.asus-linux.supergfxctl";
      description = ''
        supergfxd derivation to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

  };
}