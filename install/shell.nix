{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "nixos-builds";
  nativeBuildInputs = with pkgs; [
    git
    git-crypt
  ];

  shellHook = ''
    PATH=${pkgs.writeShellScriptBin "nix" ''
      ${pkgs.nix}/bin/nix --experimental-features "nix-command flakes" "$@"
    ''}/bin:$PATH
  '';
}