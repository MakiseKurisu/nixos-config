{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        supportedFeatures = [
          "kvm"
          "big-parallel"
        ];
        sshUser = "excalibur";
        protocol = "ssh-ng";
        hostName = "app01.protoducer.com";
      }
    ];
  };
}
