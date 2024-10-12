{ config, lib, pkgs, ... }:

{
  users.users.excalibur = {
    isNormalUser = true;
    description = "Excalibur";
    extraGroups = [
      "adbusers"
      "aria2"
      "audio"
      "cups"
      "dialout"
      "input"
      "libvirtd"
      "lp"
      "networkmanager"
      "realtime"
      "render"
      "scanner"
      "video"
      "wheel"
      "wireshark"
    ];
  };
}
