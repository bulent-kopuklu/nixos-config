
{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./machines/configurations.nix
        ./windowing/configurations.nix
    ];

    nixpkgs.config = {
        allowUnfree = true;
    };

    users.users.bulentk = {
        isNormalUser = true;
        extraGroups  = [ "docker" "networkmanager" "wheel" ]; # wheel for ‘sudo’.
        shell        = pkgs.fish;
    };    

    programs = {
        gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
        };

        fish.enable = true;
    };

    services = {
        openssh.enable = true;
        printing.enable = true;
    }

    environment.systemPackages = with pkgs; [
        wget
        git
        firefox
        vim
        sublime
    ];

    virtualisation = {
        docker = {
            enable = true;
        };
        virtualbox.host = {
            enable = true;
       };
    };

    system.stateVersion = "20.09";
}