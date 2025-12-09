{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      orion-o6n = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
