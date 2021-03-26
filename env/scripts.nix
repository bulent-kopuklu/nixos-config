
{ pkgs, ... }:

let
  lock-screen = pkgs.writeScriptBin "lock-screen" ''
    #!${pkgs.stdenv.shell}
    i3
  '';

in {
  environment.systemPackages = [ helloWorld ];
}