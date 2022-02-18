{ pkgs, theme, ... }:

let
  rofi-theme = import ./rofi-themes/app-launcher-menu.nix { inherit pkgs theme; };

  app = let
    rofi = "${pkgs.rofi}/bin/rofi -no-config -no-lazy-grab -show drun -modi drun -theme ${rofi-theme}/share/app-launcher-menu.rasi";
  in
    pkgs.writeShellScriptBin "app-launcher-menu" ''
      ${rofi}
    '';
in 

pkgs.symlinkJoin {
  name = "app-launcher-menu";
  version = "1";
  paths = [ rofi-theme app ];
}
