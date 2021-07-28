{
  # Imports the overlay
  nixpkgs.overlays = [
    (import ./overlays/vscode.nix)
  ];
}
