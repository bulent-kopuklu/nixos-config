{ config, pkgs, ... }:

{
  services.xserver = {
    xkbOptions = "eurosign:e, grb: alt_space_toggle";
    xkbVariant = "alt";
    layout = "us, tr";
  };

  systemd.services.keychron-fn = {
    enable = true;
    description = "enable keychron keyboard function keys";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c "${pkgs.coreutils}/bin/echo 2 | ${pkgs.coreutils}/bin/tee /sys/module/hid_apple/parameters/fnmode"
      '';
    };
  };
}
