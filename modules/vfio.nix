{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        virt-viewer
      ];
  };

  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      swtpm.enable = true;
      ovmf.packages = with pkgs; [
        OVMFFull.fd
      ];
      vhostUserPackages = with pkgs; [
        virtiofsd
      ];
    };
  };
}
