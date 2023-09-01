{ config, lib, pkgs, ... }:

{
  boot = {
    #kernelPackages = pkgs.unstable.linuxPackages_latest;
    kernelParams = [
      "console=tty0"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot.enable = true;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
