{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "services/networking/aria2.nix" ];
  imports = [
    "${inputs.pr-aria2}/nixos/modules/services/networking/aria2.nix"
  ];
}
