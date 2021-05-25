{
  # Imports the overlay
  nixpkgs.overlays = [
    (import ./overlays/discord.nix)
  ];
}
