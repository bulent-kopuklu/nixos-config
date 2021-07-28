{ config, pkgs, ... }:

{
  services.xserver = {
    xkbOptions = "eurosign:e, grb: alt_space_toggle";
    xkbVariant = "alt";
    layout = "us, tr";
  };

  systemd.user.services.keychron-fn = {
    description = "enable function keys";
#    wantedBy = [ "graphical-session.target" ];
#    partOf = [ "graphical-session.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      "${pkgs.bash}/bin/bash -c \"echo 2 | tee /sys/module/hid_apple/parameters/fnmode\""
    '';
  };

#      "${pkgs.fish}/bin/fish -c \"echo 2 | tee /sys/module/hid_apple/parameters/fnmode\""
  systemd.services.keychron-fn.enable = true;
}
