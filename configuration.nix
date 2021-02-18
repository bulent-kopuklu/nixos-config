
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

    i18n = {
#        consoleKeyMap = "us, tr";
        defaultLocale = "en_US.UTF-8";
    };
    
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

    environment.systemPackages = with pkgs; [
            wget
            git
            neovim
            alacritty
            fish
            tree
            file
            any-nix-shell
            gnutar
            p7zip
            bzip2
            gzip
            zstd
            lzma
            zip
            unrar
            unzip
            bmon
            htop
            iotop
            iftop
            nettools
            netcat
            psmisc
            lsof
            lshw
            usbutils
            pciutils
            nix-du
            arandr
            iptables
            curl
        ];

    environment.variables = {
        EDITOR = "vim";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
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
