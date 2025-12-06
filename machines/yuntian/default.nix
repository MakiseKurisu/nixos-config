{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      yuntian = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
