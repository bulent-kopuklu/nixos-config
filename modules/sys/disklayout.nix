{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.disk;
in {
  options.sys.disk = {
    layout = mkOption {
      type = types.enum [ "btrfs" "btrfs-crypt" "vm" ];
      description = "This is the layout of the disk used by the system.";
      default = "btrfs-crypt";
    };

    swapFileSize = mkOption {
      example = 2048;
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = ''
        If this option is set, device is interpreted as the
        path of a swapfile that will be created automatically
        with the indicated size (in megabytes).
      '';
    };
  };

  config = mkMerge [
    (mkIf (cfg.layout == "btrfs-crypt") {
      boot.initrd.luks.devices."system".device = "/dev/disk/by-partlabel/cryptsystem";
      fileSystems."/" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

      fileSystems."/home" = { 
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = [ "subvol=@home" "autodefrag" "noatime" ];
      };

      # fileSystems."/var" = { 
      #   device = "/dev/disk/by-label/system";
      #   fsType = "btrfs";
      #   options = [ "subvol=@var" "autodefrag" "noatime" ];
      # };

      fileSystems."/nix" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = [ "subvol=@nix" "autodefrag" "noatime" ];
      };

      fileSystems."/.snapshots" = {
        device = "/dev/disk/by-label/system";
        fsType = "btrfs";
        options = [ "subvol=@snapshots" "autodefrag" "noatime" ];
      };

      fileSystems."/boot" = { device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
      };

      swapDevices = [{
        device = "/var/.swapfile";
        size = cfg.swapFileSize;

        # device = "dev/disk/by-label/SWAP";
        # randomEncryption.enable = true; 
      }];

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        grub.enable = false;
      };
    })

    (mkIf (cfg.layout == "vm") {
      fileSystems."/" = { 
        device = "/dev/disk/by-label/nixos";
        autoResize = true;
        fsType = "ext4";
      };

      swapDevices = [{
        device = "/var/.swapfile";
        size = cfg.swapFileSize;
      }];

      boot.growPartition = true;

      boot.loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    })
  ];
}
