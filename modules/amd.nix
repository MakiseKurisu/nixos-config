{ config, lib, pkgs, ... }:

{
  boot = {
    kernelParams = [
      "amd_pstate=active"
    ];
  };

  services.auto-epp.enable = true;
}
