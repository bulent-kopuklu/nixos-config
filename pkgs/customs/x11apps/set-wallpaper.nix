{ config, pkgs, lib, ... }:

let
  wallpaper = ../../../config/wallpapers/doom-src.png;
  feh = "${pkgs.feh}/bin/feh";
in
pkgs.writeShellScriptBin "set-wallpaper" ''
  ${feh} --bg-scale ${wallpaper}
''
