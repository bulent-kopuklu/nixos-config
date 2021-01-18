{ config, pkgs,... }:


{
    environment.systemPackages = with pkgs; [
        vscode
        jetbrains.idea-community
        emacs
        jdk11
        smartgithg
        docker-compose
        dive            # explorering a docker image 
        python3
        python3Packages.pip
        gradle_5
        maven
        ripgrep
        fd
        meld
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