{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = (lib.filter (m: m.hostName != config.networking.hostName) [
      {
        hostName = "yuntian";
        protocol = "ssh-ng";
        speedFactor = 20;
        sshUser = "excalibur";
        sshKey = "/home/excalibur/.ssh/id_rsa";
        supportedFeatures = [ "cuda" "big-parallel" "kvm" ];
        systems = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "b490";
        protocol = "ssh-ng";
        speedFactor = 4;
        sshUser = "excalibur";
        sshKey = "/home/excalibur/.ssh/id_rsa";
        supportedFeatures = [ "kvm" ];
        systems = [ "i686-linux" "x86_64-linux" ];
      }
      {
        hostName = "mac01";
        protocol = "ssh-ng";
        speedFactor = 8;
        sshUser = "excalibur";
        sshKey = "/home/excalibur/.ssh/id_rsa";
        supportedFeatures = [ "kvm" ];
        systems = [ "aarch64-linux" ];
      }
    ]);
  };
}
