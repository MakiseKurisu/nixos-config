{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      amd0 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
