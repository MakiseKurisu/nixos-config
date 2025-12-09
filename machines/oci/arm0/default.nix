{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      arm0 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
