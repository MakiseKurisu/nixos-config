{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/media/aria2" = {
      device = "app01:/aria2";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };
  };
}
