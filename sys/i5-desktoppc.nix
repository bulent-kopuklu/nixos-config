
{ config, pkgs,... }:

{
	networking.hostName = "bulentk-black";
	
    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    swapDevices = [{
        device = "/var/.swapfile";
        size = 18432;
    }];
}
