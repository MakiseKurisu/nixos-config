{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/media/backup" = {
      device = "nas:/backup";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };
    "/media/raid" = {
      device = "nas:/raid";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };
  };
}
