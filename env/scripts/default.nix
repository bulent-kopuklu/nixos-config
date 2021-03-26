{ pkgs, ... }:

{
  lock-screen = pkgs.callPackage ./lock-screen.nix {};
}