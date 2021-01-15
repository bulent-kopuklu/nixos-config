
{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./sys/configurations.nix
        ./wm/configurations.nix
        ./env/configurations.nix
    ];

    system.stateVersion = "20.09";
}
