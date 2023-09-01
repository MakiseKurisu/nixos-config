{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/media/qbittorrent" = {
      device = "app01:/qbittorrent";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
    };
  };
}
