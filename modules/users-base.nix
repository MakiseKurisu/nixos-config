{ config, lib, pkgs, ... }:

{
  users.users.excalibur = {
    isNormalUser = true;
    description = "Excalibur";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "video" "render" "libvirtd" "input" ];
  };
}
