{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "tasks/powertop.nix" ];
  imports = [
    "${inputs.nixpkgs-master}/nixos/modules/tasks/powertop.nix"
  ];
}
