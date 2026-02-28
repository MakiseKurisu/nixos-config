{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    distributedBuilds = true;
    buildMachines = (
      lib.filter (m: m.hostName != config.networking.hostName) [
        {
          hostName = "main";
          protocol = "ssh-ng";
          speedFactor = 32;
          sshUser = "excalibur";
          sshKey = "/home/excalibur/.ssh/id_rsa";
          supportedFeatures = [
            "cuda"
            "big-parallel"
            "kvm"
          ];
          systems = [
            "i686-linux"
            "x86_64-linux"
            "aarch64-linux"
          ];
        }
        {
          hostName = "p15";
          protocol = "ssh-ng";
          speedFactor = 12;
          sshUser = "excalibur";
          sshKey = "/home/excalibur/.ssh/id_rsa";
          supportedFeatures = [ "kvm" ];
          systems = [
            "i686-linux"
            "x86_64-linux"
          ];
        }
        {
          hostName = "nas";
          protocol = "ssh-ng";
          speedFactor = 6;
          sshUser = "excalibur";
          sshKey = "/home/excalibur/.ssh/id_rsa";
          supportedFeatures = [ "kvm" ];
          systems = [
            "i686-linux"
            "x86_64-linux"
          ];
        }
      ]
    );
  };
}
