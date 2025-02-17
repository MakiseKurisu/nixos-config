{ config, lib, pkgs, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
    ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
    '';
  };

  environment = {
    systemPackages =
      with pkgs; [
        looking-glass-client
      ];
  };

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="excalibur", GROUP="incus", MODE="0660"
    '';
  };
}
