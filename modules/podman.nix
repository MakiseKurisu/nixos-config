{ config, lib, pkgs, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    podman = {
      enable = true;
      autoPrune.enable = true;
    };
  };
}
