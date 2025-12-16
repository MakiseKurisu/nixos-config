{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "main";
        protocol = "ssh-ng";
        speedFactor = 32;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "p15";
        protocol = "ssh-ng";
        speedFactor = 12;
        systems = [ "x86_64-linux" ];
      }
      {
        hostName = "nas";
        protocol = "ssh-ng";
        speedFactor = 6;
        systems = [ "x86_64-linux" ];
      }
    ];
  };
}
