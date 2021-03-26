
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
        bluetooth.enable = true;
    };

    services = {
        blueman.enable = true;
        xserver = {
            # videoDrivers = ["intel"];
            xrandrHeads = [
                { 
                    output = "eDP-1";
                    primary = true;
                    monitorConfig = ''
                        Option "PreferredMode" "2560x1440"
                        Option "Position" "0 0"
                    '';
                }
                { 
                    output = "DP-1-8";
                    monitorConfig = ''
                        Option "PreferredMode" "2560x1440"
                        Option "Position" "2560 0"
                    '';
                }
                { 
                    output = "DP-1-1";
                    monitorConfig = ''
                        Option "PreferredMode" "2560x1440"
                        Option "Position" "5120 0"
                    '';
                }
            ];            
        };
    };
}
