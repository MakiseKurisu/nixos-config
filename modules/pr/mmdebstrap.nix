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
      pr-mmdebstrap = import inputs.pr-mmdebstrap {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
  imports = [
    "${inputs.pr-mmdebstrap}/nixos/modules/programs/apt.nix"
  ];
}
