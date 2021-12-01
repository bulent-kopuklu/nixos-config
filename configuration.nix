
{ config, pkgs, ... }:

{
  imports = [
    ./sys/current
  ];

  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "openssl-1.0.2u"
    ];
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

  system.stateVersion = "21.11";
 
}
