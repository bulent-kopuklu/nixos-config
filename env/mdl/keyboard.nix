{ config, pkgs, ... }:

{
  services.xserver = {
    xkbOptions = "eurosign:e, grb: alt_space_toggle";
    xkbVariant = "alt";
    layout = "us, tr";
  };

  systemd.user.services.keychron = {
    description = "keychron function keys";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.fish} -c \"echo 2 > /sys/module/hid_apple/parameters/fnmode\"";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
