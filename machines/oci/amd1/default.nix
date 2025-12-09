{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      amd1 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
