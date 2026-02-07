{
  description = "Chrultrabook Homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    {

      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

      nixosConfigurations = {
        chrultrabook-homelab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/chrultrabook-homelab/configuration.nix
            ./modules/homelab/arr-stack.nix
          ];
        };
        # sudo nixos-rebuild switch --flake .#vvm-homelab
        vm-homelab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/vm-homelab/configuration.nix
            ./modules/homelab/arr-stack.nix
          ];
        };
      };
    };
}
