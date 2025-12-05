{ config, lib, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      pr-fastapi-dls = import inputs.pr-fastapi-dls {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
  imports = [
    "${inputs.pr-fastapi-dls}/nixos/modules/services/misc/fastapi-dls.nix"
  ];
}
