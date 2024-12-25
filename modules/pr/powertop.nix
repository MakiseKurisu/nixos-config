{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "tasks/powertop.nix" ];
  imports = [
    "${inputs.pr-powertop-fix}/nixos/modules/tasks/powertop.nix"
  ];
}
