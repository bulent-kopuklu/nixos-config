
{ config, pkgs, ... }:

{
  imports = [
    ./sys/current
  ];

  nixpkgs.config = {
    allowUnfree = true;
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
  };

  system.stateVersion = "21.05";
 
}
