{ config, lib, pkgs, ... }:

{
  services = {
    openssh.enable = true;
    qemuGuest.enable = true;
  };
}
