{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      p15 = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
