{ config, lib, pkgs, ... }:

let
  theme = import ../../../config/theme.nix;
  app-launcher-menu = pkgs.callPackage ./app-launcher-menu.nix { inherit pkgs theme; };
  show-windows-menu = pkgs.callPackage ./show-windows-menu.nix { inherit pkgs theme; };
  lock-screen = pkgs.callPackage ./lock-screen.nix { inherit pkgs; };
  power-menu = pkgs.callPackage ./power-menu.nix { inherit pkgs theme lock-screen; };
  set-wallpaper = pkgs.callPackage ./set-wallpaper.nix { inherit pkgs; };
  audioctl = pkgs.callPackage ./audioctl.nix { inherit pkgs; };

in pkgs.symlinkJoin {
  name = "x11apps";
  version = "1";
  paths = [ app-launcher-menu show-windows-menu lock-screen power-menu set-wallpaper audioctl ];
}
