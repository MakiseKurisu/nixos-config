{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./disko.nix
    ./network.nix
    ./oci.nix
    ./services.nix
    ./wg.nix
    ../base-base.nix
    ../kernel.nix
    ../sops.nix
    ../users-base.nix
    inputs.omniflake.flakes.nixos-facter-modules.nixosModules.facter
  ];
}
