{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      arm1 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
