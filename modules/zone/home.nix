{ config, lib, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    buildMachines = (lib.filter (m: m.hostName != config.networking.hostName) [
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
    ]);
  };

  programs = {
    ssh = {
      extraConfig = ''
        Host main
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host p15
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host nas
          IdentityFile /home/excalibur/.ssh/id_rsa
          IdentityFile ~/.ssh/id_rsa
        Host *
      '';
    };
  };
}
