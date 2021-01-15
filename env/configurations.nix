
{ config, pkgs, ... }:

{
    imports = [
        ./current.nix
    ];

    nixpkgs.config = {
        allowUnfree = true;
    };

    users.users.bulentk = {
        isNormalUser = true;
        shell = pkgs.fish;

        group = "users";
        extraGroups = [ "wheel" ];

        createHome = true;
        home = "/home/bulentk";
    };

    security.sudo.wheelNeedsPassword = false;

    services = {
        openssh.enable = true;
    };


    environment = {
        systemPackages = with pkgs; [
            wget
            git
            vim
        ];

        variables.EDITOR = "vim";
    };
}
