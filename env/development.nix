{ config, pkgs,... }:

{
    environment.systemPackages = with pkgs; [
        sublime
        vscode
        emacs
        jdk11
        smartgithg
        docker-compose
        dive            # explorering a docker image 
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

    users.users.bulentk = {
        extraGroups = [ "docker" "vboxusers" ];
    };
}