{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "services/home-automation/home-assistant.nix" ];
  imports = [
    "${inputs.nixpkgs-master}/nixos/modules/services/home-automation/home-assistant.nix"
  ];
}
