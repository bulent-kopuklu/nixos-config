{ config, pkgs, ... }:

{
  services.xserver = {
    xkbOptions = "eurosign:e, grb: alt_space_toggle";
    xkbVariant = "alt";
    layout = "us, tr";
  }
}
