{ inputs, ... }:
{
  flake = {
    nixOnDroidConfigurations = {
      pjf110 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = inputs.nixpkgs-droid.legacyPackages."aarch64-linux";
        modules = [
          ./nix-on-droid.nix
        ];
      };
    };
  };
}
