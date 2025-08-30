{ config, lib, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      pr-xiaomi_home = import inputs.pr-xiaomi_home {
        system = pkgs.system;
        config.allowUnfree = true;
      };
    })
  ];
}
