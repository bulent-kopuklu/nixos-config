{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.hw;
  keychron-mode-file = "/sys/module/hid_apple/parameters/fnmode"; 

  keychron-fn-key-enable = pkgs.writeShellScriptBin "keychron-fn-key-enable" ''
    if [ -f "${keychron-mode-file}" ]; then 
      ${pkgs.coreutils-full}/bin/echo 0 | ${pkgs.coreutils-full}/bin/tee ${keychron-mode-file} 
    fi
  '';

in {
  options.sys.hw = {
    cpu = {
      type = mkOption {
        type = types.enum ["intel" "amd" "arm"];
        description = "Type of cpu the system has in it";
      };

      cores = mkOption {
        type = types.ints.unsigned;
        default = 1;
        description = "Number of physical cores on cpu per socket";
      };

      sensorTemperaturePath = mkOption {
        type = types.nullOr types.str;
        description = "Command to get cpu temp";
        default = null;
      };
    };

    memorySize = mkOption {
      type = types.ints.unsigned;
      default = null;
    };

    sound = mkEnableOption {
      default = false;
      description = "System sound support";
    };

    wifi = mkEnableOption {
      default = false;
      description = "System has a wifi adapter";
    };

    bluetooth = mkEnableOption {
      default = false;
      description = "System has a bluetooth adapter";
    };

    battery =  {
      enable = mkEnableOption {
        default = false;
        description = "System has a battery";
      };

      name = mkOption {
        type = types.str;
        description = "Command to get cpu temp";
        default = "BAT0";
      };

      adapter = mkOption {
        type = types.str;
        description = "Command to get cpu temp";
        default = "AC";
      };
    };

    keychron = mkEnableOption {
      default = false;
      description = "System uses keychron keyboard";
    };

    nics = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkMerge [

    (mkIf (cfg.sound == true) {
      sound.enable = true;

      hardware.pulseaudio = {
        enable = true;
        systemWide = false;
        support32Bit = true;
        package = (mkIf (cfg.bluetooth == true) pkgs.pulseaudioFull);
        extraConfig = "
          load-module module-switch-on-connect
          unload-module module-suspend-on-idle
        ";
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        (if (cfg.bluetooth == true) then pkgs.pulseaudioFull else pkgs.pulseaudio)
      ];
    })

    {
#      networking.wireless.enable = lib.mkForce false;
      networking.wireless.enable = cfg.wifi;
#       networking.wireless.allowAuxiliaryImperativeNetworks = cfg.wifi;
#       networking.networkmanager.unmanaged = (mkIf (cfg.wifi) [
#         "*" "except:type:wwan" "except:type:gsm"
#       ]);
    }

    (mkIf (cfg.bluetooth == true) {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez;
      };

      services.blueman.enable = true;
      services.dbus.packages = [ pkgs.blueman ];
    })

    (mkIf (cfg.keychron == true) {
      # New USB device found, idVendor=05ac, idProduct=024f, bcdDevice= 1.03 
      # function keys enable
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEMS=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="024f" RUN+="${keychron-fn-key-enable}/bin/keychron-fn-key-enable"
      '';
    })

    (mkIf (cfg.nics != [ ]) {
      networking.interfaces = mkOverride 0 (listToAttrs (forEach cfg.nics (n:
          nameValuePair "${n}" {
            useDHCP = true;
          })));

/*       networking.interfaces = listToAttrs (map (n: {
        name = "${n}"; value = { useDHCP = true; };
      }) cfg.nics);
 */    })

    (mkIf (cfg.nics != [ ] || cfg.wifi == true) {
      services.resolved.enable = true;
    })
  ];

}