
{ config, pkgs,... }:

{
    imports = [
        ./dm/i3wm-none.nix
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

    users.users.bulentk = {
        extraGroups = [ "docker" "vboxusers" ];
    };

    hardware = {
        bluetooth.enable = true;
        pulseaudio.enable = true;
        opengl.driSupport32Bit = true;
        pulseaudio.support32Bit = true;
    };
    
    sound = {
        enable = true;
        mediaKeys.enable = true;
    };

    powerManagement.enable = true;


    programs = {
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };
    };

    services = {
        printing.enable = true;
        blueman.enable = true;

        dbus = {
            enable = true;
        };
    };

    environment.systemPackages = with pkgs; [
        sublime
        vscode
        emacs

        docker-compose
        dive            # explorering a docker image 
    
        jdk11
        smartgithg

        thunderbird
        libreoffice

        discord
        slack
        zoom-us
        signal-desktop
        tdesktop

        spotify
        vlc

        gnugp
    ];

    environment.etc."fuse.conf".text = ''
        user_allow_other
    '';

    virtualisation = {
        docker = {
            enable = true;
        };
        virtualbox.host = {
            enable = true;
       };
    };
}
