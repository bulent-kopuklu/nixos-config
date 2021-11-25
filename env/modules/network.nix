{ config, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable   = true;
      unmanaged = [
      ];
    };

    useDHCP = true;
    firewall.enable = false;
  # firewall.allowedTCPPorts = [ ... ];
  # firewall.allowedUDPPorts = [ ... ];

  };
}
