{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "hardware/video/nvidia.nix" ];
  imports = [
    "${inputs.nixpkgs-master}/nixos/modules/hardware/video/nvidia.nix"
  ];
}
