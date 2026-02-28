{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      mdevctl = inputs.pr-mdevctl.legacyPackages.x86_64-linux.pkgs.mdevctl;
    })
  ];
  disabledModules = [ "programs/mdevctl.nix" ];
  imports = [
    "${inputs.pr-mdevctl}/nixos/modules/programs/mdevctl.nix"
  ];
}
