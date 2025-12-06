{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      nas = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
