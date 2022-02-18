{ config, pkgs, lib, ... }:

let
  cfg = config.env.services.asus-linux.asusd;
in {
  options.env.services.asus-linux.asusd = {
    enable = lib.mkEnableOption "asusd";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.asus-linux.asusctl;
      defaultText = lib.literalExpression "pkgs.asus-linux.asusctl";
      description = ''
        asusd derivation to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
/* 
    systemd.user.services."asusd-user" = {
      description = "ASUS User Daemon";
      wantedBy = [ "default.target" ];

      unitConfig = {
        StartLimitIntervalSec = 5;
        StartLimitBurst = 2;
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 1;
        ExecStart="${cfg.package}/bin/asusd-user";
      };
    };

    systemd.user.services."asus-notify" = {
      description = "ASUS Notifications";
      wantedBy = [ "default.target" ];

      unitConfig = {
        StartLimitIntervalSec = 5;
        StartLimitBurst = 2;
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 1;
        ExecStart="${cfg.package}/bin/asus-notify";
      };
    };
*/
/*     systemd.services."asusd" = {
      environment = {
        IS_SERVICE = "1";
      };      

      unitConfig = {
        Description = "ASUS Notebook Control";
        After = [ "basic.target" "syslog.target" ];
      };

      serviceConfig = {
        Type = "dbus";
        BusName = "org.asuslinux.Daemon";
        Restart = "on-failure";
        ExecStart="${cfg.package}/bin/asusd";
      };

      wantedBy = [ "multi-user.target" ];
    };
 */ 
    environment.etc."asusd/asusd-ledmodes.toml".text = lib.fileContents "${cfg.package}/etc/asusd/asusd-ledmodes.toml";
  };
}