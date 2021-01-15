{ config, pkgs, ... }:

{
    imports = [
        ./current.nix
    ];

    services.xserver = {
        enable = true;
        layout = "us";
        libinput.enable = true;
        
        desktopManager = {
            xterm.enable = false;
        };

        displayManager = {
            lightdm = {
                enable = true;
            };
        };
    };	
}