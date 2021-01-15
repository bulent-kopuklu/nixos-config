

{ config, pkgs, lib,... }:

let
        customfonts = pkgs.nerdfonts.override {
            fonts = [
                "JetBrainsMono"
                "UbuntuMono"
                "Iosevka"
            ];
        };
        myfonts = pkgs.callPackage font/font.nix { inherit pkgs; };
in
{
    users.users.bulentk = {
        extraGroups = [ "networkmanager" "audio" "video" ];
    };    

    hardware.bluetooth.enable = true;

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
            packages = [ pkgs.gnome3.dconf ];
        };
    };


    fonts = {
        enableDefaultFonts = true;

        fonts = with pkgs; [ 
            customfonts
            font-awesome-ttf
            myfonts.icomoon-feather
        ];

        fontconfig = {
            defaultFonts = {
#                monospace = [ "monospace" ];
            };
        };
    };

    environment.systemPackages = with pkgs; [
        firefox
        sublime
        fish
        alacritty
        rofi
        python3
        aspell
        aspellDicts.en
        aspellDicts.tr
        
        pwgen
        
        tar
        bzip2
        gxip
        zstd
        lzma
        zip
        unrar
        unzip

        lsof
        lshw


        iptables
        curl
        flac
        any-nix-shell
        asciinema
        
        bmon
        htop
        iotop
        iftop

        nettools
        psmisc
        
        libreoffice
        libnotify
        nix-doc
        mupdf
        pavucontrol
        paprefs
        pasystray
        playerctl
        polybar
        pulsemixer
        signal-desktop
        slack
        spotify
        tdesktop
        tree
        vlc
        xclip

        openvpn


        gnome3.evince
        gnome3.gnome-calendar
        gnome3.nautilus
        gnome3.zenity
        gnome3.adwaita-icon-theme
        
        font-awesome-ttf
        material-design-icons
    ];

    
}
