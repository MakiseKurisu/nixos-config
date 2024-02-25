{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    "${inputs.pr-dolphin}/nixos/modules/programs/dolphin.nix"
  ];
}
