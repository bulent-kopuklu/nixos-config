
{ config, pkgs, lib, ... }:

let
  cfg = config.env.services.x11-services;
  pulseaudio-service = if (config.sys.hw.sound == true) then "pulseaudio.socket" else "";
  pkgs-polybar = (pkgs.polybar-wrapped.override {
        cpuTemperaturePath = config.sys.hw.cpu.sensorTemperaturePath;
        soundSupport = config.sys.hw.sound; 
        wifiSupport = config.sys.hw.wifi; 
        battery = config.sys.hw.battery; 
      });

in {
  options.env.services.x11-services = {
    enable = lib.mkEnableOption "x11-services";
  };

  config = lib.mkIf cfg.enable {
    env.programs.autorandr.enable = true;

    environment.systemPackages = with pkgs; [
      libnotify
      pkgs-polybar
      dunst-wrapped
      sxhkd-wrapped
    ];

    systemd.user.services = lib.mkMerge [
      {
        wallpaper = {
          wantedBy = [ "graphical-session.target" ];

          unitConfig = {
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };
          
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.x11apps}/bin/set-wallpaper";
          };
        };

        sxhkd = {
          wantedBy = [ "graphical-session.target" ];
          
          unitConfig = {
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };

          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            ExecStart = "${pkgs.sxhkd-wrapped}/bin/sxhkd -t 2";
          };
        };

        dunst = {
          wantedBy = [ "graphical-session.target" ];
          
          unitConfig = {
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };

          serviceConfig = {
            Type = "dbus";
            BusName = "org.freedesktop.Notifications";
            ExecStart = "${pkgs.dunst-wrapped}/bin/dunst";
            Restart = "on-failure";            
          };
        };

        autorandr = {
          wantedBy = [ "graphical-session.target" ];
          
          unitConfig = {
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session-pre.target" ];
          };

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.autorandr}/bin/autorandr --change --force";
          };
        };

        polybar = {
          wantedBy = [ "tray.target" ];
          
          unitConfig = {
            PartOf = [ "tray.target" ];
            Required = [ "graphical-session.target" ];
          };

          serviceConfig = {
            Type = "forking";
            Restart = "on-failure";
            Environment = "PATH=/run/wrappers/bin:/home/${config.env.user.name}/.nix-profile/bin:/etc/profiles/per-user/${config.env.user.name}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
            ExecStart = "${pkgs-polybar}/bin/polybar-launcher";
            ExecStop = "${pkgs-polybar}/bin/polybar-msg cmd quit";
          };
        };
      }
      (lib.mkIf(config.sys.hw.keychron == true) {
        asus-micmute-key = {
          wantedBy = [ "graphical-session.target" ];
          
          unitConfig = {
            PartOf = [ "graphical-session.target" ];
            Before = [ "sxhkd.service" ];
          };

          serviceConfig.Type = "oneshot";
          script = ''
            ${pkgs.xlibs.xmodmap}/bin/xmodmap -e "keycode 121 = XF86AudioMute XF86AudioMicMute XF86AudioMute"
          '';
        };
      })
    ];
  };
}

