{ config, lib, pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.unstable.linuxPackages;
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
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-windows"
    ];
  };
}
