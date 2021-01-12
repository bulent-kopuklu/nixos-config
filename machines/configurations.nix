
{ ... }:

{
    imports = [
        ./current.nix
    ];

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    networking = {
        networkmanager = {
            enable   = true;
#            packages = [ pkgs.networkmanager_openvpn ];
        };

        useDHCP = false;

        firewall.enable = false;
    };

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Istanbul";

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