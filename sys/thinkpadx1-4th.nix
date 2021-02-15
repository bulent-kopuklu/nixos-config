
{ config, pkgs,... }:

{
    imports = [
        ../env/font.nix
        ../env/stddesktop.nix
        ../env/i3wm-none.nix
        ../env/development.nix
    ];

	networking.hostName = "bulentk-x1";
	
    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    swapDevices = [{
        device = "/var/.swapfile";
        size = 18432;
    }];

    hardware = {
        opengl.driSupport32Bit = true;
        pulseaudio.support32Bit = true;
        bluetooth.enable = true;
    };

    services = {
        blueman.enable = true;
    };
}
