{ lib, ... }:
{
  options.flake.nixOnDroidConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Instantiated Nix-on-Droid configurations.";
  };
}
