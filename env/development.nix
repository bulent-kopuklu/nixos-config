
{ config, pkgs, ... }:

{
    imports = [
        ./common.nix
    ];
    
    users.users.bulentk = {
        extraGroups = [ "docker" "vboxusers" ];
    };    


    environment.systemPackages = with pkgs; [
        sublime
        vscode
        docker-compose
        dive
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
