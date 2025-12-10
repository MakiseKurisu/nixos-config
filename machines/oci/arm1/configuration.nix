# Install VM with
#  nix run github:nix-community/nixos-anywhere -- --flake .#<machine> \
#    --generate-hardware-config nixos-facter machines/oci/<machine>/facter.json \
#    --target-host <user>@<host>

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../../modules/oci
  ];

  facter = {
    reportPath = ./facter.json;
  };

  networking.hostName = "arm1";
  system.stateVersion = "25.11";
}
