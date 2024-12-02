{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "services/networking/aria2.nix" ];
  imports = [
    "${inputs.nixpkgs-master}/nixos/modules/services/networking/aria2.nix"
  ];
}
