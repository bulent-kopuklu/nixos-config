{
  description = "bulentk's nixos system configurations ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
#    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    flatpaks.url = "github:gmodena/nix-flatpak";
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, nur, flatpaks, ... }: 
  let

  in {
    nixosConfigurations.bulentk-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ nur.overlay ]; }
         flatpaks.nixosModules.nix-flatpak
        ./hosts/bulentk-vm
        ./modules
        ];
    };

    nixosConfigurations.bulentk-e14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ 
        flatpaks.nixosModules.nix-flatpak
        ./hosts/bulentk-e14
        ./modules
        nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel
        ];
    };

    nixosConfigurations.bulentk-g14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        flatpaks.nixosModules.nix-flatpak
        ./hosts/bulentk-g14
        ./modules
#        nixos-hardware.nixosModules.asus-zephyrus-ga401
#        nixos-hardware.nixosModules.asus-battery {
#          hardware.asus.battery.chargeUpto = 70;
#        }
      ];
    };
  };
}
