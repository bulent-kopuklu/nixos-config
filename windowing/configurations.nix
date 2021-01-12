{ ... }:

{
    imports = [
        ./current.nix
    ];

    services.xserver = {
        enable = true;
        layout = "us";
        libinput.enable = true;
        
        desktopManager = {
            default = none;
            xterm.enable = false;
        };

        displayManager = {
            lightdm = {
                enable = true;
            };
        };
    };	
}