{ pkgs, ... }:

let
  i3lock = "${pkgs.i3lock}/bin/i3lock}";
  playerctl = "${pkgs.playerctl}/bin/playerctl}";

in
pkgs.writeShellScriptBin "lock-screen" ''
  ${pkgs.i3lock}/bin/i3lock -c 000000
#  ${pkgs.playerctl}/bin/playerctl pause
#  ${pkgs.xorg.xset}/bin/xset dpms force off
''
