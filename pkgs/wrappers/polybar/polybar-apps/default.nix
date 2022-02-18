{ pkgs, wifiSupport, ... }:

let
  theme = import ../../../../config/theme.nix;

  microphone = pkgs.callPackage ./polybar-microphone-listener.nix { inherit pkgs theme; };
  network-listener = pkgs.callPackage ./polybar-network-listener.nix { inherit pkgs theme; };
  network-menu = pkgs.callPackage ./polybar-network-menu.nix { inherit pkgs theme; wifiSupport = wifiSupport; };
in

pkgs.symlinkJoin {
  name = "polybar-apps";
  version = "1";
  paths = [ microphone network-listener network-menu ];
}
