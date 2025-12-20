{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "main";
        protocol = "ssh-ng";
        speedFactor = 32;
        sshUser = "excalibur";
        supportedFeatures = [ "cuda" "big-parallel" "kvm" ];
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "p15";
        protocol = "ssh-ng";
        speedFactor = 12;
        sshUser = "excalibur";
        supportedFeatures = [ "kvm" ];
        systems = [ "x86_64-linux" ];
      }
      {
        hostName = "nas";
        protocol = "ssh-ng";
        speedFactor = 6;
        sshUser = "excalibur";
        supportedFeatures = [ "kvm" ];
        systems = [ "x86_64-linux" ];
      }
    ];
  };
}
