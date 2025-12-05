{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      main = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
