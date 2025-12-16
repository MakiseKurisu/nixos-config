{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "yuntian";
        protocol = "ssh-ng";
        speedFactor = 20;
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "b490";
        protocol = "ssh-ng";
        speedFactor = 4;
        systems = [ "x86_64-linux" ];
      }
      {
        hostName = "orion-o6n";
        protocol = "ssh-ng";
        speedFactor = 12;
        systems = [ "aarch64-linux" ];
      }
      {
        hostName = "mac01";
        protocol = "ssh-ng";
        speedFactor = 8;
        systems = [ "aarch64-linux" ];
      }
    ];
  };
}
