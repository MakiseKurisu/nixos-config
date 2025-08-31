{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "services/home-automation/home-assistant.nix" ];
  imports = [
    "${inputs.pr-keyboard_remote}/nixos/modules/services/home-automation/home-assistant.nix"
  ];
}
