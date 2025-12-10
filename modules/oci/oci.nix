# Mostly based on <nixpkgs>/nixos/modules/virtualisation/oci-common.nix

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  # Taken from /proc/cmdline of Ubuntu 20.04.2 LTS on OCI
  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"
  ] ++ lib.optional (pkgs.stdenv.hostPlatform.system == "x86_64-linux") "console=ttyS0"
  ++ lib.optional (pkgs.stdenv.hostPlatform.system == "aarch64-linux") "console=ttyAMA0,115200";

  services = {
    cloud-init.enable = true;
    qemuGuest.enable = true;
  };

  # https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/configuringntpservice.htm#Configuring_the_Oracle_Cloud_Infrastructure_NTP_Service_for_an_Instance
  networking.timeServers = [ "169.254.169.254" ];

  # Otherwise the instance may not have a working network-online.target,
  # making the fetch-ssh-keys.service fail
  networking.useNetworkd = lib.mkDefault true;
}
