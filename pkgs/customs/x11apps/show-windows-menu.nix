{ pkgs, theme, ... }:

let
  rofi-theme = import ./rofi-themes/show-windows-menu.nix { inherit pkgs theme; };

  app = let
    rofi = "${pkgs.rofi}/bin/rofi -show window -theme ${rofi-theme}/share/show-windows-menu.rasi";
  in
    pkgs.writeShellScriptBin "show-windows-menu" ''
      ${rofi}
    '';
in 

pkgs.symlinkJoin {
  name = "show-windows-menu";
  version = "1";
  paths = [ rofi-theme app ];
}
