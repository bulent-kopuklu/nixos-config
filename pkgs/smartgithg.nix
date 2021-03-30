
{
  # Imports the overlay
  nixpkgs.overlays = [
    (import ./overlays/smartgithg.nix)
  ];
}
