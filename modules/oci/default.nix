{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./network.nix
    ./oci.nix
    ./services.nix
    ./wg.nix
    ../base-base.nix
    ../kernel.nix
    ../users-base.nix
    inputs.nixos-facter-modules.nixosModules.facter
  ];
}
