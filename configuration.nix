
{ config, pkgs, ... }:

{
    imports = [
        ./sys/current.nix
    ];

    networking = {
        networkmanager = {
            enable   = true;
        };

        useDHCP = false;
        firewall.enable = false;
    };

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Istanbul";

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

    programs = {
        fish = {
            enable = true;
            promptInit = ''
                any-nix-shell fish --info-right | source
            '';
        };
    };

    environment = {
        systemPackages = with pkgs; [
            wget
            git
            vim
            alacritty
            fish
            any-nix-shell
            tar
            p7zip
            bzip2
            gzip
            zstd
            lzma
            zip
            unrar
            unzip

            lsof
            lshw
            bmon
            htop
            iotop
            iftop

            nettools
            netcat
            psmisc

            iptables
            curl

        ];

        variables.EDITOR = "vim";
    };

    nix = {
        autoOptimiseStore = true;

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };

        extraOptions = ''
            keep-outputs = true
            keep-derivations = true
        '';

        trustedUsers = [ "root" "bulentk" ];
    };
}
