{ config, lib, pkgs, ... }:

{
  imports = [
    (import ../../modules/nix-on-droid.nix {
      inherit config lib pkg;
      android-system-bin-list = ./android-system-bin.list;
    })
  ];

  # Read the changelog before changing this value
  system.stateVersion = "24.05";
  home-manager.config.home = {
    stateVersion = "24.05";
    sessionVariables.NOD_FLAKE_DEFAULT_DEVICE = "p027";
  };
}
