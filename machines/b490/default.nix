{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      b490 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
