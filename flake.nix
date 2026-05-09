{
  description = "Chrultrabook Homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, sops-nix }:
    {

      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

      nixosConfigurations = {
        chrultrabook-homelab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/chrultrabook-homelab/configuration.nix
            ./modules/homelab/default-configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        vm-homelab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/vm-homelab/configuration.nix
            ./modules/homelab/default-configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
