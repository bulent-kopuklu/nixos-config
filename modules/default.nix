 { config, pkgs, lib, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sys
    ./env
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
    };

#    package = pkgs.nixFlakes;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true; # TODO
      permittedInsecurePackages = [
        "openssl-1.0.2u"
        "nix-2.25.2"
      ];
    };

    overlays = import ../pkgs;
  };

  system.stateVersion = "24.11";
}

