{ config, lib, pkgs, ... }:

{
  virtualisation = {
    #lxd.enable = true; # conflict with systemd.enableUnifiedCgroupHierarchy
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
  };
}
