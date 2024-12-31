{ config, lib, pkgs, inputs, ... }:

{
  disabledModules = [ "services/misc/pykms.nix" ];
  imports = [
    "${inputs.pr-pykms}/nixos/modules/services/misc/pykms.nix"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      pr-pykms = import inputs.pr-pykms {
        system = "${pkgs.system}";
        config.allowUnfree = true;
      };
    })
  ];
}
