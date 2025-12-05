{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages =
      with pkgs; [
        virt-viewer
      ];
  };

  programs.virt-manager.enable = true;

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [
          virtiofsd
        ];
      };
    };
  };
}
