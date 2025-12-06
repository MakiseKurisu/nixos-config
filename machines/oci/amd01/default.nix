{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      amd01 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
