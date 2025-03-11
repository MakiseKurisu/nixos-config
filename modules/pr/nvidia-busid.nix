{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "hardware/video/nvidia.nix" ];
  imports = [
    "${inputs.pr-nvidia-busid}/nixos/modules/hardware/video/nvidia.nix"
  ];
}
