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
        supportedFeatures = [ "cuda" "big-parallel" "kvm" ];
        systems = [ "x86_64-linux" "aarch64-linux" ];
      }
      {
        hostName = "b490";
        protocol = "ssh-ng";
        speedFactor = 4;
        sshUser = "excalibur";
        supportedFeatures = [ "kvm" ];
        systems = [ "x86_64-linux" ];
      }
      {
        hostName = "orion-o6n";
        protocol = "ssh-ng";
        speedFactor = 12;
        sshUser = "excalibur";
        supportedFeatures = [ "big-parallel" "kvm" ];
        systems = [ "aarch64-linux" ];
      }
      {
        hostName = "mac01";
        protocol = "ssh-ng";
        speedFactor = 8;
        sshUser = "excalibur";
        supportedFeatures = [ "kvm" ];
        systems = [ "aarch64-linux" ];
      }
    ]);
  };

  programs = {
    ssh = {
      extraConfig = ''
        Host yuntian
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host b490
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host orion-o6n
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host mac01
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host *
      '';
    };
  };
}
