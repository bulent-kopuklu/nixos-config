{ config, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable   = true;
      unmanaged = [
      ];
    };

    useDHCP = false;
    firewall.enable = false;
  # firewall.allowedTCPPorts = [ ... ];
  # firewall.allowedUDPPorts = [ ... ];

  };
}
