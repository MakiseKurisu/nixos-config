{ config, lib, pkgs, ... }:

{
  boot = {
    kernelPackages = lib.mkOverride 990 pkgs.unstable.linuxPackages;
    kernelParams = [
      "console=tty1"
    ];
    kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot.enable = true;
    };
  };
}
