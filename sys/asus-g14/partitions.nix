{ config, lib, pkgs, modulesPath, ... }:

{
#  boot.initrd.luks.devices."system".device = "/dev/disk/by-uuid/93d009ba-a609-4c34-b8a3-17bddbb6ed4b";
  boot.initrd.luks.devices."system".device = "/dev/disk/by-partlabel/cryptsystem";

  fileSystems."/" = {
    device = "/dev/disk/by-label/system";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = { 
    device = "/dev/disk/by-label/system";
      fsType = "btrfs";
     options = [ "subvol=@home" ];
    };

  fileSystems."/srv" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@srv" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@docker" ];
    };

  fileSystems."/var/lib/machine" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@machine" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-label/system";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/var/.swapfile";
    size = 18432;
  }];

}